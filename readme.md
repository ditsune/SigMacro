# SigMacro v2.1

> Automation tool berbasis AutoHotkey v2 untuk mempercepat alur login dan manajemen backup code pada platform Sigma/Roblox.

---

## Daftar Isi

- [Tentang Proyek](#tentang-proyek)
- [Fitur](#fitur)
- [Persyaratan](#persyaratan)
- [Instalasi](#instalasi)
- [Cara Penggunaan](#cara-penggunaan)
- [Hotkey](#hotkey)
- [Konfigurasi](#konfigurasi)
- [Struktur Proyek](#struktur-proyek)
- [Lisensi](#lisensi)

---

## Tentang Proyek

**SigMacro** adalah skrip otomasi berbasis [AutoHotkey v2](https://www.autohotkey.com/) yang dirancang untuk mempercepat dan menyederhanakan proses login serta pengelolaan backup code. Skrip ini dilengkapi GUI interaktif, pergerakan mouse ala manusia (Bezier curve), image search, logging sesi, dan pembaruan otomatis.

---

## Fitur

- **Login otomatis** — via clipboard maupun website langsung
- **Manajemen Backup Code** — proses BC 1 & BC 2, autentikasi, dan copy backup code
- **Gerak mouse humanized** — menggunakan kurva Bezier agar tidak terdeteksi sebagai bot
- **Image Search** — deteksi elemen layar secara visual dengan toleransi warna yang dapat dikonfigurasi
- **Logging** — log sesi ke UI dan file `sigmacro.log`
- **Statistik sesi** — mencatat jumlah percobaan dan keberhasilan
- **Auto-update** — cek versi terbaru secara otomatis di background
- **Settings dialog** — konfigurasi langsung dari GUI tanpa edit file manual
- **Pause/Resume** — hentikan sementara eksekusi tanpa menutup aplikasi
- **Admin-aware** — otomatis meminta elevasi UAC saat diperlukan

---

## Persyaratan

| Kebutuhan | Keterangan |
|-----------|-----------|
| OS | Windows 10 / 11 |
| AutoHotkey | v2.0 atau lebih baru |
| Hak akses | Administrator (diminta otomatis) |
| Resolusi | Disesuaikan dengan koordinat di `Constants.ahk` |

---

## Instalasi

1. **Install AutoHotkey v2**
   Unduh dari [https://www.autohotkey.com/](https://www.autohotkey.com/) dan pilih versi **v2.x**.

2. **Clone repositori ini**
   ```bash
   git clone https://github.com/cuakproject/SigMacro.git
   cd SigMacro
   ```

3. **Jalankan skrip utama**
   Klik dua kali pada `Main.ahk` atau jalankan via terminal:
   ```bash
   "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" Main.ahk
   ```
   Skrip akan meminta hak Administrator secara otomatis jika belum dijalankan sebagai admin.

---

## Cara Penggunaan

Setelah dijalankan, jendela **Ditsy v2.1** akan muncul dengan beberapa grup tombol:

### LOGIN
| Tombol | Fungsi |
|--------|--------|
| Login Clipboard | Login menggunakan kredensial dari clipboard |
| Login Website | Membuka dan mengisi form login di website |
| PW Tele | Masukkan password lalu lanjut ke backup code |
| Paste PW | Paste password dari clipboard |

### BACKUP CODE
| Tombol | Fungsi |
|--------|--------|
| Proses BC 1 | Proses backup code metode pertama |
| Proses BC 2 | Proses backup code dengan deteksi incompatible |
| BC Authen | Autentikasi menggunakan backup code |
| Copy BC | Salin backup code ke clipboard |

### TOOLS
| Tombol | Fungsi |
|--------|--------|
| Reload | Restart skrip |
| Exit | Keluar dari aplikasi |
| Pause | Jeda/lanjutkan eksekusi |
| Settings | Buka dialog pengaturan |

---

## Hotkey

| Shortcut | Aksi |
|----------|------|
| `Ctrl+U` | Login Clipboard |
| `Ctrl+M` | Login Website |
| `Ctrl+P` | PW Tele |
| `Ctrl+Q` | Paste PW |
| `Ctrl+O` | Proses BC 1 |
| `Ctrl+E` | Proses BC 2 |
| `Ctrl+K` | BC Authen |
| `Ctrl+I` | Copy BC |
| `Ctrl+B` | Reload |
| `Ctrl+Esc` | Exit |
| `Ctrl+F12` | Pause / Resume |

### Debug Hotkey
| Shortcut | Aksi |
|----------|------|
| `Ctrl+J` | Tampilkan posisi mouse saat ini |
| `Ctrl+T` | Debug deteksi 2FA |
| `Ctrl+Y` | Debug posisi window aktif |
| `Ctrl+0` | Cek deteksi incompatible |

---

## Konfigurasi

Semua konfigurasi disimpan di file `sigmacro.ini`. Dapat diedit manual atau melalui tombol **Settings** di GUI.

### `[Timing]`
Mengatur jeda antar aksi (dalam milidetik):
```ini
DelayMin=200
DelayMax=350
SubmitDelay=300
TFATimeout=15000
```

### `[Bezier]`
Mengatur perilaku pergerakan mouse:
```ini
StepsMin=8
StepsMax=15
OffsetMin=12
OffsetMax=28
```

### `[ImageSearch]`
Toleransi warna untuk pengenalan gambar di layar:
```ini
Tolerances=30,50,70,90
FastTolerances=30,50,70
```

### `[Retry]`
Maksimal percobaan ulang untuk backup code:
```ini
BCMaxRetry=100
```

### `[Coords]`
Override koordinat klik jika layout berubah (hapus titik koma untuk mengaktifkan):
```ini
; bc_code1_x=1677
; bc_code1_y=1008
```

### `[Regions]`
Wilayah layar untuk deteksi gambar (image search region):
```ini
region_incompat_x1=1244
region_incompat_y1=184
...
```

---

## Struktur Proyek

```
SigMacro/
├── Main.ahk                  # Entry point utama + GUI
├── sigmacro.ini              # File konfigurasi
├── sigmacro.log              # Log sesi (dibuat otomatis)
├── stats.ini                 # Data statistik sesi
├── version.txt               # Versi skrip saat ini
│
├── core/
│   ├── Logger.ahk            # Logging ke UI dan file
│   ├── Mouse.ahk             # HumanClick, BezierMove, Delay
│   ├── ImageSearch.ahk       # FindImage, WaitForImage, CheckIncompatible
│   └── Logic.ahk             # Semua logika aksi utama
│
├── shared/
│   ├── Constants.ahk         # Peta koordinat layar
│   ├── Config.ahk            # Load/save konfigurasi dari INI
│   ├── Stats.ahk             # RecordSession, LoadStats, ResetStats
│   └── Update.ahk            # Cek pembaruan otomatis
│
└── ui/
    └── SettingsDialog.ahk    # Dialog pengaturan GUI
```

---

## Lisensi

Proyek ini bersifat **privat** dan dikelola oleh [cuakproject](https://github.com/cuakproject). Penggunaan ulang atau distribusi tanpa izin tidak diperbolehkan.
