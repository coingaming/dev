#!/bin/bash
# shellcheck disable=SC2155

set -e

setCloudflareCreds () {
  read -r -p "Please input your Cloudflare domain: " "CLOUDFLARE_DOMAIN_NAME"
  read -r -s -p "Please input your Cloudflare API key: " "CLOUDFLARE_API_KEY"
  read -r -p "Please input your Cloudflare email: " "CLOUDFLARE_EMAIL"
}

getCloudflareHostedZoneId () {
  curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$CLOUDFLARE_DOMAIN_NAME" \
    -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
    -H "X-Auth-Key: $CLOUDFLARE_API_KEY" \
    -H "Content-Type: application/json" | jq -r '.result[].id'
}

getCloudflareDNSRecordId () {
  local CLOUDFLARE_HOSTED_ZONE_ID="$1"
  local DOMAIN_NAME="$2"
  local RECORD_VALUE="$3"
  local RECORD_TYPE="${4:-NS}"

  curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_HOSTED_ZONE_ID/dns_records?type=$RECORD_TYPE&content=$RECORD_VALUE&name=$DOMAIN_NAME" \
    -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
    -H "X-Auth-Key: $CLOUDFLARE_API_KEY" \
    -H "Content-Type: application/json" | jq -r '.result[].id'
}

createCloudflareDNSRecord () {
  local CLOUDFLARE_HOSTED_ZONE_ID="$1"
  local RECORD_NAME="$2"
  local RECORD_VALUE="$3"
  local RECORD_TYPE="${4:-NS}"

  curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_HOSTED_ZONE_ID/dns_records" \
    -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
    -H "X-Auth-Key: $CLOUDFLARE_API_KEY" \
    -H "Content-Type: application/json" \
    --data '{"type":"'"$RECORD_TYPE"'","name":"'"$RECORD_NAME"'","content":"'"$RECORD_VALUE"'","ttl":300,"priority":10,"proxied":false}'
}

deleteCloudflareDNSRecord () {
  local CLOUDFLARE_ZONE_ID="$1"
  local CLOUDFLARE_DNS_RECORD_ID="$2"

  curl -s -X DELETE "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records/$CLOUDFLARE_DNS_RECORD_ID" \
    -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
    -H "X-Auth-Key: $CLOUDFLARE_API_KEY" \
    -H "Content-Type: application/json"
}
