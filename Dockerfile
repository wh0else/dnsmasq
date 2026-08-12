FROM alpine:3.24

# dnsmasq          - DNS/DHCP server
# ca-certificates  - trust store
# tzdata           - so TZ env var actually does something
# tini             - proper PID 1 / signal handling & zombie reaping
# bash             - entrypoint.sh uses bash features
RUN apk --no-cache add \
        dnsmasq \
        ca-certificates \
        tzdata \
        tini \
        bash; \
    rm -rf /tmp/* /var/cache/apk/*

COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

EXPOSE 53/tcp 53/udp 67/udp

# Confirms dnsmasq is actually answering queries, not just that the process exists.
# "localhost" resolves locally without hitting upstream forwarders, so this stays
# fast even if your internet uplink is down.
HEALTHCHECK --interval=30s --timeout=5s --retries=3 --start-period=10s \
    CMD nslookup -timeout=2 localhost 127.0.0.1 >/dev/null 2>&1 || exit 1

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]