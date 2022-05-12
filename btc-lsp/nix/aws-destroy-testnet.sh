#!/bin/bash
# shellcheck disable=SC2155

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"

. "$THIS_DIR/utilities.sh"
. "$THIS_DIR/aws-utilities.sh"
. "$THIS_DIR/cloudflare-utilities.sh"

deleteDbSubnetGroup () {
  local DB_SUBNET_GROUP_ARN=$(getDbSubnetGroupArn "$KUBERNETES_CLUSTER_NAME")

  if [ -z "$DB_SUBNET_GROUP_ARN" ]; then
    echo "==> Database subnet group for \"$DATABASE_INSTANCE_NAME\" does not exist."
  else
    echo "==> Deleting \"$KUBERNETES_CLUSTER_NAME\" database subnet group from AWS [RDS]..."
    aws rds delete-db-subnet-group --db-subnet-group-name "$KUBERNETES_CLUSTER_NAME" 1>/dev/null
  fi
}

deleteDbInstance () {
  local DATABASE_INSTANCE_IDENTIFIER=$(getDbInstanceIdentifier)

  if [ -z "$DATABASE_INSTANCE_IDENTIFIER" ]; then
    echo "==> Database instance for \"$DATABASE_INSTANCE_NAME\" does not exist."
  else
    echo "==> Deleting \"$DATABASE_INSTANCE_NAME\" database instance from AWS [RDS]..."
    aws rds delete-db-instance \
        --db-instance-identifier "$DATABASE_INSTANCE_NAME" \
        --skip-final-snapshot \
        --delete-automated-backups 1>/dev/null

    echo "Waiting until \"$DATABASE_INSTANCE_NAME\" database instance is fully deleted..."
    aws rds wait db-instance-deleted --db-instance-identifier="$DATABASE_INSTANCE_NAME"
  fi
}

deleteDelegatedCloudflareDomain () {
  local DOMAIN_NAME="$1"
  local NS_RECORDS="$2"

  setCloudflareCreds

  local CLOUDFLARE_HOSTED_ZONE_ID=$(getCloudflareHostedZoneId)

  for NS_RECORD in $NS_RECORDS; do
    local FORMATTED_NS_RECORD=${NS_RECORD%.}
    local DNS_RECORD_ID=$(getCloudflareDNSRecordId "$CLOUDFLARE_HOSTED_ZONE_ID" "$DOMAIN_NAME" "$FORMATTED_NS_RECORD")

    if [ -z "$DNS_RECORD_ID" ]; then
      echo "==> NS record \"$FORMATTED_NS_RECORD\" for \"$DOMAIN_NAME\" does not exist."
    else
      echo "==> Deleting \"$FORMATTED_NS_RECORD\" NS record for \"$DOMAIN_NAME\" from Cloudflare."
      deleteCloudflareDNSRecord "$CLOUDFLARE_HOSTED_ZONE_ID" "$DNS_RECORD_ID" 1>/dev/null
    fi
  done
}

deleteDelegatedDomain () {
  local HOSTED_ZONE_ID=$(getHostedZoneId "$DOMAIN_NAME")
  local NS_RECORDS=$(getDNSRecordsByType "$HOSTED_ZONE_ID" "NS" | jq -r -c '.[].ResourceRecords[].Value')

  echo "==> If your DNS provider for \"$DOMAIN_NAME\" is not Route53, you must remove the delegated access before continuing..."

  case "$DNS_PROVIDER" in
    "cloudflare")
      deleteDelegatedCloudflareDomain "$DOMAIN_NAME" "$NS_RECORDS";;
    *)
      echo "==> DNS provider \"$DNS_PROVIDER\" is not supported. Please remove NS records for \"$DOMAIN_NAME\" by yourself.";;
  esac
}

