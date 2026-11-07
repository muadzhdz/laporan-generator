#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -n "$1" ]; then
  OUTDIR="$(cd "$1" && pwd)"
elif [ -f "$(pwd)/metadata.yml" ] && [ -d "$(pwd)/chapters" ]; then
  OUTDIR="$(pwd)"
elif [ -f "$DIR/templates/default/metadata.yml" ] && [ -d "$DIR/templates/default/chapters" ]; then
  OUTDIR="$DIR/templates/default"
else
  OUTDIR="$DIR"
fi
REPORT="$OUTDIR/Laporan.pdf"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

FALLBACK_DIRS=(
  "$OUTDIR"
  "$DIR/templates/default"
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
copy_asset "ieee.csl" "$TMPDIR" || true
copy_asset "presets" "$TMPDIR" || true

PRESET_NAME=$(grep -E '^[[:space:]]*(preset|margin_preset):' "$TMPDIR/metadata.yml" 2>/dev/null | head -n 1 | cut -d: -f2- | tr -d '"'\''\r\n ')
PRESET_OPTS=()
if [ -n "$PRESET_NAME" ] && [ -f "$TMPDIR/presets/${PRESET_NAME}.yml" ]; then
  PRESET_OPTS=("--metadata-file=$TMPDIR/presets/${PRESET_NAME}.yml")
elif [ -f "$TMPDIR/presets/standard.yml" ]; then
  PRESET_OPTS=("--metadata-file=$TMPDIR/presets/standard.yml")
fi

DOC_TYPE=$(grep -E '^[[:space:]]*doc_type:' "$TMPDIR/metadata.yml" 2>/dev/null | head -n 1 | cut -d: -f2- | tr -d '"'\''\r\n ')
if [ -z "$DOC_TYPE" ] && [ -n "$PRESET_NAME" ] && [ -f "$TMPDIR/presets/${PRESET_NAME}.yml" ]; then
  DOC_TYPE=$(grep -E '^[[:space:]]*doc_type:' "$TMPDIR/presets/${PRESET_NAME}.yml" 2>/dev/null | head -n 1 | cut -d: -f2- | tr -d '"'\''\r\n ')
fi

CSL_FILE="apa.csl"
REQ_CSL=$(grep -E '^[[:space:]]*(csl|citation_style):' "$TMPDIR/metadata.yml" 2>/dev/null | head -n 1 | cut -d: -f2- | tr -d '"'\''\r\n ')
if [ -z "$REQ_CSL" ] && [ -n "$PRESET_NAME" ] && [ -f "$TMPDIR/presets/${PRESET_NAME}.yml" ]; then
  REQ_CSL=$(grep -E '^[[:space:]]*(csl|citation_style):' "$TMPDIR/presets/${PRESET_NAME}.yml" 2>/dev/null | head -n 1 | cut -d: -f2- | tr -d '"'\''\r\n ')
fi
if [ "$REQ_CSL" = "ieee" ] || [ "$REQ_CSL" = "ieee.csl" ]; then
  CSL_FILE="ieee.csl"
fi

TOP_DIV="chapter"
if [ "$DOC_TYPE" = "journal" ]; then
  TOP_DIV="section"
fi

if [ -d "$OUTDIR/chapters" ]; then
  cp "$OUTDIR/chapters"/*.md "$TMPDIR/" 2>/dev/null || true
  if [ "$DOC_TYPE" = "journal" ]; then
    INPUT_FILES=()
    while IFS= read -r f; do
      [ -n "$f" ] && INPUT_FILES+=("$f")
    done < <(find "$TMPDIR" -maxdepth 1 -name "*.md" ! -name "cover.md" | sort -V)
  else
    CHAPTER_FILES=$(find "$TMPDIR" -maxdepth 1 -name "bab*.md" | sort -V)
    if [ -z "$CHAPTER_FILES" ]; then
      echo "ERROR: Tidak ada berkas bab*.md di direktori chapters/."
      exit 1
    fi
    INPUT_FILES=("$TMPDIR/cover.md")
    while IFS= read -r f; do
      [ -n "$f" ] && INPUT_FILES+=("$f")
    done < <(find "$TMPDIR" -maxdepth 1 -name "bab*.md" | sort -V)
  fi
else
  echo "ERROR: Direktori chapters/ tidak ditemukan."
  exit 1
fi

if [ -d "$OUTDIR/gambar" ]; then
  cp -r "$OUTDIR/gambar" "$TMPDIR/"
  IM_CONV="convert"
  command -v magick >/dev/null 2>&1 && IM_CONV="magick"
  find "$TMPDIR/gambar" -type f \( -name "*.png" -o -name "*.PNG" \) -exec $IM_CONV {} -alpha off {} \; 2>/dev/null || true
fi

cd "$TMPDIR"

if ! pandoc \
  "${INPUT_FILES[@]}" \
  --template="template.typ" \
  "${PRESET_OPTS[@]}" \
  --metadata-file="metadata.yml" \
  --citeproc \
  --bibliography="references.bib" \
  --csl="$CSL_FILE" \
  --metadata=reference-section-title="DAFTAR PUSTAKA" \
  --top-level-division="$TOP_DIV" \
  --pdf-engine=typst \
  --no-highlight \
  -o "$REPORT" 2>&1; then
  echo ""
  echo "[ERROR] BUILD GAGAL: Terjadi kesalahan saat kompilasi Pandoc/Typst."
  exit 1
fi

echo ""
echo "=== PDF BERHASIL DIBUAT ==="
echo "Lokasi: $REPORT"
