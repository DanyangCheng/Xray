FROM ghcr.io/xtls/xray-core:26.3.27@sha256:592ec4d11f656db95598d01e76dbcc6e002d67360b96a5436500a938230f52c7 AS xray-source

FROM alpine:3.22.1@sha256:4bcff63911fcb4448bd4fdacec207030997caf25e9bea4045fa6c8c44de311d1

RUN mkdir -p /etc/xray /usr/share/xray

COPY --from=xray-source /usr/local/bin/xray /usr/local/bin/xray
COPY --from=xray-source /usr/local/share/xray/ /usr/share/xray/
COPY config.json.template /config.json.template
COPY gen_config.sh /gen_config.sh
COPY entrypoint.sh /entrypoint.sh

RUN chmod 0755 /gen_config.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
