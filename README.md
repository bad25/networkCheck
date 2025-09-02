# networkCheck
I build for project checking network on dekstop or mobie
# Cara pakai network_guard.sh
## Network Guard - Termux Script
**Smart Network Guard** adalah script monitor koneksi Wi-Fi dan Dual SIM Mobile Data di Android menggunakan Termux. Script ini mendukung toggle start/stop via widget, menampilkan toast realtime dengan informasi koneksi, dan mencatat log lengkap.

```⚠️ Karena smartphone tidak di-root, script tidak dapat auto-reconnect Wi-Fi atau mobile data. Failover hanya dicatat di toast dan log.```

## Fitur
1. Toggle start/stop via Termux:Widget
2. Dual SIM + Wi-Fi failover otomatis
3. Reconnect cerdas → restart hanya jika gagal 3x berturut-turut
4. Prioritas koneksi bisa dipilih via popup dialog: Wi-Fi, SIM1, SIM2
5. Toast informatif:
    - Wi-Fi: SSID, signal %, Rx/Tx Mbps
    - SIM1 / SIM2: status koneksi OK/Down
6. Log lengkap di /sdcard/network_log.txt

---
## Diagram Alur Failover
```
            +----------------+
            |   Wi-Fi Up?    |
            +----------------+
                  |
            +-----+-----+
            |           |
           Yes          No
            |           |
   +--------+--------+  |
   |  Use Wi-Fi       |  v
   |  Show toast OK   |  +-----------------+
   +-----------------+  | Switch to SIM1? |
                        +-----------------+
                               |
                        +------+------+
                        |             |
                       Yes            No
                        |             |
                 +------+-----+   +---+---+
                 | Use SIM1   |   | SIM1 Down
                 | Show toast |   | Show toast
                 +------------+   +-------+
                        |
                 +------+-----+
                 | SIM1 Up?   |
                 +------------+
                        |
                 +------+------+
                 |             |
                Yes            No
                 |             |
           +-----+-----+   +---+---+
           | Use SIM1   |   | Switch to SIM2
           | Show toast |   | Show toast
           +------------+   +-------+
                        |
                 +------+-----+
                 | SIM2 Up?   |
                 +------------+
                        |
                 +------+------+
                 |             |
                Yes            No
                 |             |
           +-----+-----+   +---+---+
           | Use SIM2   |   | Semua koneksi gagal
           | Show toast |   | Show toast
           +------------+   +-------+
```
---

## Persiapan

1. Install **Termux** dari [Play Store](https://play.google.com/store/apps/details?id=com.termux&utm_source=chatgpt.com&pli=1) atau [F-Droid](https://f-droid.org/packages/com.termux.widget/).
2. Install package `inetutils` untuk command `ping`:
```bash
pkg update
pkg upgrade
pkg install git bash coreutils termux-api jq
```
standar pkg / apt di Termux ketika ada paket yang sudah terpasang atau ada versi baru yang tersedia. Pilihan-pilihannya artinya:
y / i → Install versi dari maintainer (update/install baru) ✅
n / o → Keep versi yang sekarang terpasang (tidak diubah)
d → Tampilkan perbedaan antara versi sekarang dan versi baru
z → Masuk shell untuk memeriksa paket lebih lanjut
Biasanya untuk install baru atau update, pilih y agar paket terbaru terpasang.
3. Clone repository:
```
# ganti URL dengan repository Git kamu
git clone https://github.com/bad25/networkCheck.git ~/networkCheck
cd ~/networkCheck
```
4. Pindahkan script ke folder widget:
```
mkdir -p ~/.shortcuts
cp network_guard.sh ~/.shortcuts/
chmod +x ~/.shortcuts/network_guard.sh
```
### Cara Pakai
1. Tambahkan widget Termux ke layar utama Android Anda.
2.Klik widget untuk menjalankan script:
    - Start: Memulai pemantauan koneksi.
    - Stop: Menghentikan pemantauan koneksi.
3. Prioritas Koneksi: Pilih prioritas koneksi (Wi-Fi, SIM1, SIM2) melalui dialog interaktif yang muncul saat script dijalankan.

#### Catatan
- Non-root: Script ini tidak memerlukan akses root, namun tidak dapat melakukan reconnect otomatis pada Wi-Fi atau data seluler.
- Log: Semua status koneksi dicatat di /sdcard/network_log.txt.
- Toast: Informasi koneksi ditampilkan melalui toast yang muncul di layar.