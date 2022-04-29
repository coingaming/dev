#!/bin/bash
# shellcheck disable=SC2155

set -e

export BITCOIN_NETWORK="testnet"
export CLOUD_PROVIDER="aws"
export KUBERNETES_CLUSTER_NAME="lsp-$BITCOIN_NETWORK"
export DATABASE_INSTANCE_NAME="$KUBERNETES_CLUSTER_NAME"

isAwsConfigured () {
  for VARNAME in "aws_access_key_id" "aws_secret_access_key" "region"; do
    if [ -z "$(aws configure get $VARNAME)" ]; then
      echo "Please set up \"$VARNAME\" by running \"aws configure\" in your terminal."
      exit 1;
    fi
  done
}

disableAwsCliPager () {
  aws configure set cli_pager ""
}

clusterExists () {
  aws eks list-clusters | jq -r '.clusters | contains(["'$KUBERNETES_CLUSTER_NAME'"])'
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

getCertArn () {
  local DOMAIN_NAME="$1"

  aws acm list-certificates \
    --query "CertificateSummaryList[?DomainName=='$DOMAIN_NAME'].CertificateArn" \
    --output text | cut -f1
}

getDNSRecordsByType () {
  local HOSTED_ZONE_ID="$1"
  local RECORD_TYPE="$2"

  aws route53 list-resource-record-sets \
    --hosted-zone-id "$HOSTED_ZONE_ID" \
    --query "ResourceRecordSets[?Type=='$RECORD_TYPE']"
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

changeDNSRecord () {
  local HOSTED_ZONE_ID="$1"
  local ACTION="$2"
  local RECORD_NAME="$3"
  local RECORD_VALUE="$4"
  local RECORD_TYPE="${5:-CNAME}"
  local RECORD_TTL="${6:-300}"
  local CHANGE_BATCH=$(cat <<EOM
    {
      "Changes": [
        {
          "Action": "${ACTION}",
          "ResourceRecordSet": {
            "Name": "${RECORD_NAME}",
            "Type": "${RECORD_TYPE}",
            "TTL": ${RECORD_TTL},
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
    --hosted-zone-id "$HOSTED_ZONE_ID" \
    --change-batch "$CHANGE_BATCH" \
    --query "ChangeInfo.Id" \
    --output text)

  echo "Waiting until changes to dns records are applied in Route53..."
  aws route53 wait resource-record-sets-changed \
    --id "$CHANGE_BATCH_REQUEST_ID"
}

getDbSubnetGroupArn () {
  local DB_SUBNET_GROUP_NAME="$1"

  aws rds describe-db-subnet-groups \
    --db-subnet-group-name "$DB_SUBNET_GROUP_NAME" \
    --query "DBSubnetGroups[*].DBSubnetGroupArn" \
    --output text
}

getDbInstanceIdentifier () {
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
    jq -r '.[] | select(.[1] == "'"$VPC_ID"'")' | \
    jq -s | \
    jq -r '.[] | select(.[0] | contains("'"$SERVICE"'")) | .[0]'
}

getElbListenerArn () {
  local ELB_ARN="$1"
  local LISTENER_PORT="$2"

  aws elbv2 describe-listeners \
    --load-balancer-arn "$ELB_ARN" \
    --query 'Listeners[*].[ListenerArn, Port]' \
    --output json | \
    jq -r '.[] | select(.[1] == '"$LISTENER_PORT"') | .[0]'
}

getPolicyArn () {
  local POLICY_NAME="$1"

  aws iam list-policies \
    --scope Local \
    --query "Policies[?PolicyName=='"$POLICY_NAME"'].Arn" \
    --output text
}
