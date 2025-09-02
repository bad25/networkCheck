#!/data/data/com.termux/files/usr/bin/bash
# ========================================
# Mobile Guard Daemon Final - Non-Root
# Verbose + toast + log + failover + stop file + persistent
# ========================================

LOGFILE=/sdcard/mobile_guard_log.txt
DELAY=10       # detik
SIGNAL_MIN=10  # minimal signal % agar dianggap bagus

while true; do
    DATE_NOW=$(date +"%Y-%m-%d %H:%M:%S")

    # ---------- Cek stop file ----------
    if [ -f /sdcard/mobile_guard_stop ]; then
        termux-toast "Mobile Guard stopped via stop file!"
        echo "[$DATE_NOW] Mobile Guard stopped via stop file!" >> $LOGFILE
        rm /sdcard/mobile_guard_stop
        exit 0
    fi

    # ---------- Cek SIM1 / SIM2 ----------
    SIM_INFO=$(termux-telephony-deviceinfo)
    SIM1_PRESENT=$(echo "$SIM_INFO" | grep -i sim1 | grep -o "true\|false")
    SIM2_PRESENT=$(echo "$SIM_INFO" | grep -i sim2 | grep -o "true\|false")

    SIM1_TEXT="SIM1: $( [ "$SIM1_PRESENT" = "true" ] && echo "Present" || echo "Not present" )"
    SIM2_TEXT="SIM2: $( [ "$SIM2_PRESENT" = "true" ] && echo "Present" || echo "Not present" )"

    # ---------- Ambil signal strength ----------
    if [ "$SIM1_PRESENT" = "true" ]; then
        SIM1_SIGNAL=$(termux-telephony-signalinfo --slot 0 | grep level | awk '{print $2}')
    else
        SIM1_SIGNAL=0
    fi

    if [ "$SIM2_PRESENT" = "true" ]; then
        SIM2_SIGNAL=$(termux-telephony-signalinfo --slot 1 | grep level | awk '{print $2}')
    else
        SIM2_SIGNAL=0
    fi

    # ---------- Pilih koneksi prioritas ----------
    PRIORITY=""
    if [ "$SIM1_PRESENT" = "true" ] && [ "$SIM1_SIGNAL" -ge "$SIGNAL_MIN" ]; then
        PRIORITY="SIM1"
    elif [ "$SIM2_PRESENT" = "true" ] && [ "$SIM2_SIGNAL" -ge "$SIGNAL_MIN" ]; then
        PRIORITY="SIM2"
    else
        PRIORITY="None"
    fi

    # ---------- Cek koneksi internet ----------
    INTERNET_OK=0
    if [ "$PRIORITY" != "None" ]; then
        ping -c 1 8.8.8.8 >/dev/null 2>&1 && INTERNET_OK=1
    fi

    INTERNET_TEXT=$( [ $INTERNET_OK -eq 1 ] && echo "Online" || echo "Offline" )

    # ---------- Tampilkan info di terminal ----------
    echo "[$DATE_NOW] $SIM1_TEXT | Signal: $SIM1_SIGNAL% | $SIM2_TEXT | Signal: $SIM2_SIGNAL% | Priority: $PRIORITY | Internet: $INTERNET_TEXT"

    # ---------- Log ----------
    echo "[$DATE_NOW] $SIM1_TEXT | Signal: $SIM1_SIGNAL% | $SIM2_TEXT | Signal: $SIM2_SIGNAL% | Priority: $PRIORITY | Internet: $INTERNET_TEXT" >> $LOGFILE

    # ---------- Toast ----------
    termux-toast "Priority: $PRIORITY | Internet: $INTERNET_TEXT"

    sleep $DELAY
done
