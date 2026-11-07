#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$DIR")"

echo "=== Verifikasi Kompilasi Seluruh Contoh Dokumen ==="
echo ""

EXAMPLES=(
  "01-Skripsi-Nasional"
  "02-Makalah-Kuliah"
  "03-Jurnal-UAJY-IEEE"
)

for ex in "${EXAMPLES[@]}"; do
  EX_DIR="$DIR/$ex"
  echo "--> Membangun: $ex..."
  "$ROOT_DIR/build.sh" "$EX_DIR"
  PDF_FILE="$EX_DIR/Laporan.pdf"
  if [ ! -f "$PDF_FILE" ]; then
    echo "ERROR: $PDF_FILE gagal dibuat."
    exit 1
  fi
  SIZE=$(stat -c%s "$PDF_FILE" 2>/dev/null || stat -f%z "$PDF_FILE" 2>/dev/null)
  if [ "$SIZE" -lt 10000 ]; then
    echo "ERROR: Ukuran $PDF_FILE terlalu kecil ($SIZE bytes)."
    exit 1
  fi
  echo "    [OK] PDF berhasil dibuat ($SIZE bytes)"
done

echo ""
echo "=== Seluruh Contoh Berhasil Dikompilasi dan Valid! ==="
