#!/usr/bin/env bash
set -euo pipefail

# --- Timezone --------------------------------------------------------------
if [ -n "${TZ:-}" ] && [ -f "/usr/share/zoneinfo/${TZ}" ]; then
    ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime
    echo "$TZ" > /etc/timezone
fi

# Your dnsmasq.conf (and anything it pulls in via conf-dir) is bind-mounted
# straight into the container, so there's nothing to template or default here -
# just hand off to dnsmasq in the foreground so tini can supervise it.
exec dnsmasq --no-daemon --conf-file=/etc/dnsmasq.conf