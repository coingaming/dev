#!/bin/bash

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"

. "$THIS_DIR/utilities.sh"
. "$THIS_DIR/aws-utilities.sh"

deleteKubernetesCluster () {
  # DB and DBsubnetGroup must be deleted prior to cluster deletion otherwise eksctl will fail to cleanly delete the cluster
  deleteDbInstance
  createDbSubnetGroup "$KUBERNETES_CLUSTER_NAME"

  echo "Deleting \"$KUBERNETES_CLUSTER_NAME\" k8s cluster from AWS [EKS]..."
  eksctl delete cluster "$KUBERNETES_CLUSTER_NAME" --wait
}

deleteHostedZone () {
  echo "Deleting \"$DOMAIN_NAME\" hosted zone from AWS [R53]..."
  aws route53 delete-hosted-zone "$DOMAIN_NAME" --wait
}

# Cluster must be deleted before managed cert
deleteManagedCert () {
  local CERT_ARN="$1"

  echo "Deleting \"$CERT_ARN\" certificate from AWS [ACM]..."
  aws acm delete-certificate \
    --certificate-arn "$CERT_ARN"
}

deleteDbSubnetGroup () {
  local SUBNET_GROUP_NAME="$1"

  echo "Deleting \"$SUBNET_GROUP_NAME\" database subnet group from AWS [RDS]..."
  aws rds delete-db-subnet-group \
    --db-subnet-group-name "$SUBNET_GROUP_NAME"
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

echo "==> Starting to teardown lsp $BITCOIN_NETWORK on $CLOUD_PROVIDER."

# Delete everything in order!

echo "==> Teardown of lsp $BITCOIN_NETWORK on $CLOUD_PROVIDER has been completed!"
