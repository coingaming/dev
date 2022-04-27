#!/bin/bash

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"

. "$THIS_DIR/k8s-setup-utilities.sh"

BITCOIN_NETWORK="testnet"
CLOUD_PROVIDER="aws"
DATABASE_USERNAME="lsp"
IDEMPOTENCY_TOKEN=$(date +%F | md5 | cut -c1-5)

KUBERNETES_CLUSTER_NAME="lsp-$BITCOIN_NETWORK"
DATABASE_INSTANCE_NAME="$KUBERNETES_CLUSTER_NAME"

isAwsConfigured () {
  for VARNAME in "aws_access_key_id" "aws_secret_access_key" "region"; do
    if [ -z $(aws configure get $VARNAME) ]; then
      echo "Please set up \"$VARNAME\" by running \"aws configure\" in your terminal."
      exit 1;
    fi
  done
}

createIamOpenIdConnectProvider () {
  echo "Creating OpenIDConnectProvider on AWS [IAM]..."
  eksctl utils associate-iam-oidc-provider \
    --cluster="$KUBERNETES_CLUSTER_NAME" \
    --approve
}

createAwsLbControllerPolicy () {
  local POLICY_FILEPATH="$THIS_DIR/iam_policy.json"
  local POLICY_URL="https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.1/docs/install/iam_policy.json"

  curl -o "$POLICY_FILEPATH" "$POLICY_URL"

  echo "Creating policy for AWSLBController on AWS [IAM]..."
  aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document "file://$POLICY_FILEPATH"

  rm "$POLICY_FIPATH"
}

createAwsLbServiceAccount () {
  local AWS_ACCOUNT_ID=$(aws sts get-caller-identity | jq -r '.Account')

  echo "Creating service account for AWSLBController on AWS [EKS]..."
  eksctl create iamserviceaccount \
    --cluster="$KUBERNETES_CLUSTER_NAME" \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --role-name "AmazonEKSLoadBalancerControllerRole" \
    --attach-policy-arn="arn:aws:iam::$AWS_ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy" \
    --approve
}

createAwsLbController () {
  echo "Creating AWSLBController on AWS [EKS]..."
  helm repo add eks https://aws.github.io/eks-charts && \
  helm repo update && \
  helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName="$KUBERNETES_CLUSTER_NAME" \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller

  kubectl get deployment \
    -n kube-system aws-load-balancer-controller
}

createKubernetesCluster () {
  local AWS_REGION=$(aws configure get region)

  echo "Creating \"$KUBERNETES_CLUSTER_NAME\" k8s cluster on AWS [EKS]..."
  echo "Public CIDR range is required! (to access k8s api endpoint after cluster creation)"
  read -p "Input your public CIDR: " "KUBERNETES_API_ENDPOINT_PUBLIC_ACCESS_CIDR"

  cat <<EOF | eksctl create cluster -f -
  apiVersion: eksctl.io/v1alpha5
  kind: ClusterConfig
  metadata:
    name: ${KUBERNETES_CLUSTER_NAME}
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
      - ${KUBERNETES_API_ENDPOINT_PUBLIC_ACCESS_CIDR}
EOF
}

deleteKubernetesCluster () {
  # DB and DBsubnetGroup must be deleted prior to cluster deletion otherwise eksctl will fail to cleanly delete the cluster
  deleteDbInstance
  createDbSubnetGroup "$KUBERNETES_CLUSTER_NAME"

  echo "Deleting \"$KUBERNETES_CLUSTER_NAME\" k8s cluster from AWS [EKS]..."
  eksctl delete cluster "$KUBERNETES_CLUSTER_NAME" --wait
}

setupKubernetesCluster () {
  isInstalled eksctl && isInstalled helm && isAwsConfigured

  local CREATE_AWS_LB_CONTROLLER="createIamOpenIdConnectProvider && createAwsLbControllerPolicy && createAwsLbServiceAccount && createAwsLbController"

  if eksctl get cluster --name "$KUBERNETES_CLUSTER_NAME"; then
    confirmAction \
    "==> Delete existing \"$KUBERNETES_CLUSTER_NAME\" k8s cluster and create a new one" \
    "deleteKubernetesCluster && createKubernetesCluster && $CREATE_AWS_LB_CONTROLLER"
  else
    confirmAction \
    "==> Create new \"$KUBERNETES_CLUSTER_NAME\" k8s cluster" \
    "createKubernetesCluster && $CREATE_AWS_LB_CONTROLLER"
  fi
}

getHostedZoneId () {
  aws route53 list-hosted-zones-by-name \
    --dns-name "$DOMAIN_NAME" \
    --query "HostedZones[?Name=='$DOMAIN_NAME.'].Id" \
    --output text
}

