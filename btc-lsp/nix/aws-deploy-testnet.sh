#!/bin/bash
# shellcheck disable=SC2155

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"

. "$THIS_DIR/utilities.sh"
. "$THIS_DIR/aws-utilities.sh"
. "$THIS_DIR/cloudflare-utilities.sh"

createCluster () {
  local AWS_REGION=$(aws configure get region)

  echo "==> Creating \"$KUBERNETES_CLUSTER_NAME\" k8s cluster on AWS [EKS]..."
  echo "Public CIDR range is required! (to access k8s api endpoint after cluster creation)"
  read -r -p "Input your public CIDR: " "KUBERNETES_API_ENDPOINT_PUBLIC_ACCESS_CIDR"

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
      volumeSize: 10
      privateNetworking: true
      iam:
        withAddonPolicies:
          autoScaler: true
          awsLoadBalancerController: true
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

  rm "$POLICY_FILEPATH"
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

  echo "Verifying that AwsLBController has been successfully installed..."
  kubectl get deployment \
    -n kube-system aws-load-balancer-controller
}

setupCluster () {
  if "$(clusterExists)"; then
    echo "==> Cluster \"$KUBERNETES_CLUSTER_NAME\" already exists."
  else
    createCluster && \
      createIamOpenIdConnectProvider && \
      createAwsLbControllerPolicy && \
      createAwsLbServiceAccount && \
      createAwsLbController
  fi
}

delegateCloudflareDomain () {
  local DOMAIN_NAME="$1"
  local NS_RECORDS="$2"

  setCloudflareCreds

  local CLOUDFLARE_HOSTED_ZONE_ID=$(getCloudflareHostedZoneId)

  for NS_RECORD in $NS_RECORDS; do
    local DNS_RECORD_ID=$(getCloudflareDNSRecordId "$CLOUDFLARE_HOSTED_ZONE_ID" "$DOMAIN_NAME" "$NS_RECORD")

    if [ -n "$DNS_RECORD_ID" ]; then
      echo "==> NS record \"$NS_RECORD\" for \"$DOMAIN_NAME\" already exists."
    else
      echo "==> Adding \"$NS_RECORD\" NS record for \"$DOMAIN_NAME\" in Cloudflare."
      createCloudflareDNSRecord "$CLOUDFLARE_HOSTED_ZONE_ID" "$DOMAIN_NAME" "$NS_RECORD" 1>/dev/null
    fi
  done
}

delegateDomain () {
  local DNS_PROVIDER="$1"
  local DOMAIN_NAME="$2"
  local NS_RECORDS="$3"

  case "$DNS_PROVIDER" in
    "cloudflare")
      delegateCloudflareDomain "$DOMAIN_NAME" "$NS_RECORDS";;
    *)
      echo "==> DNS provider \"$DNS_PROVIDER\" is not supported. Please add the NS records displayed below by yourself."
      echo "$NS_RECORDS";;
  esac
}

createHostedZone () {
  local CALLER_REFERENCE=$(uuidgen)

  aws route53 create-hosted-zone \
    --name "$DOMAIN_NAME" \
    --query "DelegationSet.NameServers" \
    --caller-reference "$CALLER_REFERENCE" \
    --output text
}

setupHostedZone () {
  local HOSTED_ZONE_ID=$(getHostedZoneId "$DOMAIN_NAME")

  if [ -n "$HOSTED_ZONE_ID" ]; then
    echo "==> Hosted zone for \"$DOMAIN_NAME\" already exists."
  else
    echo "==> Creating \"$DOMAIN_NAME\" hosted zone on AWS [R53]..."
    local NS_RECORDS=$(createHostedZone)

    echo "==> If your DNS provider for \"$DOMAIN_NAME\" is not Route53, you must delegate the domain to Route53 before continuing..."

    setDNSProvider && delegateDomain "$DNS_PROVIDER" "$DOMAIN_NAME" "$NS_RECORDS"

    confirmContinue "==> Have you delegated \"$DOMAIN_NAME\" to the Route53 nameservers"

    until nslookup -type=NS "$DOMAIN_NAME" > /dev/null; do
      echo "Waiting until \"$DOMAIN_NAME\" is resolvable by Route53 nameservers..."
      sleep 30;
    done
  fi
}

