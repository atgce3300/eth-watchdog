# eth-watchdog

It is a watchdog script to monitor your Ethernet link

while true; do
  if ! ping -c 1 192.168.1.1 > /dev/null 2>&1; then
    # No connectivity, try restarting the Ethernet service
    svc ethernet disable && sleep 2 && svc ethernet enable
  fi
  sleep 30
done

How it works:
Runs continuously in the background
Every N seconds, it checks if the network is actually working (ping the gateway)
If the check fails, it restarts the Ethernet service, which forces Android to re-run DHCP and recover
Then it goes back to monitoring

For your situation specifically, since we know the link comes back up at the kernel level but Android gets stuck, the trigger could be:
A ping check (internet actually unreachable)
Watching cat /sys/class/net/eth0/operstate for unexpected state changes
Monitoring carrier_changes to detect link flapping

Downside: It's a hack that papercuts the symptom rather than fixing the root cause. It also means your device is running a background script constantly.

Here are the steps to set it up manually in Termux:

Create the script

mkdir -p ~/scripts
nano ~/scripts/eth-watchdog.sh


Paste this in:
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


Save and exit (Ctrl+X, then Y, then Enter).

Make it executable

bash
chmod +x ~/scripts/eth-watchdog.sh


Run it in the background

nohup ~/scripts/eth-watchdog.sh > ~/scripts/eth-watchdog.log 2>&1 &


Check it's running

ps aux | grep eth-watchdog


To stop it:
bash
killall eth-watchdog.sh


To see the log:
cat ~/scripts/eth-watchdog.log


That's it. It just runs in the background and checks every 30 seconds. Swap 192.168.1.1 for your actual gateway IP if it's different.
x
