#!/bin/bash

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"

. "$THIS_DIR/k8s-setup-utilities.sh"

BITCOIN_NETWORK="testnet"
CLOUD_PROVIDER="aws"
K8S_CLUSTER_NAME="lsp-$BITCOIN_NETWORK"
DB_INSTANCE_NAME="lsp-$BITCOIN_NETWORK"
DB_USERNAME="lsp"
TMP_DIR="/tmp"

isAwsConfigured () {
  for VARNAME in "aws_access_key_id" "aws_secret_access_key" "region"; do
    if [ -z `aws configure get $VARNAME` ]; then
      echo "Please set up \"$VARNAME\" by running \"aws configure\" in your terminal."
      exit 1;
    fi
  done
}

createK8Scluster () {
  local AWS_REGION=`aws configure get region`

  echo "Creating \"$K8S_CLUSTER_NAME\" k8s cluster on AWS..."

  echo "Public CIDR range is required! (to access Kubernetes API endpoint after cluster creation)"
  read -p "Input your public CIDR: " "K8S_API_ENDPOINT_PUBLIC_ACCESS_CIDR"

  cat <<EOF | eksctl create cluster -f -
  apiVersion: eksctl.io/v1alpha5
  kind: ClusterConfig
  metadata:
    name: ${K8S_CLUSTER_NAME}
    region: ${AWS_REGION}
  managedNodeGroups:
    - name: Standard-Workers
      desiredCapacity: 3
      instanceType: t3.medium
      maxSize: 4
      minSize: 1
      privateNetworking: true
      iam:
        withAddonPolicies:
          autoScaler: true
          awsLoadBalancerController: true
          certManager: true
          ebs: true
  vpc:
    clusterEndpoints:
      publicAccess: true
      privateAccess: true
    publicAccessCIDRs:
      # VPN
      - ${K8S_API_ENDPOINT_PUBLIC_ACCESS_CIDR}
EOF
}

deleteK8Scluster () {
  # DB and DBsubnetGroup must be deleted prior to cluster deletion otherwise eksctl will fail to cleanly delete the cluster
  deleteDBinstance
  deleteDBsubnetGroup "$K8S_CLUSTER_NAME"

  echo "Deleting \"$K8S_CLUSTER_NAME\" k8s cluster from AWS..."
  eksctl delete cluster "$K8S_CLUSTER_NAME" --wait
}

setupK8Scluster () {
  isInstalled eksctl && isInstalled helm && isAwsConfigured

  local CREATE_AWS_LB_CONTROLLER="createIAMOpenIDConnectProvider && createAWSLBControllerPolicy && createAWSLBServiceAccount createAWSLBController"

  if eksctl get cluster --name "$K8S_CLUSTER_NAME"; then
    confirmAction \
    "==> Delete existing \"$K8S_CLUSTER_NAME\" k8s cluster and create a new one" \
    "deleteK8Scluster && createK8Scluster && $CREATE_AWS_LB_CONTROLLER"
  else
    confirmAction \
    "==> Create new \"$K8S_CLUSTER_NAME\" k8s cluster" \
    "createK8Scluster"
  fi
}

createAWSLBControllerPolicy () {
  local POLICY_FILEPATH="$TMP_DIR/iam_policy.json"
  curl -o "$POLICY_FILEPATH" https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.1/docs/install/iam_policy.json
  aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document "file://$POLICY_FILEPATH" && \
  rm "$POLICY_FIPATH"
}

createIAMOpenIDConnectProvider () {
  eksctl utils associate-iam-oidc-provider \
  --cluster="$K8S_CLUSTER_NAME" \
  --approve
}

createAWSLBServiceAccount () {
  local AWS_ACCOUNT_ID=`aws sts get-caller-identity | jq -r '.Account'`

  eksctl create iamserviceaccount \
  --cluster="$K8S_CLUSTER_NAME" \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name "AmazonEKSLoadBalancerControllerRole" \
  --attach-policy-arn="arn:aws:iam::$AWS_ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy" \
  --approve
}

createAWSLBController () {
  helm repo add eks https://aws.github.io/eks-charts && \
  helm repo update && \
  helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName="$K8S_CLUSTER_NAME" \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller

  kubectl get deployment \
    -n kube-system aws-load-balancer-controller
}

getVpcId () {
  aws eks describe-cluster \
    --name "$K8S_CLUSTER_NAME" \
    --query "cluster.resourcesVpcConfig.vpcId" \
    --output text
}

getSecurityGroupId () {
  local VPC_ID=`getVpcId $K8S_CLUSTER_NAME`

  aws ec2 describe-security-groups \
    --filters "Name=group-name,Values=eks-cluster-sg-$K8S_CLUSTER_NAME*" "Name=vpc-id,Values=$VPC_ID" \
    --query "SecurityGroups[0].GroupId" --output text
}

createDBsubnetGroup () {
  local SUBNET_GROUP_NAME="$1"
  local VPC_ID=`getVpcId $K8S_CLUSTER_NAME`

  local PRIVATE_SUBNETS_ID=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=eksctl-$K8S_CLUSTER_NAME-cluster/SubnetPrivate*" \
    --query 'Subnets[*].SubnetId' \
    --output json | jq -c .)

  echo "Creating \"$SUBNET_GROUP_NAME\" database subnet group on AWS..."
  aws rds create-db-subnet-group \
    --db-subnet-group-name "$SUBNET_GROUP_NAME" \
    --db-subnet-group-description "$SUBNET_GROUP_NAME" \
    --subnet-ids "$PRIVATE_SUBNETS_ID"
}

