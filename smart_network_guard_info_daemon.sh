#!/data/data/com.termux/files/usr/bin/bash

PRIORITY_VAR="$1"
DNS1=8.8.8.8
DNS2=1.1.1.1
HOST=google.com
LOGFILE=/sdcard/network_log.txt
DELAY=5
WIFI_SSID="Siantar Lt 2"

WIFI_FAIL=0; SIM1_FAIL=0; SIM2_FAIL=0; MAX_FAIL=3

check_connection() { ... }  # isi sama seperti sebelumnya
get_wifi_info() { ... }     # isi sama seperti sebelumnya

while true; do
    # monitoring loop, semua echo dan termux-toast seperti sebelumnya
    sleep $DELAY
done
