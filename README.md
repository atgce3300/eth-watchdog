# eth-watchdog

Network connectivity monitor and auto-recovery script for Android devices (Termux).

## Overview

eth-watchdog monitors your network connection and automatically attempts to recover connectivity when the network becomes unreachable. Designed for non-rooted Android devices running Termux.

## Features

- **Automatic Network Monitoring**: Checks gateway connectivity every 30 seconds
- **Multiple Recovery Methods**: Tries multiple approaches to restore network
- **Logging**: Records all activities to log file
- **Non-rooted Friendly**: Works without root access
- **Wake Lock**: Keeps device awake during monitoring

## The Problem

On Android devices, network connectivity can become stuck after the cable is unplugged and plugged back. The kernel detects the link, but Android doesn't recover properly. This script monitors and recovers from such situations.

## Installation

```bash
# Copy script to Termux
mkdir -p ~/scripts
cp eth-watchdog.sh ~/scripts/
chmod +x ~/scripts/eth-watchdog.sh
```

## Configuration

Edit the script to match your network:

```bash
GATEWAY="192.168.1.1"      # Your gateway IP
CHECK_INTERVAL=30            # Check every 30 seconds
MAX_RETRIES=3               # Maximum retry attempts
LOGFILE="${HOME}/eth-watchdog.log"
```

## Usage

### Start the watchdog

```bash
# Run in background
nohup ~/scripts/eth-watchdog.sh > ~/scripts/eth-watchdog.log 2>&1 &

# Or use termux-service
termux-service -s ~/scripts/eth-watchdog.sh
```

### Check if running

```bash
ps aux | grep eth-watchdog
```

### View logs

```bash
cat ~/scripts/eth-watchdog.log

# Or watch in real-time
tail -f ~/scripts/eth-watchdog.log
```

### Stop the watchdog

```bash
killall eth-watchdog.sh
```

## How It Works

1. **Ping Check**: Every 30 seconds, pings the gateway
2. **If Failed**:
   - Try flushing and renewing IP via DHCP
   - Open Android network settings (as workaround)
   - Try toggling WiFi scanning
3. **If Success**: Continue monitoring

## Recovery Methods

| Method | Description |
|--------|-------------|
| IP Flush | Down/up interface + DHCP renew |
| Settings Intent | Open Android network settings |
| WiFi Toggle | Enable/disable WiFi scanning |

## Non-Rooted Limitations

On non-rooted Android, direct network control is limited. This script uses workarounds:
- Opens network settings as a recovery trigger
- Attempts DHCP renewal via Termux
- Uses WiFi scanning toggle when applicable

## Troubleshooting

### Script not running
```bash
# Check if started
ps aux | grep eth-watchdog

# Start manually
~/scripts/eth-watchdog.sh
```

### No logs
```bash
# Check log file
cat ~/scripts/eth-watchdog.log

# Or use termux-logcat
termux-logcat | grep eth-watchdog
```

### Gateway unreachable
Change `GATEWAY` in script to your actual gateway IP:
```bash
GATEWAY="192.168.1.1"  # Change this
```

## Disclaimer

This script is a workaround for network issues on Android. It monitors connectivity and attempts recovery, but may not fix all network problems. For persistent issues, check your device's network hardware and Android settings.

## Author

Created for Termux users experiencing network connectivity issues on Android devices.
