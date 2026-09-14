#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -n "$1" ]; then
  OUTDIR="$1"
elif [ -f "$(pwd)/metadata.yml" ] && [ -d "$(pwd)/chapters" ]; then
  OUTDIR="$(pwd)"
else
  OUTDIR="$DIR"
fi
REPORT="$OUTDIR/Laporan.pdf"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

FALLBACK_DIRS=(
  "$OUTDIR"
  "$DIR"
  "$HOME/.agents/skills/laporan-generator/resources"
)

copy_asset() {
  local asset="$1"
  local dest="$2"
  for base in "${FALLBACK_DIRS[@]}"; do
    if [ -e "$base/$asset" ]; then
      cp -r "$base/$asset" "$dest/"
      return 0
    fi
  done
  return 1
}

copy_asset "cover.md" "$TMPDIR" || true
copy_asset "template.typ" "$TMPDIR" || true
copy_asset "logo.jpg" "$TMPDIR" || true
copy_asset "metadata.yml" "$TMPDIR" || true
copy_asset "references.bib" "$TMPDIR" || true
copy_asset "apa.csl" "$TMPDIR" || true
copy_asset "presets" "$TMPDIR" || true

if [ -d "$OUTDIR/chapters" ]; then
  cp "$OUTDIR/chapters"/*.md "$TMPDIR/" 2>/dev/null || true
  CHAPTER_FILES=$(find "$TMPDIR" -maxdepth 1 -name "bab*.md" | sort -V)
  if [ -z "$CHAPTER_FILES" ]; then
    echo "ERROR: Tidak ada berkas bab*.md di direktori chapters/."
    exit 1
  fi
  INPUT_FILES=("$TMPDIR/cover.md")
  while IFS= read -r f; do
    [ -n "$f" ] && INPUT_FILES+=("$f")
  done < <(find "$TMPDIR" -maxdepth 1 -name "bab*.md" | sort -V)
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
PRESET_OPTS=()
if [ -n "$PRESET_NAME" ] && [ -f "$TMPDIR/presets/${PRESET_NAME}.yml" ]; then
  PRESET_OPTS=("--metadata-file=$TMPDIR/presets/${PRESET_NAME}.yml")
elif [ -f "$TMPDIR/presets/standard.yml" ]; then
  PRESET_OPTS=("--metadata-file=$TMPDIR/presets/standard.yml")
fi

if ! pandoc \
  "${INPUT_FILES[@]}" \
  --template="template.typ" \
  "${PRESET_OPTS[@]}" \
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