createCert () {
  local SERVICE_DOMAIN_NAME="$1"
  local HOSTED_ZONE_ID=$(getHostedZoneId "$DOMAIN_NAME")
  if [ `uname -s` = "Darwin" ]; then
    local IDEMPOTENCY_TOKEN=$(date +%F | md5 | cut -c1-5)
  else
    local IDEMPOTENCY_TOKEN=$(date +%F | md5sum | cut -c1-5)
  fi

  echo "==> Creating certificate for \"$SERVICE_DOMAIN_NAME\" on AWS [ACM]..."
  local CERT_ARN=$(aws acm request-certificate \
    --domain-name "$SERVICE_DOMAIN_NAME" \
    --subject-alternative-names "*.$DOMAIN_NAME" \
    --validation-method DNS \
    --idempotency-token "$IDEMPOTENCY_TOKEN" \
    --query CertificateArn \
    --options CertificateTransparencyLoggingPreference=DISABLED \
    --output text)

  echo "Waiting until dns record appears in ACM..."
  until [ -n "$(getDNSValidationName "$CERT_ARN" "$SERVICE_DOMAIN_NAME")" ] ; do
    sleep 1;
  done

  local VALIDATION_NAME=$(getDNSValidationName "$CERT_ARN" "$SERVICE_DOMAIN_NAME")
  local VALIDATION_VALUE=$(getDNSValidationValue "$CERT_ARN" "$SERVICE_DOMAIN_NAME")

  changeDNSRecord "$HOSTED_ZONE_ID" "UPSERT" "$VALIDATION_NAME" "$VALIDATION_VALUE"

  echo "Waiting for certificate to validate..."
  aws acm wait certificate-validated \
    --certificate-arn "$CERT_ARN"
}

writeCertArn () {
  local SERVICE_NAME="$1"
  local SERVICE_DOMAIN_NAME="$2"
  local CERT_ARN=$(getCertArn "$SERVICE_DOMAIN_NAME")
  local SERVICE_CERT_ARN_PATH="$SECRETS_DIR/$SERVICE/certarn.txt"

  echo "Saving $CERT_ARN to $SERVICE_CERT_ARN_PATH"
  echo -n "$CERT_ARN" > "$SERVICE_CERT_ARN_PATH"
}

setupCerts () {
  for SERVICE in rtl lsp; do
    local SERVICE_DOMAIN_NAME=$(cat "$SECRETS_DIR/$SERVICE/domainname.txt")
    local CERT_ARN=$(getCertArn "$SERVICE_DOMAIN_NAME")

    if [ -n "$CERT_ARN" ]; then
      echo "==> Certificate for \"$SERVICE_DOMAIN_NAME\" already exists."
    else
      createCert "$SERVICE_DOMAIN_NAME" && writeCertArn "$SERVICE" "$SERVICE_DOMAIN_NAME"
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
    --subnet-ids "$PRIVATE_SUBNETS_ID" 1>/dev/null
}

setupDbSubnetGroup () {
  local DB_SUBNET_GROUP_ARN=$(getDbSubnetGroupArn "$KUBERNETES_CLUSTER_NAME")

  if [ -n "$DB_SUBNET_GROUP_ARN" ]; then
    echo "==> Database subnet group for \"$DATABASE_INSTANCE_NAME\" already exists."
  else
    createDbSubnetGroup "$KUBERNETES_CLUSTER_NAME"
  fi
}

createDbInstance () {
  local DATABASE_USERNAME="$1"
  local DATABASE_PASSWORD="$2"
  local DATABASE_NAME="$3"
  local SECURITY_GROUP_ID=$(getSecurityGroupId "$KUBERNETES_CLUSTER_NAME")

  echo "==> Creating \"$DATABASE_INSTANCE_NAME\" database instance on AWS [RDS]..."
  aws rds create-db-instance \
    --engine postgres \
    --db-instance-identifier "$DATABASE_INSTANCE_NAME" \
    --db-name "$DATABASE_NAME" \
    --allocated-storage 20 \
    --db-instance-class "db.t3.micro" \
    --no-publicly-accessible \
    --storage-type gp2 \
    --no-multi-az \
    --no-storage-encrypted \
    --no-deletion-protection \
    --master-username "$DATABASE_USERNAME" \
    --master-user-password "$DATABASE_PASSWORD" \
    --db-subnet-group-name "$KUBERNETES_CLUSTER_NAME" \
    --vpc-security-group-ids "$SECURITY_GROUP_ID" 1>/dev/null

  echo "Waiting until \"$DATABASE_INSTANCE_NAME\" database instance is up and running..."
  aws rds wait db-instance-available \
    --db-instance-identifier="$DATABASE_INSTANCE_NAME"
}

writeDbUri () {
  local DATABASE_USERNAME="$1"
  local DATABASE_USER_PASSWORD="$2"
  local DATABASE_NAME="$3"
  local DATABASE_HOST=$(aws rds describe-db-instances \
    --filters "Name=db-instance-id,Values=$DATABASE_INSTANCE_NAME" \
    --query "*[].[Endpoint.Address,Endpoint.Port]" \
    --output json | jq -c -r .[0][0])
  local DATABASE_URI="postgresql://$DATABASE_USERNAME:$DATABASE_USER_PASSWORD@$DATABASE_HOST/$DATABASE_NAME"

  echo "Saving database connection details to $POSTGRES_PATH/dburi.txt"
  echo -n "$DATABASE_URI" > "$POSTGRES_PATH/dburi.txt"
}

