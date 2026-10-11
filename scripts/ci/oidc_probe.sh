#!/usr/bin/env bash
# Read-only: exchange the GitHub OIDC token with npm and report the identity.
set -uo pipefail

label="$1"
token=$(curl -sS -H "Authorization: bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" \
  "${ACTIONS_ID_TOKEN_REQUEST_URL}&audience=registry.npmjs.org" \
  | python3 -c "import sys,json;print(json.load(sys.stdin)['value'])")

payload=$(printf '%s' "$token" | cut -d. -f2)
payload+=$(( 4 - ${#payload} % 4 ))
sub=$(printf '%s' "$payload" | tr '_-' '/+' | base64 -d 2>/dev/null \
  | python3 -c "import sys,json;print(json.load(sys.stdin).get('sub'))")

echo "=== $label ==="
echo "sub: $sub"
status=$(curl -sS -o /tmp/whoami.txt -w '%{http_code}' \
  -H "Authorization: Bearer $token" https://registry.npmjs.org/-/whoami)
echo "whoami http_status: $status"
echo "whoami body: $(cat /tmp/whoami.txt)"
