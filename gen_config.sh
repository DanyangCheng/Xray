#!/bin/sh

set -eu
umask 077

CONFIG=${CONFIG:-/etc/xray/config.json}
CONFIG_TEMPLATE=${CONFIG_TEMPLATE:-/config.json.template}
URL_FILE=${URL_FILE:-/etc/xray/url.txt}

: "${TARGET:?TARGET is required, for example example.com:443}"
: "${SERVER_NAME:?SERVER_NAME is required, for example example.com}"
: "${SERVER_ADDRESS:?SERVER_ADDRESS is required, for example 203.0.113.10}"

if [ "$TARGET" = "www.cloudflare.com:443" ]; then
    echo "[!] TARGET=www.cloudflare.com:443 is unsafe for REALITY and is not allowed." >&2
    exit 1
fi

UUID=$(xray uuid)
KEY_OUTPUT=$(xray x25519)

PRIVATE_KEY=$(printf '%s\n' "$KEY_OUTPUT" | awk -F ': *' \
    '/^PrivateKey:|^Private key:/ { print $2; exit }')
PUBLIC_KEY=$(printf '%s\n' "$KEY_OUTPUT" | awk -F ': *' \
    '/^PublicKey:|^Public key:|^Password:|^Password \(PublicKey\):/ { print $2; exit }')
SHORT_ID=$(od -An -N8 -tx1 /dev/urandom | tr -d ' \n')

if [ -z "$UUID" ] || [ -z "$PRIVATE_KEY" ] || [ -z "$PUBLIC_KEY" ] || [ -z "$SHORT_ID" ]; then
    echo "[!] Failed to generate Xray credentials." >&2
    exit 1
fi

CONFIG_TMP=${CONFIG}.tmp
sed \
    -e "s|\${UUID}|${UUID}|g" \
    -e "s|\${PRIVATE_KEY}|${PRIVATE_KEY}|g" \
    -e "s|\${SHORT_ID}|${SHORT_ID}|g" \
    -e "s|\${TARGET}|${TARGET}|g" \
    -e "s|\${SERVER_NAME}|${SERVER_NAME}|g" \
    "$CONFIG_TEMPLATE" > "$CONFIG_TMP"
mv "$CONFIG_TMP" "$CONFIG"

printf '%s\n' \
    "vless://${UUID}@${SERVER_ADDRESS}:443?type=tcp&security=reality&pbk=${PUBLIC_KEY}&fp=chrome&sni=${SERVER_NAME}&sid=${SHORT_ID}&flow=xtls-rprx-vision" \
    > "$URL_FILE"

chmod 0600 "$CONFIG" "$URL_FILE"
echo "[+] Generated Xray configuration and client URI in /etc/xray."
unset KEY_OUTPUT PRIVATE_KEY
