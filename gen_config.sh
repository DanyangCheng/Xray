#!/bin/sh

set -e


CONFIG=/config.json


echo "[+] Generate UUID"

UUID=$(cat /proc/sys/kernel/random/uuid)


echo "[+] Generate REALITY key"

KEY_OUTPUT=$(xray x25519)


PRIVATE_KEY=$(echo "$KEY_OUTPUT" \
  | grep -E '^Private(Key)?' \
  | sed -E 's/^[^:]+:[[:space:]]*//')


PUBLIC_KEY=$(echo "$KEY_OUTPUT" \
  | grep -E 'PublicKey|\(PublicKey\)' \
  | sed -E 's/^[^:]+:[[:space:]]*//')

echo "[+] Generate short id"

SHORT_ID=$(openssl rand -hex 8)



DEST=${DEST:-www.cloudflare.com:443}

SERVER_NAME=${SERVER_NAME:-www.cloudflare.com:443}

export UUID
export PRIVATE_KEY
export PUBLIC_KEY
export SHORT_ID
export DEST
export SERVER_NAME

envsubst \
'${UUID} ${PRIVATE_KEY} ${PUBLIC_KEY} ${SHORT_ID} ${DEST} ${SERVER_NAME}' \
< /config.template \
> $CONFIG



echo ""
echo "========== SERVER INFO =========="
echo UUID:
echo $UUID

echo ""
echo Private Key:
echo $PRIVATE_KEY

echo ""
echo Public Key:
echo $PUBLIC_KEY

echo ""
echo Short ID:
echo $SHORT_ID


echo ""
echo "========== CLIENT URI =========="


echo \
"vless://${UUID}@YOUR_SERVER_IP:443?type=tcp&security=reality&pbk=${PUBLIC_KEY}&fp=chrome&sni=${SERVER_NAME}&sid=${SHORT_ID}&flow=xtls-rprx-vision" > /url.txt



# exec xray run -config $CONFIG