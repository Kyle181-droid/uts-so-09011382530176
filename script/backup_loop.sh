#!/bin/bash
# Nama: Revandy Javier
# NIM: 09011382530176
# Kelas: P2

# Interval dapat diubah melalui environment; nilai bawaan adalah 60 detik.
INTERVAL="${INTERVAL:-60}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SCRIPT="${SCRIPT_DIR}/backup.sh"

# Pastikan interval berupa bilangan bulat positif.
if ! [[ "$INTERVAL" =~ ^[1-9][0-9]*$ ]]; then
    echo "INTERVAL harus bilangan bulat positif (detik)." >&2
    exit 1
fi

if [[ ! -x "$BACKUP_SCRIPT" ]]; then
    echo "Script backup tidak ditemukan atau belum executable: $BACKUP_SCRIPT" >&2
    echo "Jalankan: chmod +x \"$BACKUP_SCRIPT\"" >&2
    exit 1
fi

echo "Backup berulang dimulai. Interval: ${INTERVAL} detik."
echo "PID proses loop: $$"
echo "Hentikan dari terminal lain dengan: kill $$"

# Jalankan backup berulang sampai proses ini dihentikan dengan kill.
while true; do
    "$BACKUP_SCRIPT"
    sleep "$INTERVAL"
done
