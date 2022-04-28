#!/bin/bash

set -e

BITCOIN_NETWORK="testnet"
CLOUD_PROVIDER="aws"
KUBERNETES_CLUSTER_NAME="lsp-$BITCOIN_NETWORK"
DATABASE_INSTANCE_NAME="$KUBERNETES_CLUSTER_NAME"
IDEMPOTENCY_TOKEN=$(date +%F | md5 | cut -c1-5)

isAwsConfigured () {
  for VARNAME in "aws_access_key_id" "aws_secret_access_key" "region"; do
    if [ -z $(aws configure get $VARNAME) ]; then
      echo "Please set up \"$VARNAME\" by running \"aws configure\" in your terminal."
      exit 1;
    fi
  done
}

eksClusterExists () {
  eksctl get cluster \
    --name "$KUBERNETES_CLUSTER_NAME" > /dev/null; \
    echo $?
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
    --query "SecurityGroups[0].GroupId" \
    --output text
}

getHostedZoneId () {
  local DOMAIN_NAME="$1"

  aws route53 list-hosted-zones-by-name \
    --dns-name "$DOMAIN_NAME" \
    --query "HostedZones[?Name=='$DOMAIN_NAME.'].Id" \
    --output text
}

getManagedCertArn () {
  local DOMAIN_NAME="$1"

  aws acm list-certificates \
    --query "CertificateSummaryList[?DomainName=='$DOMAIN_NAME'].CertificateArn" \
    --output text | cut -f1
}

getDNSRecord () {
  local HOSTED_ZONE_ID="$1"
  local DOMAIN_NAME="$2"

  aws route53 list-resource-record-sets \
    --hosted-zone-id "$HOSTED_ZONE_ID" \
    --query "ResourceRecordSets[?Name=='$DOMAIN_NAME.'].Name" \
    --output text
}

getDNSValidationName () {
  local CERT_ARN="$1"
  local DOMAIN_NAME="$2"

  aws acm describe-certificate \
    --certificate-arn "$CERT_ARN" \
    --query "Certificate.DomainValidationOptions[?DomainName=='$DOMAIN_NAME'].ResourceRecord.Name" \
    --output text
}

getDNSValidationValue () {
  local CERT_ARN="$1"
  local DOMAIN_NAME="$2"

  aws acm describe-certificate \
    --certificate-arn "$CERT_ARN" \
    --query "Certificate.DomainValidationOptions[?DomainName=='$DOMAIN_NAME'].ResourceRecord.Value" \
    --output text
}

getDbSubnetGroupArn () {
  local DB_SUBNET_GROUP_NAME="$1"

  aws rds describe-db-subnet-groups \
    --db-subnet-group-name "$DB_SUBNET_GROUP_NAME" \
    --query "DBSubnetGroups[*].DBSubnetGroupArn" \
    --output text
}

getDatabaseInstanceIdentifier () {
  aws rds describe-db-instances \
    --filters "Name=db-instance-id,Values=$DATABASE_INSTANCE_NAME" \
    --query 'DBInstances[*].[DBInstanceIdentifier]' \
    --output text
}

getKubernetesServiceExternalIP () {
  local SERVICE_NAME="$1"

  kubectl get svc "$SERVICE_NAME" -o json | \
    jq -r ".status.loadBalancer.ingress[].hostname"
}

getKubernetesIngressExternalIP () {
  local INGRESS_NAME="$1"

  kubectl get ingress "$INGRESS_NAME" -o json | \
    jq -r ".status.loadBalancer.ingress[].hostname"
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
