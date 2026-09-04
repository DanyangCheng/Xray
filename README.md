# Xray VLESS + XTLS Vision + REALITY

## Deploy

1. Copy `.env.example` to `.env`.
2. Set `TARGET`, `SERVER_NAME`, and `SERVER_ADDRESS` in `.env`.
3. Check the target before deployment:

   ```sh
   docker run --rm ghcr.io/xtls/xray-core:26.3.27 tls ping example.com
   ```

   Prefer a TLS 1.3 site in the same ASN as the server. Do not use a public CDN
   such as Cloudflare as the target: unauthenticated REALITY traffic is forwarded
   to the target and can turn the server into an unwanted CDN relay.

4. Start the service:

   ```sh
   docker compose up -d --build
   ```

The first start creates `config/config.json` and `config/url.txt`. Both files are
created with mode `0600`. The private key is never printed to the build or runtime
logs. Import `config/url.txt` into a compatible client.

To deliberately rotate all credentials, stop the service, securely back up and
remove the `config` directory, then start it again. Removing this directory makes
all previously issued client URIs invalid.

## Existing installations

This version refuses to start if an existing generated configuration still uses
`www.cloudflare.com:443`. Choose a suitable target, remove the old generated
configuration, and start the service to generate new credentials.