deleteDBsubnetGroup () {
  local SUBNET_GROUP_NAME="$1"

  echo "Deleting \"$SUBNET_GROUP_NAME\" database subnet group from AWS..."
  aws rds delete-db-subnet-group \
    --db-subnet-group-name "$SUBNET_GROUP_NAME"
}

createDBinstance () {
  local DB_PASSWORD=`cat $POSTGRES_PATH/dbpassword.txt`
  local SG_ID=`getSecurityGroupId $K8S_CLUSTER_NAME`

  echo "Creating \"$DB_INSTANCE_NAME\" database instance on AWS..."
  aws rds create-db-instance \
    --engine postgres \
    --db-instance-identifier "$DB_INSTANCE_NAME" \
    --allocated-storage 20 \
    --db-instance-class "db.t3.micro" \
    --no-publicly-accessible \
    --storage-type gp2 \
    --no-multi-az \
    --no-storage-encrypted \
    --no-deletion-protection \
    --master-username "$DB_USERNAME" \
    --master-user-password "$DB_PASSWORD" \
    --db-subnet-group-name "$K8S_CLUSTER_NAME" \
    --vpc-security-group-ids "$SG_ID"

  echo "Waiting until \"$DB_INSTANCE_NAME\" database instance is fully ready..."
  aws rds wait db-instance-available \
    --db-instance-identifier="$DB_INSTANCE_NAME"
}

deleteDBinstance () {
  echo "Deleting \"$DB_INSTANCE_NAME\" database instance from AWS..."
  aws rds delete-db-instance \
    --db-instance-identifier "$DB_INSTANCE_NAME" \
    --skip-final-snapshot \
    --delete-automated-backups

  echo "Waiting until \"$DB_INSTANCE_NAME\" database instance is fully deleted..."
  aws rds wait db-instance-deleted \
    --db-instance-identifier="$DB_INSTANCE_NAME"
}

writeDBURI () {
  local DB_PASSWORD=`cat $POSTGRES_PATH/dbpassword.txt`
  local DB_HOST=$(aws rds describe-db-instances \
    --filters "Name=db-instance-id,Values=$DB_INSTANCE_NAME" \
    --query "*[].[Endpoint.Address,Endpoint.Port]" \
    --output json | jq -c -r .[0][0])
  local DB_URI="postgresql://$DB_USERNAME:$DB_PASSWORD@$DB_HOST/postgres"
  local DB_CONN_PATH="$POSTGRES_PATH/conn.txt"

  echo -n "$DB_URI" > "$DB_CONN_PATH"
  echo "Saved connection details to $DB_CONN_PATH"
}

setupDBInstance () {
  isInstalled aws && isAwsConfigured

  local DB_INSTANCE_EXISTS=$(aws rds describe-db-instances \
    --filters "Name=db-instance-id,Values=$DB_INSTANCE_NAME" \
    --query 'DBInstances[*].[DBInstanceIdentifier]' \
    --output text)

  local CREATE_DB="createDBsubnetGroup $K8S_CLUSTER_NAME && createDBinstance && writeDBURI"
  local DELETE_DB="deleteDBinstance && deleteDBsubnetGroup $K8S_CLUSTER_NAME"

  if [ -n "$DB_INSTANCE_EXISTS" ]; then
    confirmAction \
    "==> Delete existing \"$DB_INSTANCE_NAME\" database instance and create a new one" \
    "$DELETE_DB && $CREATE_DB"
  else
    confirmAction \
    "==> Create new \"$DB_INSTANCE_NAME\" database instance" \
    "$CREATE_DB"
  fi
}

echo "==> Starting setup for $BITCOIN_NETWORK on $CLOUD_PROVIDER."

confirmAction \
"==> Clean up previous build" \
"cleanBuildDir"

askForDomainName "$BITCOIN_NETWORK-$CLOUD_PROVIDER-"

confirmAction \
"==> Setup LetsEncrypt certificate?" \
"setupLetsEncryptCert"

checkRequiredFiles
setupK8Scluster
setupDBInstance

echo "==> Checking that db connection details are saved"
checkFileExistsNotEmpty "$POSTGRES_PATH/conn.txt" 
echo "Connection details are OK."

echo "==> Partial dhall"
sh "$THIS_DIR/hm-shell-docker.sh" --mini \
   "--run './nix/ns-dhall-compile.sh $BITCOIN_NETWORK $CLOUD_PROVIDER'"

confirmContinue "==> Deploy $BITCOIN_NETWORK to $CLOUD_PROVIDER?"

echo "==> Configuring environment for containers"
sh "$THIS_DIR/k8s-setup-env.sh"

echo "==> Deploying k8s resources"
sh "$THIS_DIR/k8s-deploy.sh" "bitcoind lnd"

echo "==> Waiting until containers are ready"
sh "$THIS_DIR/k8s-wait.sh" "bitcoind lnd"

echo "==> Initializing LND wallet"
sh "$THIS_DIR/k8s-lazy-init-unlock.sh"

echo "==> Exporting creds from running pods"
sh "$THIS_DIR/k8s-export-creds.sh"

echo "==> Full dhall"
sh "$THIS_DIR/hm-shell-docker.sh" --mini \
   "--run './nix/ns-dhall-compile.sh $BITCOIN_NETWORK $CLOUD_PROVIDER'"

echo "==> Configuring environment for containers"
sh "$THIS_DIR/k8s-setup-env.sh"

echo "==> Deploying additional k8s resources"
sh "$THIS_DIR/k8s-deploy.sh" "rtl lsp"

echo "==> Waiting until containers are ready"
sh "$THIS_DIR/k8s-wait.sh" "rtl lsp"

echo "==> Setup for $BITCOIN_NETWORK on $CLOUD_PROVIDER has been completed!"
