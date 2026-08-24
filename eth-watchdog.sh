#!/data/data/com.termux/files/usr/bin/bash
# Watchdog: restarts ethernet if network is unreachable

GATEWAY="192.168.1.1"
CHECK_INTERVAL=30
while true; do
  if ! ping -c 1 -W 5 "$GATEWAY" > /dev/null 2>&1; then
    echo "[$(date)] No connectivity, restarting ethernet..."
    svc ethernet disable
    sleep 2
    svc ethernet enable
  fi
  sleep "$CHECK_INTERVAL"
done
