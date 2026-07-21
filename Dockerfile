FROM alpine:latest AS xray-install

COPY xray.sh /xray.sh
RUN set -ex \
&& chmod +x /xray.sh \
&& /xray.sh \
&& rm -fv /xray.sh \
&& wget -O /geosite.dat https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat \
&& wget -O /geoip.dat https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat

RUN apk add --no-cache \
openssl \
gettext
COPY config.json.template config.template
COPY gen_config.sh /gen_config.sh

RUN chmod +x /gen_config.sh
RUN ./gen_config.sh

FROM alpine:latest AS xray-run

RUN apk add --no-cache \
    openssl \
    gettext \
&& mkdir -p /var/log/xray /usr/share/xray 

COPY --from=xray-install /usr/local/bin/xray /usr/local/bin/xray
COPY --from=xray-install /geosite.dat /usr/share/xray/geosite.dat
COPY --from=xray-install /geoip.dat /usr/share/xray/geoip.dat
COPY --from=xray-install /config.json /config.json
COPY --from=xray-install /url.txt /url.txt
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]