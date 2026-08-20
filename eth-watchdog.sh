#!/data/data/com.termux/files/usr/bin/bash
# eth-watchdog: Network connectivity monitor for Android (non-rooted)
# Monitors network and attempts recovery when connectivity is lost

# Configuration
GATEWAY="192.168.1.1"
CHECK_INTERVAL=30
MAX_RETRIES=3
LOGFILE="${HOME}/eth-watchdog.log"

# Keep device awake during monitoring
termux-wake-lock

echo "[$(date)] eth-watchdog started" | tee -a "$LOGFILE"

while true; do
    # Check if we can reach the gateway
    if ! ping -c 1 -W 5 "$GATEWAY" >/dev/null 2>&1; then
        echo "[$(date)] No connectivity to $GATEWAY" | tee -a "$LOGFILE"
        
        # Try to recover network
        echo "[$(date)] Attempting network recovery..." | tee -a "$LOGFILE"
        
        # Method 1: Flush and renew IP (works on some devices)
        for IFACE in $(ls /sys/class/net/ | grep -v '^lo$\|^bond'); do
            # Check if interface exists
            if [ -d "/sys/class/net/$IFACE" ]; then
                echo "[$(date)] Trying: flush $IFACE and restart DHCP" | tee -a "$LOGFILE"
                ip link set "$IFACE" down 2>/dev/null
                sleep 2
                ip link set "$IFACE" up 2>/dev/null
                sleep 3
                dhclient -r "$IFACE" 2>/dev/null
                dhclient "$IFACE" 2>/dev/null
            fi
        done
        
        # Method 2: Open network settings (non-rooted workaround)
        echo "[$(date)] Opening network settings..." | tee -a "$LOGFILE"
        am start -a android.settings.WIRELESS_SETTINGS 2>/dev/null || \
        am start -a android.settings.NETWORK_OPERATOR_SETTINGS 2>/dev/null || \
        am start -c android.intent.category.LAUNCHER -a android.intent.action.MAIN -n com.android.settings/.Settings\$NetworkSettingsActivity 2>/dev/null
        
        # Wait a bit after opening settings
        sleep 5
        
        # Method 3: Try to restart WiFi (if available)
        echo "[$(date)] Trying WiFi toggle..." | tee -a "$LOGFILE"
        wifi-scan-disable 2>/dev/null
        sleep 2
        wifi-scan-enable 2>/dev/null
        
        # Check if recovery worked
        sleep 10
        if ping -c 1 -W 5 "$GATEWAY" >/dev/null 2>&1; then
            echo "[$(date)] Network recovered! ✓" | tee -a "$LOGFILE"
        else
            echo "[$(date)] Network recovery failed 😞" | tee -a "$LOGFILE"
        fi
    else
        echo "[$(date)] Network OK ✓" | tee -a "$LOGFILE"
    fi
    
    # Wait before next check
    sleep "$CHECK_INTERVAL"
done
