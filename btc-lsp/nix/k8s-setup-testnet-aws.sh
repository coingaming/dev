#!/bin/bash

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"

. "$THIS_DIR/k8s-setup-utilities.sh"

BITCOIN_NETWORK="testnet"
EKS_CLUSTER_NAME="lsp-$BITCOIN_NETWORK"
RDS_DB_IDENTIFIER="lsp-$BITCOIN_NETWORK"
K8S_API_ENDPOINT_PUBLIC_ACCESS_CIDR="$1"

if [ -z "$K8S_API_ENDPOINT_PUBLIC_ACCESS_CIDR" ]; then
  echo "Public CIDR range is required! (to access Kubernetes API endpoint after cluster creation)"
  exit 1;
fi

isAwsConfigured () {
  for VARNAME in "aws_access_key_id" "aws_secret_access_key" "region"; do
    if [ -z `aws configure get $VARNAME` ]; then
      echo "Please set up \"$VARNAME\" by running \"aws configure\" in your terminal."
      exit 1;
    fi
  done
}

createK8Scluster () {
  local K8S_CLUSTER_NAME="$1"
  local AWS_REGION=`aws configure get region`

  echo "Creating \"$K8S_CLUSTER_NAME\" k8s cluster on AWS..."

  cat <<EOF | eksctl create cluster -f -
  apiVersion: eksctl.io/v1alpha5
  kind: ClusterConfig
  metadata:
    name: ${K8S_CLUSTER_NAME}
    region: ${AWS_REGION}
  managedNodeGroups:
    - name: standard-workers
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
      - ${VPN_CIDR}
EOF
}

deleteK8Scluster () {
  local K8S_CLUSTER_NAME="$1"

  echo "Deleting \"$K8S_CLUSTER_NAME\" k8s cluster from AWS..."
  eksctl delete cluster "$K8S_CLUSTER_NAME" --wait
}

setupK8Scluster () {
  isInstalled eksctl && isAwsConfigured

  local K8S_CLUSTER_NAME="$1"

  if eksctl get cluster --name "$K8S_CLUSTER_NAME"; then
    confirmAction \
    "==> Delete existing \"$K8S_CLUSTER_NAME\" k8s cluster and create a new one" \
    "deleteK8Scluster $K8S_CLUSTER_NAME && createK8Scluster $K8S_CLUSTER_NAME"
  else
    confirmAction \
    "==> Create new \"$K8S_CLUSTER_NAME\" k8s cluster" \
    "createK8Scluster $K8S_CLUSTER_NAME"
  fi
}

getVpcId () {
  local K8S_CLUSTER_NAME="$1"

  aws eks describe-cluster \
    --name "$K8S_CLUSTER_NAME" \
    --query "cluster.resourcesVpcConfig.vpcId" \
    --output text
}

getSecurityGroupId () {
  local K8S_CLUSTER_NAME="$1"
  local VPC_ID=`getVpcId $K8S_CLUSTER_NAME`

  aws ec2 describe-security-groups \
    --filters "Name=group-name,Values=eks-cluster-sg-$K8S_CLUSTER_NAME*" "Name=vpc-id,Values=$VPC_ID" \
    --query "SecurityGroups[0].GroupId" --output text
}

createDBinstance () {
  local DB_INSTANCE_IDENTIFIER="$1"
  local K8S_CLUSTER_NAME="$2"
  local DB_USERNAME="lsp"
  local DB_PASSWORD=`cat $POSTGRES_PATH/dbpassword.txt`
  local SG_ID=`getSecurityGroupId $K8S_CLUSTER_NAME`

  # Save username
  echo "$DB_USERNAME" > "$POSTGRES_PATH/dbusername.txt"

  createDBsubnetGroup "$K8S_CLUSTER_NAME" "$K8S_CLUSTER_NAME"

  echo "Creating \"$DB_INSTANCE_IDENTIFIER\" database instance on AWS..."
  aws rds create-db-instance \
    --engine postgres \
    --db-instance-identifier "$DB_INSTANCE_IDENTIFIER" \
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
}

