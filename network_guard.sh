#!/data/data/com.termux/files/usr/bin/bash
# ========================================
# Smart Network Guard - Main Toggle Script
# Non-Root, Termux:Widget
# ========================================

PID=$(pgrep -f smart_network_guard_info_daemon.sh)

if [ -z "$PID" ]; then
    # Pilih prioritas koneksi via dialog
    PRIORITY=$(termux-dialog radio --title "Pilih prioritas koneksi" --items "Wi-Fi,SIM1,SIM2" | jq -r '.text')
    [ -z "$PRIORITY" ] && PRIORITY="wifi"
    termux-toast "Smart Guard started, priority: $PRIORITY"

    # Jalankan daemon di background
    nohup bash ~/.shortcuts/smart_network_guard_info_daemon.sh "$PRIORITY" >/dev/null 2>&1 &
else
    # Stop daemon
    kill $PID
    termux-toast "Smart Network Guard stopped!"
fi
