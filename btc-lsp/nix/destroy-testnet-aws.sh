#!/bin/bash

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"

. "$THIS_DIR/utilities.sh"
. "$THIS_DIR/aws-utilities.sh"

deleteDbSubnetGroup () {
  local DB_SUBNET_GROUP_ARN=$(getDbSubnetGroupArn "$KUBERNETES_CLUSTER_NAME")

  if [ -z "$DB_SUBNET_GROUP_ARN" ]; then
    echo "==> Database subnet group for \"$DATABASE_INSTANCE_NAME\" does not exist."
  else
    echo "==> Deleting \"$KUBERNETES_CLUSTER_NAME\" database subnet group from AWS [RDS]..."
    aws rds delete-db-subnet-group \
      --db-subnet-group-name "$KUBERNETES_CLUSTER_NAME"
  fi
}

deleteDbInstance () {
  local DATABASE_INSTANCE_IDENTIFIER=$(getDatabaseInstanceIdentifier)

  if [ -z "$DATABASE_INSTANCE_IDENTIFIER" ]; then
    echo "==> Database instance for \"$DATABASE_INSTANCE_NAME\" does not exist."
  else
    echo "==> Deleting \"$DATABASE_INSTANCE_NAME\" database instance from AWS [RDS]..."
    aws rds delete-db-instance \
        --db-instance-identifier "$DATABASE_INSTANCE_NAME" \
        --skip-final-snapshot \
        --delete-automated-backups

    echo "Waiting until \"$DATABASE_INSTANCE_NAME\" database instance is fully deleted..."
    aws rds wait db-instance-deleted \
        --db-instance-identifier="$DATABASE_INSTANCE_NAME"
  fi
}

deleteHostedZone () {
  local HOSTED_ZONE_ID=$(getHostedZoneId "$DOMAIN_NAME")

  if [ -z "$HOSTED_ZONE_ID" ]; then
    echo "==> Hosted zone for \"$DOMAIN_NAME\" does not exist."
  else
    echo "==> Deleting \"$DOMAIN_NAME\" hosted zone from AWS [R53]..."
    aws route53 delete-hosted-zone "$DOMAIN_NAME" --wait
  fi
}

deleteKubernetesCluster () {
  if [ $(eksClusterExists) ]; then
    echo "==> Deleting \"$KUBERNETES_CLUSTER_NAME\" k8s cluster from AWS [EKS]..."
    eksctl delete cluster "$KUBERNETES_CLUSTER_NAME" --wait
  else
    echo "==> Cluster \"$KUBERNETES_CLUSTER_NAME\" does not exist."
  fi
}

deleteEbsVolumes () {
  local EBS_VOLUME_IDS=$(aws ec2 describe-volumes \
    --filters "Name=tag-key,Values=kubernetes.io/cluster/$KUBERNETES_CLUSTER_NAME" \
    --query 'Volumes[].VolumeId' --output text)
  
  for EBS_VOLUME_ID in $EBS_VOLUME_IDS; do
    echo "==> Deleting \"$EBS_VOLUME_ID\" volume from AWS [EBS]..."
    aws ec2 delete-volume --volume-id "$EBS_VOLUME_ID"
  done
}

deleteManagedCerts () {
  for SERVICE in rtl lsp; do
    local SERVICE_DOMAIN_NAME=$(cat "$SECRETS_DIR/$SERVICE/domainname.txt")
    local CERT_ARN=$(getManagedCertArn "$SERVICE_DOMAIN_NAME")
     
    if [ -z "$CERT_ARN" ]; then
      echo "==> Certificate for \"$SERVICE_DOMAIN_NAME\" does not exist."
    else
      echo "==> Deleting \"$CERT_ARN\" certificate from AWS [ACM]..."
      aws acm delete-certificate \
        --certificate-arn "$CERT_ARN"
    fi
  done
}

echo "==> Starting to destroy lsp $BITCOIN_NETWORK on $CLOUD_PROVIDER."

deleteDbSubnetGroup && \
deleteDbInstance && \
setDomainName && \
deleteHostedZone && \
deleteKubernetesCluster && \
deleteEbsVolumes && \
deleteManagedCerts

echo "==> Finished destroying lsp $BITCOIN_NETWORK on $CLOUD_PROVIDER!"