deleteDNSRecords () {
  local HOSTED_ZONE_ID=$(getHostedZoneId "$DOMAIN_NAME")

  if [ -z "$HOSTED_ZONE_ID" ]; then
    echo "==> Hosted zone for \"$DOMAIN_NAME\" does not exist."
  else
    local CNAME_RECORDS=$(getDNSRecordsByType "$HOSTED_ZONE_ID" "CNAME")

    for CNAME_RECORD in $(echo "$CNAME_RECORDS" | jq -r -c '.[]'); do
      local RECORD_NAME=$(echo "$CNAME_RECORD" | jq -r '.Name')
      local RECORD_VALUE=$(echo "$CNAME_RECORD" | jq -r '.ResourceRecords[].Value')

      echo "==> Deleting $RECORD_NAME CNAME record from AWS [R53]..."
      changeDNSRecord "$HOSTED_ZONE_ID" "DELETE" "$RECORD_NAME" "$RECORD_VALUE"
    done
  fi
}

deleteHostedZone () {
  local HOSTED_ZONE_ID=$(getHostedZoneId "$DOMAIN_NAME")

  if [ -z "$HOSTED_ZONE_ID" ]; then
    echo "==> Hosted zone for \"$DOMAIN_NAME\" does not exist."
  else
    echo "==> Deleting \"$DOMAIN_NAME\" hosted zone from AWS [R53]..."
    aws route53 delete-hosted-zone --id "$HOSTED_ZONE_ID" 1>/dev/null
  fi
}

# eksctl leaves dangling Application Load Balancer and because of this CloudFormation fails to delete the stack
deleteLoadBalancer () {
  if kubectl get ingress rtl; then 
    echo "==> Deleting ingress resource from AWS [EKS]..."
    kubectl delete ingress rtl
  else
    echo "==> Ingress for RTL does not exist."
  fi
}

deleteCluster () {
  if "$(clusterExists)"; then
    echo "==> Deleting \"$KUBERNETES_CLUSTER_NAME\" k8s cluster from AWS [EKS]..."
    eksctl delete cluster "$KUBERNETES_CLUSTER_NAME" --wait
  else
    echo "==> Cluster \"$KUBERNETES_CLUSTER_NAME\" does not exist."
  fi
}

deletePolicy () {
  local POLICY_NAME="AWSLoadBalancerControllerIAMPolicy"
  local POLICY_ARN=$(getPolicyArn "$POLICY_NAME")

  if [ -z "$POLICY_ARN" ]; then
    echo "==> Policy \"$POLICY_NAME\" does not exist."
  else
    echo "==> Deleting \"$POLICY_NAME\" from AWS [IAM]..."
    aws iam delete-policy --policy-arn "$POLICY_ARN"
  fi
}

deleteVolumes () {
  local EBS_VOLUME_IDS=$(aws ec2 describe-volumes \
    --filters "Name=tag-key,Values=kubernetes.io/cluster/$KUBERNETES_CLUSTER_NAME" \
    --query 'Volumes[].VolumeId' --output text)
  
  for EBS_VOLUME_ID in $EBS_VOLUME_IDS; do
    echo "==> Deleting \"$EBS_VOLUME_ID\" volume from AWS [EBS]..."
    aws ec2 delete-volume --volume-id "$EBS_VOLUME_ID"
  done
}

deleteCerts () {
  for SERVICE in rtl lsp; do
    local SERVICE_DOMAIN_NAME=$(cat "$SECRETS_DIR/$SERVICE/domainname.txt")
    local CERT_ARN=$(getCertArn "$SERVICE_DOMAIN_NAME")
     
    if [ -z "$CERT_ARN" ]; then
      echo "==> Certificate for \"$SERVICE_DOMAIN_NAME\" does not exist."
    else
      echo "==> Deleting \"$CERT_ARN\" certificate from AWS [ACM]..."
      aws acm delete-certificate --certificate-arn "$CERT_ARN"
    fi
  done
}

echo "==> Starting to teardown \"$KUBERNETES_CLUSTER_NAME\" on $CLOUD_PROVIDER."

deleteDbInstance && \
deleteDbSubnetGroup && \
setDomainName && \
setDNSProvider && \
deleteDelegatedDomain && \
deleteDNSRecords && \
deleteHostedZone && \
deleteLoadBalancer && \
deleteCluster && \
deletePolicy && \
deleteVolumes && \
deleteCerts

echo "==> Finished removing \"$KUBERNETES_CLUSTER_NAME\" from $CLOUD_PROVIDER!"
