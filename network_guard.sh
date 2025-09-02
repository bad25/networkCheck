#!/data/data/com.termux/files/usr/bin/bash

# ========================================
# Smart Network Guard - Informative (Non-Root)
# Toggle via Termux:Widget
# ========================================

# Cek apakah daemon sudah berjalan
PID=$(pgrep -f smart_network_guard_info_daemon.sh)
if [ -z "$PID" ]; then
    # Script belum jalan, jalankan daemon

    # Pilih prioritas koneksi via dialog
    PRIORITY=$(termux-dialog radio --title "Pilih prioritas koneksi" --items "Wi-Fi,SIM1,SIM2" | jq -r '.text')
    if [ -z "$PRIORITY" ]; then
        PRIORITY="wifi"
    fi
    termux-toast "Smart Guard started, priority: $PRIORITY"

    # Jalankan daemon di background
    nohup bash -c '
    DNS1=8.8.8.8
    DNS2=1.1.1.1
    HOST=google.com
    LOGFILE=/sdcard/network_log.txt
    DELAY=5
    WIFI_SSID="Siantar Lt 2"

    WIFI_FAIL=0
    SIM1_FAIL=0
    SIM2_FAIL=0
    MAX_FAIL=3

    PRIORITY_VAR="'$PRIORITY'"

    check_connection() {
        INTERFACE=$1
        SUCCESS=1
        for TARGET in $DNS1 $DNS2 $HOST; do
            ping -c 1 $TARGET >/dev/null
            if [ $? -ne 0 ]; then SUCCESS=0; fi
        done
        echo $SUCCESS
    }

    get_wifi_info() {
        # Ambil SSID, signal %, Rx/Tx rate
        SSID=$(termux-wifi-connectioninfo | grep "SSID" | awk -F'"' "{print \$2}")
        SIGNAL=$(termux-wifi-connectioninfo | grep "signal" | awk -F: "{print \$2}" | tr -d " ")
        RX=$(termux-wifi-connectioninfo | grep "rx" | awk -F: "{print \$2}" | tr -d " ")
        TX=$(termux-wifi-connectioninfo | grep "tx" | awk -F: "{print \$2}" | tr -d " ")
        echo "$SSID | Signal: $SIGNAL | Rx: $RX Mbps | Tx: $TX Mbps"
    }

    while true; do
        WIFI_STATE=$(termux-wifi-connectioninfo | grep "SSID" | awk -F\" "{print \$2}")

        # Wi-Fi cek
        if [ "$WIFI_STATE" == "$WIFI_SSID" ]; then
            WIFI_OK=$(check_connection "Wi-Fi")
            if [ $WIFI_OK -eq 1 ]; then
                WIFI_FAIL=0
                INFO=$(get_wifi_info)
                termux-toast "Wi-Fi OK: $INFO"
                echo "[$(date)] Wi-Fi OK: $INFO" >> $LOGFILE
            else
                WIFI_FAIL=$((WIFI_FAIL+1))
                echo "[$(date)] Wi-Fi FAIL ping" >> $LOGFILE
            fi
        else
            termux-toast "Wi-Fi drop!"
            echo "[$(date)] Wi-Fi not connected" >> $LOGFILE
            PRIORITY_VAR="sim1"
        fi

        # SIM1 cek
        SIM1_OK=$(check_connection "SIM1")
        if [ $SIM1_OK -eq 1 ]; then
            SIM1_FAIL=0
            termux-toast "SIM1 OK"
            echo "[$(date)] SIM1 OK" >> $LOGFILE
        else
            SIM1_FAIL=$((SIM1_FAIL+1))
            termux-toast "SIM1 Down"
            echo "[$(date)] SIM1 Down" >> $LOGFILE
        fi

        # SIM2 cek
        SIM2_OK=$(check_connection "SIM2")
        if [ $SIM2_OK -eq 1 ]; then
            SIM2_FAIL=0
            termux-toast "SIM2 OK"
            echo "[$(date)] SIM2 OK" >> $LOGFILE
        else
            SIM2_FAIL=$((SIM2_FAIL+1))
            termux-toast "SIM2 Down"
            echo "[$(date)] SIM2 Down" >> $LOGFILE
        fi

        # Prioritas koneksi (tanpa reconnect, hanya catatan)
        if [ "$PRIORITY_VAR" == "wifi" ] && [ "$WIFI_STATE" != "$WIFI_SSID" ]; then
            PRIORITY_VAR="sim1"; termux-toast "Wi-Fi down, switch to SIM1"; echo "[$(date)] Priority switched to SIM1" >> $LOGFILE
        elif [ "$PRIORITY_VAR" == "sim1" ] && [ $SIM1_OK -eq 0 ] && [ $SIM2_OK -eq 1 ]; then
            PRIORITY_VAR="sim2"; termux-toast "SIM1 down, switch to SIM2"; echo "[$(date)] Priority switched to SIM2" >> $LOGFILE
        elif [ "$PRIORITY_VAR" == "sim2" ] && [ $SIM1_OK -eq 1 ]; then
            PRIORITY_VAR="sim1"; termux-toast "SIM2 down, switch back to SIM1"; echo "[$(date)] Priority switched to SIM1" >> $LOGFILE
        elif [ "$PRIORITY_VAR" != "wifi" ] && [ "$WIFI_STATE" == "$WIFI_SSID" ]; then
            PRIORITY_VAR="wifi"; termux-toast "Wi-Fi available, switch back to Wi-Fi"; echo "[$(date)] Priority switched to Wi-Fi" >> $LOGFILE
        fi

        sleep '$DELAY'
    done
    ' >/dev/null 2>&1 &
else
    kill $PID
    termux-toast "Smart Network Guard stopped!"
fi
