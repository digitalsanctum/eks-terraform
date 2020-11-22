#!/usr/bin/env bash

# references:
# https://github.com/terraform-providers/terraform-provider-aws/issues/10104
# https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc_verify-thumbprint.html

set -e

REGION="$1"

if [ -z "$REGION" ]; then
  echo "Must provide region"
  exit 1
fi

CERTS=$(echo | openssl s_client -servername oidc.eks.${REGION}.amazonaws.com -showcerts -connect oidc.eks.${REGION}.amazonaws.com:443 2>/dev/null > certs)
cat certs | sed -n '/BEGIN CERTIFICATE/,/END CERTIFICATE/H;$!d;g;s/.*\(-----BEGIN\)/\1/p' > last_cert
THUMBPRINT=$(cat last_cert | openssl x509 -fingerprint -noout | sed 's/://g' | awk -F= '{print tolower($2)}')
THUMBPRINT_JSON="{\"thumbprint\": \"${THUMBPRINT}\"}"
echo $THUMBPRINT_JSON
