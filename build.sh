#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
OUTDIR="$DIR"
REPORT="$OUTDIR/Laporan.pdf"

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

cp "$OUTDIR/cover.md" "$TMPDIR/"
cp "$OUTDIR/template.typ" "$TMPDIR/"
cp "$OUTDIR/logo.jpg" "$TMPDIR/"
cp "$OUTDIR/metadata.yml" "$TMPDIR/" 2>/dev/null || true
cp "$OUTDIR/references.bib" "$TMPDIR/" 2>/dev/null || true
cp "$OUTDIR/apa.csl" "$TMPDIR/" 2>/dev/null || true
cp -r "$OUTDIR/presets" "$TMPDIR/" 2>/dev/null || true

if [ -d "$OUTDIR/chapters" ]; then
  cp "$OUTDIR/chapters"/*.md "$TMPDIR/" 2>/dev/null || true
  CHAPTER_FILES=$(find "$TMPDIR" -maxdepth 1 -name "bab*.md" | sort -V)
  if [ -z "$CHAPTER_FILES" ]; then
    echo "ERROR: Tidak ada berkas bab*.md di direktori chapters/."
    exit 1
  fi
  INPUT_FILES="$TMPDIR/cover.md $CHAPTER_FILES"
else
  echo "ERROR: Direktori chapters/ tidak ditemukan."
  echo "Buat folder chapters/ dengan file bab laporan (contoh: bab1-pendahuluan.md dst)."
  exit 1
fi

if [ -d "$OUTDIR/gambar" ]; then
  cp -r "$OUTDIR/gambar" "$TMPDIR/"
  IM_CONV="convert"
  command -v magick >/dev/null 2>&1 && IM_CONV="magick"
  find "$TMPDIR/gambar" -type f \( -name "*.png" -o -name "*.PNG" \) -exec $IM_CONV {} -alpha off {} \; 2>/dev/null || true
fi

cd "$TMPDIR"

PRESET_NAME=$(grep -E '^[[:space:]]*(preset|margin_preset):' "$TMPDIR/metadata.yml" 2>/dev/null | head -n 1 | cut -d: -f2- | tr -d '"'\''\r\n ')
PRESET_OPTS=""
if [ -n "$PRESET_NAME" ] && [ -f "$TMPDIR/presets/${PRESET_NAME}.yml" ]; then
  PRESET_OPTS="--metadata-file=$TMPDIR/presets/${PRESET_NAME}.yml"
elif [ -f "$TMPDIR/presets/standard.yml" ]; then
  PRESET_OPTS="--metadata-file=$TMPDIR/presets/standard.yml"
fi

if ! pandoc \
  $INPUT_FILES \
  --template="template.typ" \
  $PRESET_OPTS \
  --metadata-file="metadata.yml" \
  --citeproc \
  --bibliography="references.bib" \
  --csl="apa.csl" \
  --metadata=reference-section-title="DAFTAR PUSTAKA" \
  --top-level-division=chapter \
  --pdf-engine=typst \
  --no-highlight \
  -o "$REPORT" 2>&1; then
  echo ""
  echo "[ERROR] BUILD GAGAL: Terjadi kesalahan saat kompilasi Pandoc/Typst."
  echo "Kemungkinan penyebab & solusi:"
  echo "  1. Sintaks YAML di metadata.yml tidak valid -> Cek docs/metadata-schema.md"
  echo "  2. Berkas gambar tidak ditemukan atau rusak -> Cek path gambar di chapters/"
  echo "  3. Sintaks Markdown tidak didukung -> Cek docs/troubleshooting.md"
  echo "  4. Gunakan Docker jika ada masalah dependensi lokal: docker compose run --rm laporan-generator"
  exit 1
fi

echo ""
echo "=== PDF BERHASIL DIBUAT ==="
echo "Lokasi: $REPORT"