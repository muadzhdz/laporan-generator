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
REPORT="$OUTDIR/Laporan.docx"

# Resolve Python (handle WindowsApps stub redirector on Windows)
PYTHON_BIN="python3"
if ! command -v python3 >/dev/null 2>&1 || ! python3 -V >/dev/null 2>&1; then
  if command -v python >/dev/null 2>&1 && python -V >/dev/null 2>&1; then
    PYTHON_BIN="python"
  fi
fi

if [ ! -d "$OUTDIR/chapters" ]; then
  echo "ERROR: Direktori chapters/ tidak ditemukan."
  exit 1
fi

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
copy_asset "logo.jpg" "$TMPDIR" || true
copy_asset "reference.docx" "$TMPDIR" || true
copy_asset "docx.lua" "$TMPDIR" || true
copy_asset "metadata.yml" "$TMPDIR" || true
copy_asset "references.bib" "$TMPDIR" || true
copy_asset "apa.csl" "$TMPDIR" || true
copy_asset "presets" "$TMPDIR" || true
copy_asset "scripts" "$TMPDIR" || true

if [ -d "$OUTDIR/gambar" ]; then
  cp -r "$OUTDIR/gambar" "$TMPDIR/"
elif [ -d "$DIR/gambar" ]; then
  cp -r "$DIR/gambar" "$TMPDIR/"
fi

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

cd "$TMPDIR"

PRESET_NAME=$(grep -E '^[[:space:]]*(preset|margin_preset):' "$TMPDIR/metadata.yml" 2>/dev/null | head -n 1 | cut -d: -f2- | tr -d '"'\''\r\n ')
PRESET_OPTS=()
if [ -n "$PRESET_NAME" ] && [ -f "$TMPDIR/presets/${PRESET_NAME}.yml" ]; then
  PRESET_OPTS=("--metadata-file=$TMPDIR/presets/${PRESET_NAME}.yml")
elif [ -f "$TMPDIR/presets/standard.yml" ]; then
  PRESET_OPTS=("--metadata-file=$TMPDIR/presets/standard.yml")
fi

pandoc \
  "${INPUT_FILES[@]}" \
  "${PRESET_OPTS[@]}" \
  --metadata-file="metadata.yml" \
  --citeproc \
  --bibliography="references.bib" \
  --csl="apa.csl" \
  --metadata=reference-section-title="DAFTAR PUSTAKA" \
  --top-level-division=chapter \
  --reference-doc="reference.docx" \
  --lua-filter="docx.lua" \
  -o "$TMPDIR/Laporan-tmp.docx" 2>&1

FINALIZE_SCRIPT="$TMPDIR/scripts/finalize-docx.py"
PAGENUM_SCRIPT="$TMPDIR/scripts/docx-pagenum.py"
if [ ! -f "$FINALIZE_SCRIPT" ]; then
  for base in "${FALLBACK_DIRS[@]}"; do
    if [ -f "$base/scripts/finalize-docx.py" ]; then
      FINALIZE_SCRIPT="$base/scripts/finalize-docx.py"
      break
    fi
  done
fi
if [ ! -f "$PAGENUM_SCRIPT" ]; then
  for base in "${FALLBACK_DIRS[@]}"; do
    if [ -f "$base/scripts/docx-pagenum.py" ]; then
      PAGENUM_SCRIPT="$base/scripts/docx-pagenum.py"
      break
    fi
  done
fi

export PYTHONUTF8=1
"$PYTHON_BIN" "$FINALIZE_SCRIPT" "$TMPDIR/Laporan-tmp.docx" "$TMPDIR/Laporan-sect.docx"
"$PYTHON_BIN" "$PAGENUM_SCRIPT" "$TMPDIR/Laporan-sect.docx" "$REPORT"

echo "=== DOCX BERHASIL DIBUAT ==="
echo "Lokasi: $REPORT"
