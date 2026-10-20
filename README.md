# UTS Sistem Operasi — Revandy Javier

## 1. Identitas

- **Nama:** Revandy Javier
- **NIM:** 09011382530176
- **Kelas:** P2
- **Repository:** [uts-so-09011382530176](https://github.com/Kyle181-droid/uts-so-09011382530176)

## 2. Deskripsi Proyek

Proyek ini membuat sistem *backup* catatan praktikum menggunakan Bash di Ubuntu (WSL 1). Script `backup.sh` mencari file berekstensi `.txt` secara rekursif, menyimpan daftar nama file, membuat arsip `.tar.gz` dengan **BusyBox tar**, memeriksa daftar isi arsip, mencatat aktivitas ke `backup.log`, dan menerapkan **rotasi maksimal lima arsip terbaru**.

Script `backup_loop.sh` menjalankan backup berulang menggunakan `while true` dan `sleep`, sedangkan `alias.sh` menyediakan jalan pintas `bk176` untuk menjalankan backup. Berbagai fitur telah diuji melalui terminal Ubuntu WSL 1.

> **Catatan lingkungan:** Pada WSL 1 yang digunakan untuk pengujian, GNU tar menghasilkan error `Cannot stat: Function not implemented`. Karena itu script memakai `busybox tar`. Pastikan BusyBox terpasang sebelum menjalankannya.

## 3. Struktur dan Persiapan

### 3.1 Struktur repository

```text
uts-so-09011382530176/
├── README.md
├── nim.txt
└── script/
    ├── backup.sh
    ├── backup_loop.sh
    └── alias.sh
```

Direktori lokal repository yang digunakan saat pengujian adalah `~/uts-so-github/`. Setelah melakukan `git clone` ke nama folder berbeda, sesuaikan path pada instruksi berikut.

### 3.2 Struktur data pengujian

Data pengujian yang digunakan berada di `~/data_09011382530176/`, dengan **14 file `.txt`**:

```text
data_09011382530176/
├── catatan1.txt
├── catatan2.txt
├── ...
├── catatan10.txt
├── modul1/
│   ├── praktikum1.txt
│   └── praktikum2.txt
├── modul2/
│   ├── praktikum1.txt
│   └── praktikum2.txt
├── [file .csv]
└── [file .md]
```

Pada pengujian yang direkam, keempat belas file `.txt` berukuran **0 byte**; file `.csv` dan `.md` tidak disertakan dalam arsip. Nama persis file tambahan `.csv` dan `.md` tidak didokumentasikan dalam keluaran pengujian.

Untuk menyiapkan contoh data yang sejenis **tanpa menimpa file yang sudah ada**:

```bash
mkdir -p "$HOME/data_09011382530176/modul1" "$HOME/data_09011382530176/modul2"
for i in {1..10}; do
    [[ -e "$HOME/data_09011382530176/catatan${i}.txt" ]] || \
        printf 'Catatan praktikum %s\n' "$i" > "$HOME/data_09011382530176/catatan${i}.txt"
done
for modul in modul1 modul2; do
    for i in 1 2; do
        [[ -e "$HOME/data_09011382530176/$modul/praktikum${i}.txt" ]] || \
            printf 'Catatan %s praktikum %s\n' "$modul" "$i" > "$HOME/data_09011382530176/$modul/praktikum${i}.txt"
    done
done
[[ -e "$HOME/data_09011382530176/nilai.csv" ]] || printf 'id,nilai\n1,90\n' > "$HOME/data_09011382530176/nilai.csv"
[[ -e "$HOME/data_09011382530176/ringkasan.md" ]] || printf '# Ringkasan\n' > "$HOME/data_09011382530176/ringkasan.md"
```

### 3.3 Persyaratan

- Ubuntu/Linux dengan Bash, `find`, `sort`, `stat`, dan utilitas dasar.
- BusyBox, dipasang di Ubuntu dengan:

```bash
sudo apt update
sudo apt install -y busybox
```

## 4. Cara Menjalankan

### 4.1 Backup satu kali

```bash
cd ~/uts-so-github
chmod +x script/*.sh
./script/backup.sh
```

Hasilnya tersimpan di:

- Arsip: `~/backup_09011382530176/backup_09011382530176_YYYYMMDD_HHMMSS.tar.gz`
- Log: `~/backup_09011382530176/backup.log`
- Daftar file hasil `find`: `~/backup_09011382530176/daftar_file_YYYYMMDD_HHMMSS.txt`

Periksa hasil:

```bash
cat ~/backup_09011382530176/backup.log
ls -lh ~/backup_09011382530176/*.tar.gz
# Ganti NAMA_ARSIP dengan nama file .tar.gz yang benar:
busybox tar -tzvf ~/backup_09011382530176/NAMA_ARSIP.tar.gz
```

`backup.log` mencatat tanggal/waktu, nama arsip, jumlah file `.txt`, dan ukuran arsip dalam **byte** (`stat -c %s`).

### 4.2 Alias `bk176`

Aktifkan alias di shell Bash saat ini:

```bash
source "$HOME/uts-so-github/script/alias.sh"
alias bk176
bk176
```

Agar alias aktif pada sesi Bash berikutnya, tambahkan baris berikut ke `~/.bashrc` (cukup satu kali):

```bash
grep -qxF 'source "$HOME/uts-so-github/script/alias.sh"' ~/.bashrc || \
  echo 'source "$HOME/uts-so-github/script/alias.sh"' >> ~/.bashrc
source ~/.bashrc
```

### 4.3 Backup berulang dan job control

Interval default adalah 60 detik. Untuk pengujian bisa memakai interval lain, contohnya 60 detik dengan log output dipisahkan:

```bash
INTERVAL=60 bash ~/uts-so-github/script/backup_loop.sh > /tmp/backup-loop-jobcontrol.log 2>&1 &
jobs -l
```

Gunakan nomor job yang benar sesuai keluaran `jobs -l` (`%1` di bawah **hanya contoh**):

```bash
fg %1
# Tekan Ctrl+Z untuk menghentikan sementara
jobs -l
bg %1
jobs -l
ps x | grep '[b]ackup_loop.sh'
kill %1
jobs -l
```

**Penting:** Backup loop berjalan terus sampai dihentikan. Jangan meninggalkannya aktif tanpa perlu. Pada WSL 1, terminal dapat menampilkan pesan `tcsetattr`, meski pengujian status `Stopped`, `Running`, dan `Terminated` berhasil.

## 5. Fitur Pengembangan: Rotasi Lima Arsip

`backup.sh` menyimpan **maksimal lima file** bernama `backup_09011382530176_*.tar.gz` berdasarkan waktu modifikasi. Arsip yang lebih lama dihapus setelah backup berhasil. File log dan daftar hasil `find` **tidak dihapus** oleh rotasi.

Pada pengujian, backup dijalankan **enam kali** dengan jeda satu detik. Periksa jumlah arsip yang tersisa:

```bash
find ~/backup_09011382530176 -maxdepth 1 -type f -name '*.tar.gz' | wc -l
```

**Hasil yang diperoleh: `5`.**

## 6. Bukti Pengujian Nyata

Bagian ini berasal dari keluaran terminal saat pengujian, dengan ringkasan kolom dan spasi agar lebih mudah dibaca. Contoh data di bagian 3.2 adalah instruksi pembuatan ulang, bukan klaim bahwa contoh tersebut persis digunakan pada pengujian awal.

### 6.1 Backup dan verifikasi arsip

Pemanggilan `bk176` berhasil mencantumkan 14 file, termasuk empat file di subdirektori. Ringkasan akhir terminal:

```text
Backup berhasil: /home/revandy/backup_09011382530176/backup_09011382530176_20261021_004140.tar.gz
Jumlah file .txt: 14
Ukuran arsip: 245B
Rotasi selesai: maksimal 5 arsip terbaru disimpan.
```

### 6.2 Log dan rotasi

Enam entri log hasil uji rotasi:

```text
2026-10-21 00:38:27 | backup_09011382530176_20261021_003827.tar.gz | 14 | 245B
2026-10-21 00:38:28 | backup_09011382530176_20261021_003828.tar.gz | 14 | 245B
2026-10-21 00:38:29 | backup_09011382530176_20261021_003829.tar.gz | 14 | 245B
2026-10-21 00:38:31 | backup_09011382530176_20261021_003831.tar.gz | 14 | 245B
2026-10-21 00:38:32 | backup_09011382530176_20261021_003832.tar.gz | 14 | 245B
2026-10-21 00:38:33 | backup_09011382530176_20261021_003833.tar.gz | 14 | 245B
```

Perintah `find ... | wc -l` menghasilkan `5`, sesuai batas rotasi.

### 6.3 Job control

Pengujian menggunakan PID **5106** dan nomor job **[1]**:

```text
$ INTERVAL=60 bash ~/uts-so-github/script/backup_loop.sh > /tmp/backup-loop-jobcontrol.log 2>&1 &
[1] 5106

$ jobs -l
[1]+ 5106 Running    INTERVAL=60 bash ~/uts-so-github/script/backup_loop.sh ... &

$ fg %1
INTERVAL=60 bash ~/uts-so-github/script/backup_loop.sh ...
[Ctrl+Z]
[1]+ Stopped      INTERVAL=60 bash ~/uts-so-github/script/backup_loop.sh ...

$ jobs -l
[1]+ 5106 Stopped  INTERVAL=60 bash ~/uts-so-github/script/backup_loop.sh ...

$ bg %1
[1]+ INTERVAL=60 bash ~/uts-so-github/script/backup_loop.sh ... &

$ jobs -l
[1]+ 5106 Running  INTERVAL=60 bash ~/uts-so-github/script/backup_loop.sh ... &

$ ps x | grep '[b]ackup_loop.sh'
5106 tty1 S 0:00 bash /home/revandy/uts-so-github/script/backup_loop.sh

$ kill %1

$ jobs -l
[1]+ 5106 Terminated INTERVAL=60 bash ~/uts-so-github/script/backup_loop.sh ...
```

Pesan tambahan yang muncul saat `Ctrl+Z` di terminal WSL 1 adalah `tcsetattr: Inappropriate ioctl for device`; status proses tetap berubah menjadi `Stopped`, lalu `Running` setelah `bg` dan `Terminated` setelah `kill`.

## 7. Kendala yang Dialami dan Solusi

1. **GNU tar gagal pada WSL 1:** pesan `Cannot stat: Function not implemented`. **Solusi:** gunakan `busybox tar` untuk membuat dan membaca arsip.
2. **BusyBox tar tidak mendukung opsi `-T`:** perintah awal tidak berhasil. **Solusi:** baca daftar file menggunakan `mapfile -t FILES`, kemudian teruskan `"${FILES[@]}"` ke BusyBox tar.
3. **Ukuran arsip di log muncul `0`:** `du -h` mengembalikan angka 0 pada lingkungan pengujian, padahal arsip berukuran 245 byte. **Solusi:** pakai `stat -c %s` untuk mengambil ukuran aktual dalam byte.
4. **Alias mengarah ke folder yang tidak digunakan:** awalnya memakai `uts-so-09011382530176` sebagai folder lokal. **Solusi:** perbaiki menjadi `~/uts-so-github/script/backup.sh` dan aktifkan melalui `~/.bashrc`.
5. **Terminal WSL 1 mengeluarkan pesan `tcsetattr`:** muncul saat pengujian `fg` dan `Ctrl+Z`. **Hasil:** `jobs`, `bg`, `ps`, dan `kill` tetap dapat digunakan sebagaimana ditunjukkan pada bukti di atas.
6. **Autentikasi push Git dari terminal Ubuntu terganggu:** push kemudian berhasil melalui Git Bash pada Windows.

## 8. Kesimpulan

Pengujian menunjukkan backup rekursif 14 file `.txt`, pembuatan dan pembacaan arsip, pencatatan log beserta ukuran, rotasi maksimal lima arsip, alias `bk176`, backup berulang, serta job control berfungsi pada lingkungan Ubuntu WSL 1 yang digunakan. Pengujian utama memakai file `.txt` kosong; pengujian tambahan dengan data nonkosong dapat dilakukan untuk memperkuat validasi isi file.