deleteDBinstance () {
  local DB_INSTANCE_IDENTIFIER="$1"
  local SUBNET_GROUP_NAME="$2"

  deleteDBsubnetGroup "$SUBNET_GROUP_NAME"

  echo "Deleting \"$DB_INSTANCE_IDENTIFIER\" database instance from AWS..."
  aws rds delete-db-instance \
    --db-instance-identifier "$DB_INSTANCE_IDENTIFIER" \
    --skip-final-snapshot \
    --delete-automated-backups

  echo "Waiting until \"$DB_INSTANCE_IDENTIFIER\" database instance is fully deleted..."
  aws rds wait db-instance-deleted --db-instance-identifier="$DB_INSTANCE_IDENTIFIER"
}

writeDBURI () {
  exit

  aws rds describe-db-instances \
  --query "*[].[DBInstanceIdentifier,Endpoint.Address,Endpoint.Port,MasterUsername]"

  local PG_INSTANCE_NAME="$1"
  local PG_INSTANCE_ID=`getPostgresInstanceId $1`
  local PG_URI=`doctl databases connection $PG_INSTANCE_ID --format URI --no-header`
  local PG_CONN_PATH="$POSTGRES_PATH/conn.txt"

  echo "==> Saving pg connection details"
  mkdir -p "$POSTGRES_PATH"

  echo -n "$PG_URI" > "$PG_CONN_PATH"
  echo "Saved connection details to $PG_CONN_PATH"
}

setupDBInstance () {
  isInstalled aws && isAwsConfigured

  local K8S_CLUSTER_NAME="$1"
  local DB_INSTANCE_IDENTIFIER="$2"
  local DB_INSTANCE_EXISTS=$(aws rds describe-db-instances \
    --filters "Name=db-instance-id,Values=$DB_INSTANCE_IDENTIFIER" \
    --query 'DBInstances[*].[DBInstanceIdentifier]' \
    --output text)

  if [ -n "$DB_INSTANCE_EXISTS" ]; then
    confirmAction \
    "==> Delete existing \"$DB_INSTANCE_IDENTIFIER\" database instance and create a new one" \
    "deleteDBinstance $DB_INSTANCE_IDENTIFIER $K8S_CLUSTER_NAME && createDBinstance $DB_INSTANCE_IDENTIFIER $K8S_CLUSTER_NAME && writeDBURI $DB_INSTANCE_IDENTIFIER"
  else
    confirmAction \
    "==> Create new \"$DB_INSTANCE_IDENTIFIER\" database instance" \
    "createDBinstance $DB_INSTANCE_IDENTIFIER $K8S_CLUSTER_NAME && writeDBURI $DB_INSTANCE_IDENTIFIER"
  fi
}

createDBsubnetGroup () {
  local K8S_CLUSTER_NAME="$1"
  local SUBNET_GROUP_NAME="$2"
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

confirmAction \
"==> Clean up previous build" \
"cleanBuildDir"

#askForDomainName "$BITCOIN_NETWORK-"

# confirmAction \
# "==> Setup LetsEncrypt certificate?" \
# "setupLetsEncryptCert"

checkRequiredFiles

setupK8Scluster "$EKS_CLUSTER_NAME"

setupDBInstance "$EKS_CLUSTER_NAME" "$RDS_DB_IDENTIFIER"

exit

echo "==> Checking that postgres connection details are saved"
checkFileExistsNotEmpty "$POSTGRES_PATH/conn.txt" 
echo "Connection details are OK."

echo "==> Partial dhall"
sh "$THIS_DIR/hm-shell-docker.sh" --mini \
   "--run './nix/ns-dhall-compile.sh $BITCOIN_NETWORK'"

confirmContinue "==> Deploy to $BITCOIN_NETWORK?"

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
   "--run './nix/ns-dhall-compile.sh $BITCOIN_NETWORK'"

echo "==> Configuring environment for containers"
sh "$THIS_DIR/k8s-setup-env.sh"

echo "==> Deploying additional k8s resources"
sh "$THIS_DIR/k8s-deploy.sh" "rtl lsp"

echo "==> Waiting until containers are ready"
sh "$THIS_DIR/k8s-wait.sh" "rtl lsp"

echo "==> Setup for $BITCOIN_NETWORK has been completed!"
