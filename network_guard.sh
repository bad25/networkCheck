#!/data/data/com.termux/files/usr/bin/bash

PID=$(pgrep -f smart_network_guard_info_daemon.sh)
if [ -z "$PID" ]; then
    PRIORITY=$(termux-dialog radio --title "Pilih prioritas koneksi" --items "Wi-Fi,SIM1,SIM2" | jq -r '.text')
    [ -z "$PRIORITY" ] && PRIORITY="wifi"
    termux-toast "Smart Guard started, priority: $PRIORITY"

    nohup bash ~/.shortcuts/smart_network_guard_info_daemon.sh "$PRIORITY" >/dev/null 2>&1 &
else
    kill $PID
    termux-toast "Smart Network Guard stopped!"
fi
