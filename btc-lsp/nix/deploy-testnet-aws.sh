#!/bin/bash

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"

. "$THIS_DIR/k8s-setup-utilities.sh"
. "$THIS_DIR/deploy-aws-utilities.sh"

createKubernetesCluster () {
  local AWS_REGION=$(aws configure get region)

  echo "==> Creating \"$KUBERNETES_CLUSTER_NAME\" k8s cluster on AWS [EKS]..."
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

createIamOpenIdConnectProvider () {
  echo "==> Creating OpenIDConnectProvider on AWS [IAM]..."
  eksctl utils associate-iam-oidc-provider \
    --cluster="$KUBERNETES_CLUSTER_NAME" \
    --approve
}

createAwsLbControllerPolicy () {
  local POLICY_FILEPATH="$THIS_DIR/iam_policy.json"
  local POLICY_URL="https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.1/docs/install/iam_policy.json"

  curl -o "$POLICY_FILEPATH" "$POLICY_URL"

  echo "==> Creating policy for AWSLBController on AWS [IAM]..."
  aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document "file://$POLICY_FILEPATH"

  rm "$POLICY_FIPATH"
}

createAwsLbServiceAccount () {
  local AWS_ACCOUNT_ID=$(aws sts get-caller-identity | jq -r '.Account')

  echo "==> Creating service account for AWSLBController on AWS [EKS]..."
  eksctl create iamserviceaccount \
    --cluster="$KUBERNETES_CLUSTER_NAME" \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --role-name "AmazonEKSLoadBalancerControllerRole" \
    --attach-policy-arn="arn:aws:iam::$AWS_ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy" \
    --approve
}

createAwsLbController () {
  echo "==> Creating AWSLBController on AWS [EKS]..."
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

setupKubernetesCluster () {
  if eksctl get cluster --name "$KUBERNETES_CLUSTER_NAME"; then
    echo "Kubernetes cluster \"$KUBERNETES_CLUSTER_NAME\" already exists..."
  else
    createKubernetesCluster && \
      createIamOpenIdConnectProvider && \
      createAwsLbControllerPolicy && \
      createAwsLbServiceAccount && \
      createAwsLbController
  fi
}

createHostedZone () {
  echo "==> Creating \"$DOMAIN_NAME\" hosted zone on AWS [R53]..."
  aws route53 create-hosted-zone \
    --name "$DOMAIN_NAME" \
    --caller-reference "$IDEMPOTENCY_TOKEN"
}

setupHostedZone () {
  local HOSTED_ZONE_ID=$(getHostedZoneId "$DOMAIN_NAME")

  if [ -n "$HOSTED_ZONE_ID" ]; then
    echo "Hosted zone for \"$DOMAIN_NAME\" already exists..."
  else
    createHostedZone
  fi
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
      echo "Certificate for \"$SERVICE_DOMAIN_NAME\" already exists..."
    else
      createManagedCert "$SERVICE_DOMAIN_NAME" && \
        writeCertArn "$SERVICE" "$SERVICE_DOMAIN_NAME"
    fi
  done
}

createDbSubnetGroup () {
  local SUBNET_GROUP_NAME="$1"
  local VPC_ID=$(getVpcId "$KUBERNETES_CLUSTER_NAME")

  local PRIVATE_SUBNETS_ID=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=eksctl-$KUBERNETES_CLUSTER_NAME-cluster/SubnetPrivate*" \
    --query 'Subnets[*].SubnetId' \
    --output json | jq -c .)

  echo "==> Creating \"$SUBNET_GROUP_NAME\" database subnet group on AWS [RDS]..."
  aws rds create-db-subnet-group \
    --db-subnet-group-name "$SUBNET_GROUP_NAME" \
    --db-subnet-group-description "$SUBNET_GROUP_NAME" \
    --subnet-ids "$PRIVATE_SUBNETS_ID"
}

createDbInstance () {
  local DB_PASSWORD=$(cat "$POSTGRES_PATH/dbpassword.txt")
  local SG_ID=$(getSecurityGroupId "$KUBERNETES_CLUSTER_NAME")

  echo "==> Creating \"$DATABASE_INSTANCE_NAME\" database instance on AWS [RDS]..."
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
  local DB_INSTANCE_IDENTIFIER=$(aws rds describe-db-instances \
    --filters "Name=db-instance-id,Values=$DATABASE_INSTANCE_NAME" \
    --query 'DBInstances[*].[DBInstanceIdentifier]' \
    --output text)

  if [ -n "$DB_INSTANCE_IDENTIFIER" ]; then
    echo "Database instance for \"$DATABASE_INSTANCE_NAME\" already exists..."
  else
    createDbSubnetGroup "$KUBERNETES_CLUSTER_NAME" && \
    createDbInstance && \
    writeDbUri
  fi
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

confirmContinue "==> Start setting up $BITCOIN_NETWORK on $CLOUD_PROVIDER?"

isInstalled eksctl && \
  isInstalled helm && \
  isInstalled aws && \
  isAwsConfigured && \
  cleanBuildDir && \
  genSecureCreds && \
  writeDomainName && \
  checkRequiredFiles && \
  setupKubernetesCluster && \
  setupHostedZone && \
  setupManagedCerts

echo "==> Checking that certificate arns are saved"
checkFileExistsNotEmpty "$RTL_PATH/cert-arn.txt"
checkFileExistsNotEmpty "$LSP_PATH/cert-arn.txt"
echo "Cert arns are OK."

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
