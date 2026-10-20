# Tugas Besar UTS Sistem Operasi — Revandy Javier

## 1. Identitas

- **Nama:** Revandy Javier
- **NIM:** 09011382530176
- **Kelas:** P2
- **Repository:** `uts-so-09011382530176`

## 2. Deskripsi

Proyek ini membuat backup catatan praktikum di Linux menggunakan Bash. `backup.sh` mencari seluruh file berekstensi `.txt` pada direktori sumber termasuk subdirektori, menyimpan daftar file hasil pencarian, mengarsipkan file tersebut dengan `tar -czvf`, memverifikasi isi arsip dengan `tar -tzvf`, dan menambahkan hasilnya ke file log. Nama arsip memakai NIM dan timestamp.

`backup_loop.sh` menjalankan `backup.sh` berulang dengan `while true` dan `sleep`. `alias.sh` mendefinisikan alias `bk176` untuk menjalankan proses backup.

## 3. Cara menjalankan

### A. Siapkan direktori sumber dan data uji

Jalankan perintah berikut di terminal Linux. Perintah ini membuat 10 file `.txt` di direktori utama, dua file berekstensi lain, dan dua subdirektori yang masing-masing berisi dua file `.txt`.

```bash
mkdir -p "$HOME/data_09011382530176/modul_1" \
         "$HOME/data_09011382530176/modul_2"

for i in {1..10}; do
    printf 'Catatan praktikum nomor %s\n' "$i" \
        > "$HOME/data_09011382530176/catatan_${i}.txt"
done

printf 'Contoh data Markdown\n' \
    > "$HOME/data_09011382530176/ringkasan.md"
printf 'id,nilai\n1,90\n' \
    > "$HOME/data_09011382530176/nilai.csv"

for i in {1..2}; do
    printf 'Catatan modul 1 nomor %s\n' "$i" \
        > "$HOME/data_09011382530176/modul_1/catatan_${i}.txt"
    printf 'Catatan modul 2 nomor %s\n' "$i" \
        > "$HOME/data_09011382530176/modul_2/catatan_${i}.txt"
done
```

### B. Beri izin eksekusi dan jalankan backup

```bash
cd ~/uts-so-github
chmod +x script/*.sh
./script/backup.sh
```

Hasil backup disimpan di `~/backup_09011382530176/`. File log berada di `~/backup_09011382530176/backup.log`. Daftar file hasil `find` disimpan sebagai `daftar_file_TANGGAL_JAM.txt`.

Untuk memeriksa hasil:

```bash
cat ~/backup_09011382530176/backup.log
ls -lh ~/backup_09011382530176/
busybox busybox busybox tar -tzvf ~/backup_09011382530176/backup_09011382530176_TANGGAL_JAM.tar.gz
```

Ganti `TANGGAL_JAM` dengan timestamp nama arsip yang benar-benar dibuat.

### C. Menjalankan alias

Muat alias ke shell aktif:

```bash
source ~/uts-so-github/script/alias.sh
bk176
```

Agar alias tersedia setelah login berikutnya, buka `~/.bashrc`:

```bash
nano ~/.bashrc
```

Tambahkan baris berikut (baris ini sama dengan yang ada di `script/alias.sh`):

```bash
alias bk176='bash "$HOME/uts-so-github/script/backup.sh"'
```

Simpan, lalu muat ulang konfigurasi:

```bash
source ~/.bashrc
bk176
```

### D. Menjalankan backup berulang

```bash
cd ~/uts-so-github/script
./backup_loop.sh &
jobs -l
```

Nilai interval bawaan adalah 60 detik. Untuk pengujian lebih cepat, interval dapat ditentukan saat menjalankan script, misalnya:

```bash
INTERVAL=5 ./backup_loop.sh &
```

Hentikan job menggunakan nomor job yang tampil pada `jobs -l`:

```bash
kill %1
jobs -l
```

### E. Fitur pengembangan: rotasi arsip

Script `backup.sh` menyimpan maksimal lima arsip `backup_09011382530176_*.tar.gz` terbaru. Setelah backup berhasil, arsip yang lebih lama dihapus. Daftar file dan `backup.log` tidak ikut dihapus oleh rotasi.

## 4. Fitur pengembangan

Fitur yang dipilih adalah **rotasi arsip**. Untuk mengujinya, jalankan backup beberapa kali dengan jeda agar nama timestamp berbeda:

```bash
./script/backup.sh
sleep 1
./script/backup.sh
sleep 1
./script/backup.sh
ls -lt ~/backup_09011382530176/backup_09011382530176_*.tar.gz
```

Setelah lebih dari lima arsip dibuat, periksa bahwa hanya lima arsip terbaru yang tersisa.

