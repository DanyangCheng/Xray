#!/bin/sh

set -eu

CONFIG_DIR=/etc/xray
CONFIG_FILE=${CONFIG_DIR}/config.json

mkdir -p "$CONFIG_DIR"

if [ ! -f "$CONFIG_FILE" ]; then
    CONFIG="$CONFIG_FILE" \
    CONFIG_TEMPLATE=/config.json.template \
    URL_FILE="${CONFIG_DIR}/url.txt" \
    /gen_config.sh
fi

if grep -Eq '"target"[[:space:]]*:[[:space:]]*"www\.cloudflare\.com:443"' "$CONFIG_FILE"; then
    echo "[!] Refusing the unsafe default REALITY target www.cloudflare.com:443." >&2
    echo "[!] Remove config/config.json and set TARGET and SERVER_NAME to a suitable target in .env." >&2
    exit 1
fi

xray run -test -config "$CONFIG_FILE"
exec xray run -config "$CONFIG_FILE"