createHostedZone () {
  echo "Creating \"$DOMAIN_NAME\" hosted zone on AWS [R53]..."
  aws route53 create-hosted-zone \
    --name "$DOMAIN_NAME" \
    --caller-reference "$IDEMPOTENCY_TOKEN"
}

deleteHostedZone () {
  echo "Deleting \"$DOMAIN_NAME\" hosted zone from AWS [R53]..."
  aws route53 delete-hosted-zone "$DOMAIN_NAME" --wait
}

setupHostedZone () {
  createHostedZone
}

getManagedCertArn () {
  local SERVICE_DOMAIN_NAME="$1"

  aws acm list-certificates \
    --query "CertificateSummaryList[?DomainName=='$SERVICE_DOMAIN_NAME'].CertificateArn" \
    --output text | cut -f1
}

upsertDNSRecord () {
  local RECORD_NAME="$1"
  local RECORD_VALUE="$2"

  local HOSTED_ZONE_ID=$(getHostedZoneId)
  local HOSTED_ZONE=${HOSTED_ZONE_ID##*/}

  local CHANGE_BATCH=$(cat <<EOM
    {
      "Changes": [
        {
          "Action": "UPSERT",
          "ResourceRecordSet": {
            "Name": "${RECORD_NAME}",
            "Type": "CNAME",
            "TTL": 300,
            "ResourceRecords": [
              {
                "Value": "${RECORD_VALUE}"
              }
            ]
          }
        }
      ]
    }
EOM
)

  local CHANGE_BATCH_REQUEST_ID=$(aws route53 change-resource-record-sets \
    --hosted-zone-id "$HOSTED_ZONE" \
    --change-batch "$CHANGE_BATCH" \
    --query "ChangeInfo.Id" \
    --output text)

  echo "Waiting for validation records to be created in Route53..."
  aws route53 wait resource-record-sets-changed \
    --id "$CHANGE_BATCH_REQUEST_ID"
}

createManagedCert () {
  local SERVICE_DOMAIN_NAME="$1"

  echo "Creating certificate for $SERVICE_DOMAIN_NAME on AWS [ACM]..."
  local CERT_ARN=$(aws acm request-certificate \
    --domain-name "$SERVICE_DOMAIN_NAME" \
    --validation-method DNS \
    --idempotency-token "$IDEMPOTENCY_TOKEN" \
    --query CertificateArn \
    --options CertificateTransparencyLoggingPreference=DISABLED \
    --output text)

  echo "Waiting until certificate is registered in ACM..."
  # TODO: refactor for polling instead of sleep!
  sleep 10;
  
  local VALIDATION_NAME=$(aws acm describe-certificate \
    --certificate-arn "$CERT_ARN" \
    --query "Certificate.DomainValidationOptions[?DomainName=='$SERVICE_DOMAIN_NAME'].ResourceRecord.Name" \
    --output text)

  local VALIDATION_VALUE=$(aws acm describe-certificate \
    --certificate-arn "$CERT_ARN" \
    --query "Certificate.DomainValidationOptions[?DomainName=='$SERVICE_DOMAIN_NAME'].ResourceRecord.Value" \
    --output text)

  upsertDNSRecord "$VALIDATION_NAME" "$VALIDATION_VALUE"

  echo "Waiting for certificate to validate..."
  aws acm wait certificate-validated \
    --certificate-arn "$CERT_ARN"
}

deleteManagedCert () {
  local CERT_ARN="$1"

  echo "Deleting \"$CERT_ARN\" certificate from AWS [ACM]..."
  aws acm delete-certificate \
    --certificate-arn "$CERT_ARN"
}

writeCertArn () {
  local SERVICE_NAME="$1"
  local SERVICE_DOMAIN_NAME="$2"
  local CERT_ARN=$(getManagedCertArn "$SERVICE_DOMAIN_NAME")
  local SERVICE_CERT_ARN_PATH="$SECRETS_DIR/$SERVICE/cert-arn.txt"

  echo "Saving $CERT_ARN to $SERVICE_CERT_ARN_PATH"
  echo -n "$CERT_ARN" > "$SERVICE_CERT_ARN_PATH"
}

setupManagedCerts () {
  for SERVICE in rtl lsp; do
    local SERVICE_DOMAIN_NAME=$(cat "$SECRETS_DIR/$SERVICE/domain-name.txt")
    local CERT_ARN=$(getManagedCertArn "$SERVICE_DOMAIN_NAME")
     
    if [ -n "$CERT_ARN" ]; then
      confirmAction \
        "==> Delete existing \"$SERVICE_DOMAIN_NAME\" cert and create a new one" \
        "deleteManagedCert $CERT_ARN && createManagedCert $SERVICE_DOMAIN_NAME && writeCertArn $SERVICE $SERVICE_DOMAIN_NAME"
    else
      confirmAction \
        "==> Create new \"$SERVICE_DOMAIN_NAME\" cert" \
        "createManagedCert $SERVICE_DOMAIN_NAME && writeCertArn $SERVICE $SERVICE_DOMAIN_NAME"
    fi
  done
}

getVpcId () {
  aws eks describe-cluster \
    --name "$KUBERNETES_CLUSTER_NAME" \
    --query "cluster.resourcesVpcConfig.vpcId" \
    --output text
}

getSecurityGroupId () {
  local VPC_ID=$(getVpcId "$KUBERNETES_CLUSTER_NAME")

  aws ec2 describe-security-groups \
    --filters "Name=group-name,Values=eks-cluster-sg-$KUBERNETES_CLUSTER_NAME*" "Name=vpc-id,Values=$VPC_ID" \
    --query "SecurityGroups[0].GroupId" --output text
}

createDbSubnetGroup () {
  local SUBNET_GROUP_NAME="$1"
  local VPC_ID=$(getVpcId "$KUBERNETES_CLUSTER_NAME")

  local PRIVATE_SUBNETS_ID=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=eksctl-$KUBERNETES_CLUSTER_NAME-cluster/SubnetPrivate*" \
    --query 'Subnets[*].SubnetId' \
    --output json | jq -c .)

  echo "Creating \"$SUBNET_GROUP_NAME\" database subnet group on AWS [RDS]..."
  aws rds create-db-subnet-group \
    --db-subnet-group-name "$SUBNET_GROUP_NAME" \
    --db-subnet-group-description "$SUBNET_GROUP_NAME" \
    --subnet-ids "$PRIVATE_SUBNETS_ID"
}

createDbSubnetGroup () {
  local SUBNET_GROUP_NAME="$1"

  echo "Deleting \"$SUBNET_GROUP_NAME\" database subnet group from AWS [RDS]..."
  aws rds delete-db-subnet-group \
    --db-subnet-group-name "$SUBNET_GROUP_NAME"
}

createDbInstance () {
  local DB_PASSWORD=$(cat "$POSTGRES_PATH/dbpassword.txt")
  local SG_ID=$(getSecurityGroupId "$KUBERNETES_CLUSTER_NAME")

  echo "Creating \"$DATABASE_INSTANCE_NAME\" database instance on AWS [RDS]..."
  aws rds create-db-instance \
    --engine postgres \
    --db-instance-identifier "$DATABASE_INSTANCE_NAME" \
    --allocated-storage 20 \
    --db-instance-class "db.t3.micro" \
    --no-publicly-accessible \
    --storage-type gp2 \
    --no-multi-az \
    --no-storage-encrypted \
    --no-deletion-protection \
    --master-username "$DATABASE_USERNAME" \
    --master-user-password "$DB_PASSWORD" \
    --db-subnet-group-name "$KUBERNETES_CLUSTER_NAME" \
    --vpc-security-group-ids "$SG_ID"

  echo "Waiting until \"$DATABASE_INSTANCE_NAME\" database instance is fully ready..."
  aws rds wait db-instance-available \
    --db-instance-identifier="$DATABASE_INSTANCE_NAME"
}

deleteDbInstance () {
  echo "Deleting \"$DATABASE_INSTANCE_NAME\" database instance from AWS [RDS]..."
  aws rds delete-db-instance \
    --db-instance-identifier "$DATABASE_INSTANCE_NAME" \
    --skip-final-snapshot \
    --delete-automated-backups

  echo "Waiting until \"$DATABASE_INSTANCE_NAME\" database instance is fully deleted..."
  aws rds wait db-instance-deleted \
    --db-instance-identifier="$DATABASE_INSTANCE_NAME"
}

writeDbUri () {
  local DB_PASSWORD=$(cat "$POSTGRES_PATH/dbpassword.txt")
  local DB_HOST=$(aws rds describe-db-instances \
    --filters "Name=db-instance-id,Values=$DATABASE_INSTANCE_NAME" \
    --query "*[].[Endpoint.Address,Endpoint.Port]" \
    --output json | jq -c -r .[0][0])
  local DB_URI="postgresql://$DATABASE_USERNAME:$DB_PASSWORD@$DB_HOST/postgres"
  local DB_CONN_PATH="$POSTGRES_PATH/conn.txt"

  echo -n "$DB_URI" > "$DB_CONN_PATH"
  echo "Saved connection details to $DB_CONN_PATH"
}

setupDbInstance () {
  isInstalled aws && isAwsConfigured

  local DB_INSTANCE_EXISTS=$(aws rds describe-db-instances \
    --filters "Name=db-instance-id,Values=$DATABASE_INSTANCE_NAME" \
    --query 'DBInstances[*].[DBInstanceIdentifier]' \
    --output text)

  local CREATE_DB="createDbSubnetGroup $KUBERNETES_CLUSTER_NAME && createDbInstance && writeDbUri"
  local DELETE_DB="deleteDbInstance && createDbSubnetGroup $KUBERNETES_CLUSTER_NAME"

  if [ -n "$DB_INSTANCE_EXISTS" ]; then
    confirmAction \
    "==> Delete existing \"$DATABASE_INSTANCE_NAME\" database instance and create a new one" \
    "$DELETE_DB && $CREATE_DB"
  else
    confirmAction \
    "==> Create new \"$DATABASE_INSTANCE_NAME\" database instance" \
    "$CREATE_DB"
  fi
}

getKubernetesServiceExternalIP () {
  local SERVICE_NAME="$1"

  kubectl get svc "$SERVICE_NAME" -o json | jq -r ".status.loadBalancer.ingress[].hostname"
}

getKubernetesIngressExternalIP () {
  local INGRESS_NAME="$1"

  kubectl get ingress "$INGRESS_NAME" -o json | jq -r ".status.loadBalancer.ingress[].hostname"
}

setupDNSRecords () {
  for SERVICE in bitcoind lnd lsp; do
    local SERVICE_DOMAIN_NAME=$(cat "$SECRETS_DIR/$SERVICE/domain-name.txt")
    local SERVICE_EXTERNAL_IP=$(getKubernetesServiceExternalIP "$SERVICE")

    echo "Adding CNAME DNS record for $SERVICE_DOMAIN_NAME k8s service..."

    upsertDNSRecord "$SERVICE_DOMAIN_NAME" "$SERVICE_EXTERNAL_IP"
  done

  local RTL_DOMAIN_NAME=$(cat "$RTL_PATH/domain-name.txt")
  local RTL_EXTERNAL_IP=$(getKubernetesIngressExternalIP rtl)

  echo "Adding CNAME DNS record for $RTL_DOMAIN_NAME k8s ingress.."

  upsertDNSRecord "$RTL_DOMAIN_NAME" "$RTL_EXTERNAL_IP"
}

getElbArn () {
  local SERVICE="$1"
  local VPC_ID=$(getVpcId)

  aws elbv2 describe-load-balancers \
    --query 'LoadBalancers[*].[LoadBalancerArn, VpcId]' \
    --output json | \
    jq -r '.[] | select(.[1] == "'$VPC_ID'")' | \
    jq -s | \
    jq -r '.[] | select(.[0] | contains("'$SERVICE'")) | .[0]'
}

getElbListenerArn () {
  local ELB_ARN="$1"
  local LISTENER_PORT="$2"

  aws elbv2 describe-listeners \
    --load-balancer-arn "$ELB_ARN" \
    --query 'Listeners[*].[ListenerArn, Port]' \
    --output json | \
    jq -r '.[] | select(.[1] == '$LISTENER_PORT') | .[0]'
}

deleteElbListener () {
  local LISTENER_ARN="$1"

  echo "Deleting \"$LISTENER_ARN\" ELB listener from AWS [ELB]..."
  aws elbv2 delete-listener \
    --listener-arn "$LISTENER_ARN"
}

setupElbListener () {
  local SERVICE_NAME="$1"
  local SERVICE_PORTS="$2"
  local ELB_ARN=$(getElbArn "$SERVICE_NAME")

  for SERVICE_PORT in $SERVICE_PORTS; do
    local ELB_LISTENER_ARN=$(getElbListenerArn "$ELB_ARN" "$SERVICE_PORT")

    echo "Deleting port $SERVICE_PORT from $SERVICE_NAME load balancer..."
    (deleteElbListener "$ELB_LISTENER_ARN") || true
  done
}

setupElbListeners () {
  setupElbListener "bitcoind" "18332 39703 39704"
  setupElbListener "lnd" "10009 8080"
}

echo "==> Starting setup for $BITCOIN_NETWORK on $CLOUD_PROVIDER."

confirmAction \
"==> Clean up previous build" \
"cleanBuildDir"

writeDomainName
checkRequiredFiles # TODO: dont use func here, check for file existence separately!! (or some files need to be always present?!)
setupKubernetesCluster
setupHostedZone
setupManagedCert
setupDbInstance

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

setupDNSRecords
setupElbListeners

echo "==> Setup for $BITCOIN_NETWORK on $CLOUD_PROVIDER has been completed!"