setupDbInstance () {
  local DATABASE_USERNAME="lsp"
  local DATABASE_USER_PASSWORD=$(cat "$POSTGRES_PATH/dbpassword.txt")
  local DATABASE_NAME="$DATABASE_USERNAME"
  local DATABASE_INSTANCE_IDENTIFIER=$(getDbInstanceIdentifier)

  if [ -n "$DATABASE_INSTANCE_IDENTIFIER" ]; then
    echo "==> Database instance for \"$DATABASE_INSTANCE_NAME\" already exists."
  else
    createDbInstance "$DATABASE_USERNAME" "$DATABASE_USER_PASSWORD" "$DATABASE_NAME" && \
      writeDbUri "$DATABASE_USERNAME" "$DATABASE_USER_PASSWORD" "$DATABASE_NAME"
  fi
}

setupDNSRecord () {
  local HOSTED_ZONE_ID="$1"
  local SERVICE_DOMAIN_NAME="$2"
  local CNAME_VALUE="$3"
  local DNS_RECORD=$(getDNSRecord "$HOSTED_ZONE_ID" "$SERVICE_DOMAIN_NAME")

  if [ -n "$DNS_RECORD" ]; then
    echo "==> CNAME record for \"$SERVICE_DOMAIN_NAME\" already exists."
  else
    echo "==> Adding CNAME record for \"$SERVICE_DOMAIN_NAME\""
    changeDNSRecord "$HOSTED_ZONE_ID" "UPSERT" "$SERVICE_DOMAIN_NAME" "$CNAME_VALUE"
  fi
}

setupDNSRecords () {
  local HOSTED_ZONE_ID=$(getHostedZoneId "$DOMAIN_NAME")

  for SERVICE in bitcoind lnd lsp; do
    local SERVICE_DOMAIN_NAME=$(cat "$SECRETS_DIR/$SERVICE/domainname.txt")
    local CNAME_VALUE=$(getKubernetesServiceExternalIP "$SERVICE")

    setupDNSRecord "$HOSTED_ZONE_ID" "$SERVICE_DOMAIN_NAME" "$CNAME_VALUE"
  done

  local SERVICE_DOMAIN_NAME=$(cat "$RTL_PATH/domainname.txt")
  local CNAME_VALUE=$(getKubernetesIngressExternalIP rtl)

  setupDNSRecord "$HOSTED_ZONE_ID" "$SERVICE_DOMAIN_NAME" "$CNAME_VALUE"
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

    if [ -n "$ELB_LISTENER_ARN" ]; then
      echo "==> Deleting port $SERVICE_PORT from $SERVICE_NAME load balancer..."
      deleteElbListener "$ELB_LISTENER_ARN"
    fi
  done
}

setupElbListeners () {
  setupElbListener "bitcoind" "18332 39703 39704"
  setupElbListener "lnd" "10009 8080"
}

# Check that required executables are installed & configured
isInstalled eksctl && \
  isInstalled helm && \
  isInstalled aws && \
  isAwsConfigured

confirmContinue "==> Start to set up \"$KUBERNETES_CLUSTER_NAME\" on $CLOUD_PROVIDER"

confirmAction \
"==> Clean up previous build" \
"cleanBuildDir && genSecureCreds"

# Check that required files are generated
checkRequiredFiles && setDomainName

echo "==> Checking that service domain names exist and are not empty"
for SERVICE in bitcoind lnd rtl lsp; do
  checkFileExistsNotEmpty "$SECRETS_DIR/$SERVICE/domainname.txt"
done
echo "Service domain names are OK."

# Disable need for user prompt after running aws commands
disableAwsCliPager

# Create eks cluster, route53 hosted zone and request certs from acm
setupCluster && \
setupHostedZone && \
setupCerts

echo "==> Checking that certificate arns are saved"
checkFileExistsNotEmpty "$RTL_PATH/certarn.txt"
checkFileExistsNotEmpty "$LSP_PATH/certarn.txt"
echo "Cert arns are OK."

# Create subnet group and rds postgres instance
setupDbSubnetGroup && setupDbInstance

echo "==> Checking that db connection details exist and are not empty"
checkFileExistsNotEmpty "$POSTGRES_PATH/dburi.txt"
echo "Connection details are OK."

confirmContinue "==> Deploy \"$KUBERNETES_CLUSTER_NAME\" to $CLOUD_PROVIDER"

# Deploy partial env
echo "==> Partial dhall"
sh "$THIS_DIR/hm-shell-docker.sh" --mini \
   "--run './nix/ns-dhall-compile.sh $BITCOIN_NETWORK $CLOUD_PROVIDER'"

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

# Deploy full env
echo "==> Full dhall"
sh "$THIS_DIR/hm-shell-docker.sh" --mini \
   "--run './nix/ns-dhall-compile.sh $BITCOIN_NETWORK $CLOUD_PROVIDER'"

echo "==> Configuring environment for containers"
sh "$THIS_DIR/k8s-setup-env.sh"

echo "==> Deploying additional k8s resources"
sh "$THIS_DIR/k8s-deploy.sh" "rtl lsp"

echo "==> Waiting until containers are ready"
sh "$THIS_DIR/k8s-wait.sh" "rtl lsp"

# Create dns records in route53 and delete some ports (which should be private!) from elb
setupDNSRecords && setupElbListeners

echo "==> Finished setting up \"$KUBERNETES_CLUSTER_NAME\" on $CLOUD_PROVIDER!"
