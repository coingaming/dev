#!/bin/bash

set -e

BITCOIN_NETWORK="testnet"
CLOUD_PROVIDER="aws"
KUBERNETES_CLUSTER_NAME="lsp-$BITCOIN_NETWORK"
DATABASE_INSTANCE_NAME="$KUBERNETES_CLUSTER_NAME"
DATABASE_USERNAME="lsp"
IDEMPOTENCY_TOKEN=$(date +%F | md5 | cut -c1-5)

isAwsConfigured () {
  for VARNAME in "aws_access_key_id" "aws_secret_access_key" "region"; do
    if [ -z $(aws configure get $VARNAME) ]; then
      echo "Please set up \"$VARNAME\" by running \"aws configure\" in your terminal."
      exit 1;
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

getHostedZoneId () {
  local DOMAIN_NAME="$1"

  aws route53 list-hosted-zones-by-name \
    --dns-name "$DOMAIN_NAME" \
    --query "HostedZones[?Name=='$DOMAIN_NAME.'].Id" \
    --output text
}

getManagedCertArn () {
  local SERVICE_DOMAIN_NAME="$1"

  aws acm list-certificates \
    --query "CertificateSummaryList[?DomainName=='$SERVICE_DOMAIN_NAME'].CertificateArn" \
    --output text | cut -f1
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
