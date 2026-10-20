#!/bin/bash
# Nama: Revandy Javier
# NIM: 09011382530176
# Kelas: P2

# Konfigurasi utama: ubah lokasi cukup di bagian ini.
NIM="09011382530176"
SOURCE_DIR="${HOME}/data_09011382530176"
DEST_DIR="${HOME}/backup_09011382530176"
LOG_FILE="${DEST_DIR}/backup.log"
ROTATION_LIMIT=5

# Folder backup harus tersedia sebelum file log dibuat.
if ! mkdir -p "$DEST_DIR"; then
    echo "Gagal membuat direktori backup: $DEST_DIR" >&2
    exit 1
fi

# Timestamp digunakan untuk nama arsip. Tunggu jika nama detik ini sudah dipakai.
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
while [[ -e "${DEST_DIR}/backup_${NIM}_${TIMESTAMP}.tar.gz" ]]; do
    sleep 1
    TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
done

ARCHIVE_NAME="backup_${NIM}_${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="${DEST_DIR}/${ARCHIVE_NAME}"
FILE_LIST="${DEST_DIR}/daftar_file_${TIMESTAMP}.txt"
LOG_TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"

# Jika sumber belum tersedia, catat percobaan agar setiap pemanggilan tercatat.
if [[ ! -d "$SOURCE_DIR" ]]; then
    printf '%s | %s | 0 | 0B\n' "$LOG_TIMESTAMP" "$ARCHIVE_NAME" >> "$LOG_FILE"
    echo "Direktori sumber tidak ditemukan: $SOURCE_DIR" >&2
    exit 1
fi

# Cari seluruh file .txt, termasuk yang ada di subdirektori.
# Daftar disimpan sebagai teks dengan path relatif terhadap SOURCE_DIR.
if ! find "$SOURCE_DIR" -type f -name '*.txt' -printf '%P\n' > "$FILE_LIST"; then
    printf '%s | %s | 0 | 0B\n' "$LOG_TIMESTAMP" "$ARCHIVE_NAME" >> "$LOG_FILE"
    echo "Gagal mencari file .txt di $SOURCE_DIR" >&2
    exit 1
fi

FILE_COUNT="$(wc -l < "$FILE_LIST" | tr -d '[:space:]')"

# Jangan membuat arsip kosong; tetap catat hasil percobaan ke log.
if [[ "$FILE_COUNT" -eq 0 ]]; then
    printf '%s | %s | 0 | 0B\n' "$LOG_TIMESTAMP" "$ARCHIVE_NAME" >> "$LOG_FILE"
    echo "Tidak ditemukan file .txt di $SOURCE_DIR" >&2
    exit 1
fi

# Buat arsip terkompresi. Hanya daftar file .txt dari find yang dimasukkan.
if tar -czvf "$ARCHIVE_PATH" -C "$SOURCE_DIR" -T "$FILE_LIST"; then
    echo
    echo "Verifikasi isi arsip:"
    tar -tzvf "$ARCHIVE_PATH"

    # Ukuran ditampilkan dalam format mudah dibaca, misalnya 4.0K.
    ARCHIVE_SIZE="$(du -h "$ARCHIVE_PATH" | awk '{print $1}')"

    # Tambahkan tepat satu baris log untuk backup yang berhasil.
    printf '%s | %s | %s | %s\n' \
        "$LOG_TIMESTAMP" "$ARCHIVE_NAME" "$FILE_COUNT" "$ARCHIVE_SIZE" >> "$LOG_FILE"
    echo
    echo "Backup berhasil: $ARCHIVE_PATH"
    echo "Jumlah file .txt: $FILE_COUNT"
    echo "Ukuran arsip: $ARCHIVE_SIZE"
else
    # Hapus arsip yang tidak lengkap dan catat kegagalan.
    rm -f -- "$ARCHIVE_PATH"
    printf '%s | %s | %s | 0B\n' \
        "$LOG_TIMESTAMP" "$ARCHIVE_NAME" "$FILE_COUNT" >> "$LOG_FILE"
    echo "Pembuatan arsip gagal." >&2
    exit 1
fi

# Fitur pengembangan: rotasi arsip, simpan maksimal lima arsip terbaru.
mapfile -t OLD_ARCHIVES < <(
    find "$DEST_DIR" -maxdepth 1 -type f -name "backup_${NIM}_*.tar.gz" \
        -printf '%T@ %p\n' |
        sort -nr |
        tail -n +$((ROTATION_LIMIT + 1)) |
        cut -d' ' -f2-
)

for old_archive in "${OLD_ARCHIVES[@]}"; do
    [[ -n "$old_archive" ]] && rm -f -- "$old_archive"
done

echo "Rotasi selesai: maksimal ${ROTATION_LIMIT} arsip terbaru disimpan."
