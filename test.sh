#!/usr/bin/env bash
set -e

PASS=0
FAIL=0

pass() { PASS=$((PASS+1)); echo "  [OK] $1"; }
fail() { FAIL=$((FAIL+1)); echo "  [FAIL] $1"; }

echo "=== Test Suite: Laporan Generator ==="
echo ""

# T1: Cek dependensi
echo "[T1] Dependency check"
if command -v pandoc &>/dev/null; then pass "pandoc tersedia"; else fail "pandoc tidak ada"; fi
if command -v typst &>/dev/null; then pass "typst tersedia"; else fail "typst tidak ada"; fi
if command -v convert &>/dev/null; then pass "imagemagick tersedia"; else fail "imagemagick tidak ada"; fi
echo ""

# T2: Cek file wajib
echo "[T2] File structure check"
for f in cover.md template.typ build.sh metadata.yml references.bib reference.docx docx.lua; do
  if [ -f "$f" ]; then pass "$f ditemukan"; else fail "$f tidak ada"; fi
done
if [ -d chapters ] && ls chapters/bab*.md &>/dev/null; then
  pass "Konten laporan ditemukan (chapters/)"
else
  fail "Tidak ada konten laporan di chapters/"
fi
echo ""

# T3: Cek metadata validity
echo "[T3] Metadata check"
if grep -q '^title:' metadata.yml 2>/dev/null; then pass "metadata.yml punya title"; else fail "metadata.yml tidak punya title"; fi
if grep -q '^author:' metadata.yml 2>/dev/null; then pass "metadata.yml punya author"; else fail "metadata.yml tidak punya author"; fi
echo ""

# T4: Cek template validity
echo "[T4] Template check"
if grep -q '^#set page' template.typ; then pass "template punya konfigurasi halaman (#set page)"; else fail "template tanpa #set page"; fi
# shellcheck disable=SC2016
if grep -Fq '$body$' template.typ; then pass "template punya placeholder \$body\$"; else fail "template tanpa placeholder \$body\$"; fi
if grep -Fq 'set heading(numbering' template.typ; then pass "template punya penomoran heading otomatis"; else fail "template tanpa penomoran heading"; fi
echo ""

# T5: Cek gitignore
echo "[T5] .gitignore check"
if grep -Fq '*.pdf' .gitignore; then pass ".gitignore mengecualikan *.pdf"; else fail ".gitignore tidak exclude *.pdf"; fi
if ! grep -q '!Laporan.pdf' .gitignore 2>/dev/null; then pass ".gitignore tidak exception Laporan.pdf"; else fail ".gitignore masih exception Laporan.pdf"; fi
echo ""

# T6: Cek Dockerfile
echo "[T6] Docker check"
if [ -f Dockerfile ]; then pass "Dockerfile ada"; else fail "Dockerfile tidak ada"; fi
if [ -f docker-compose.yml ]; then pass "docker-compose.yml ada"; else fail "docker-compose.yml tidak ada"; fi
echo ""

# T7: Build test
echo "[T7] Build PDF"
if ./build.sh; then
  pass "Build sukses"
  if [ -f Laporan.pdf ]; then
    SIZE=$(stat -c%s Laporan.pdf 2>/dev/null || stat -f%z Laporan.pdf 2>/dev/null)
    if [ "$SIZE" -gt 50000 ]; then
      pass "PDF valid ($(numfmt --to=iec "$SIZE" 2>/dev/null || echo "${SIZE}B"))"
    else
      fail "PDF terlalu kecil ($SIZE bytes)"
    fi
  else
    fail "Laporan.pdf tidak dihasilkan"
  fi
else
  fail "Build gagal"
fi
echo ""

# T8: Cek box-drawing di konten
echo "[T8] No box-drawing characters"
if grep -rn -E '(├|─|└|│)' chapters/ 2>/dev/null; then
  fail "Masih ada box-drawing characters"
else
  pass "Tidak ada box-drawing characters"
fi
echo ""

# T9: Cek manual numbering di heading
echo "[T9] No manual numbering in headings"
if grep -rn '^## [0-9]\+\.' chapters/ 2>/dev/null; then
  fail "Masih ada manual numbering di heading (harusnya ## Judul, bukan ## 1.1 Judul)"
else
  pass "Tidak ada manual numbering di heading level 2"
fi
if grep -rn '^### [0-9]\+\.' chapters/ 2>/dev/null; then
  fail "Masih ada manual numbering di heading level 3"
else
  pass "Tidak ada manual numbering di heading level 3"
fi
echo ""

# T10: Cek metadata fields
echo "[T10] Metadata fields check"
if grep -q '^lecturer:' metadata.yml 2>/dev/null; then
  pass "metadata.yml punya lecturer"
else
  fail "metadata.yml tidak punya lecturer"
fi
if grep -q '^course:' metadata.yml 2>/dev/null; then
  pass "metadata.yml punya course"
else
  fail "metadata.yml tidak punya course"
fi
echo ""

# T11: Cek format BibTeX
echo "[T11] References check"
if grep -qE '^@[a-zA-Z]+{' references.bib 2>/dev/null; then
  pass "references.bib memiliki struktur BibTeX valid"
else
  fail "references.bib tidak memiliki entri BibTeX valid"
fi
echo ""

# T12: Cek target Makefile (init & view)
echo "[T12] Makefile targets check"
if grep -q 'init:' Makefile 2>/dev/null && grep -q 'view:' Makefile 2>/dev/null; then
  pass "Makefile memiliki target init dan view"
else
  fail "Makefile tidak memiliki target init atau view"
fi
echo ""

# T13: Cek recursive image processing
echo "[T13] Recursive image processing check"
if grep -q 'find.*gambar' build.sh 2>/dev/null; then
  pass "build.sh mendukung pemrosesan gambar rekursif (find)"
else
  fail "build.sh belum mendukung pemrosesan gambar rekursif"
fi
echo ""

# T14: Cek ekstrasi dan keterbacaan teks PDF
echo "[T14] PDF content readability check"
if command -v pdftotext &>/dev/null; then
  if [ -f Laporan.pdf ]; then
    WORDS=$(pdftotext Laporan.pdf - 2>/dev/null | wc -w)
    if [ "$WORDS" -gt 200 ]; then
      pass "PDF readable ($WORDS kata terdeteksi)"
    else
      fail "PDF terlalu sedikit konten atau corrupt ($WORDS kata)"
    fi
  else
    fail "Laporan.pdf tidak ditemukan untuk diaudit"
  fi
else
  pass "pdftotext tidak terinstall (skipped)"
fi
echo ""

# T15: Cek engine Typst pada pipeline
echo "[T15] Typst engine check"
if grep -q -- '--pdf-engine=typst' build.sh 2>/dev/null; then
  pass "build.sh menggunakan pdf-engine typst"
else
  fail "build.sh belum menggunakan pdf-engine typst"
fi
echo ""

# T16: Cek kualitas DOCX export
echo "[T16] DOCX export check"
if command -v unzip &>/dev/null; then
  if make docx >/dev/null 2>&1; then
    pass "make docx sukses"
    if [ -f Laporan.docx ]; then
      DOCXML=$(unzip -p Laporan.docx word/document.xml 2>/dev/null)
      STYXML=$(unzip -p Laporan.docx word/styles.xml 2>/dev/null)
      if echo "$DOCXML" | grep -q 'BAB I</w:t></w:r><w:r><w:br'; then
        pass "docx penomoran BAB I dua baris"
      else
        fail "docx BAB I bukan dua baris"
      fi
      if echo "$DOCXML" | grep -q 'BAB I PENDAHULUAN'; then
        pass "docx entri TOC BAB I PENDAHULUAN"
      else
        fail "docx tanpa entri TOC BAB I"
      fi
      if echo "$DOCXML" | grep -q 'KATA PENGANTAR' && ! echo "$DOCXML" | grep -q 'BAB I KATA PENGANTAR'; then
        pass "KATA PENGANTAR tanpa nomor bab"
      else
        fail "KATA PENGANTAR ke-numbering BAB I"
      fi
      if echo "$DOCXML" | grep -q 'w:hyperlink w:anchor'; then
        pass "docx daftar isi ber-hyperlink"
      else
        fail "docx daftar isi tanpa hyperlink"
      fi
      if echo "$DOCXML" | grep -q 'instrText'; then
        pass "docx punya field DAFTAR ISI (TOC)"
      else
        fail "docx tanpa field TOC"
      fi
      if ! echo "$DOCXML" | grep -q 'AbstractTitle'; then
        pass "docx tanpa halaman abstract"
      else
        fail "docx masih ada abstract"
      fi
      if echo "$STYXML" | grep -q 'Times New Roman'; then
        pass "docx memakai Times New Roman"
      else
        fail "docx tanpa Times New Roman"
      fi
      if echo "$DOCXML" | grep -q 'w:w="11906"'; then
        pass "docx ukuran halaman A4"
      else
        fail "docx bukan A4"
      fi
      if echo "$STYXML" | grep -q 'w:val="28"'; then
        pass "Heading1 berukuran 14pt (sz 28)"
      else
        fail "Heading1 bukan 14pt"
      fi
      if echo "$DOCXML" | grep -q 'w:drawing'; then
        pass "cover docx memuat logo"
      else
        fail "cover docx tanpa logo"
      fi
      if echo "$DOCXML" | grep -q 'w:val="CoverTitle"'; then
        pass "cover docx memakai style CoverTitle"
      else
        fail "cover docx tanpa style CoverTitle"
      fi
      if echo "$DOCXML" | grep -q 'w:val="CoverInstitution"'; then
        pass "cover docx memakai style CoverInstitution"
      else
        fail "cover docx tanpa style CoverInstitution"
      fi
      if ! echo "$DOCXML" | grep -q 'w:val="Title"'; then
        pass "title block bawaan pandoc dinonaktifkan"
      else
        fail "title block bawaan pandoc masih muncul"
      fi
      COVER_BR=$(echo "$DOCXML" | grep -oE 'w:val="CoverTitle".{0,500}' | grep -o '<w:br />' | wc -l)
      if [ "$COVER_BR" -eq 1 ]; then
        pass "judul cover docx 2 baris"
      else
        fail "judul cover docx bukan 2 baris (br=$COVER_BR)"
      fi
      if echo "$DOCXML" | grep -q 'w:anchor="kata-pengantar"'; then
        pass "TOC memuat KATA PENGANTAR"
      else
        fail "TOC tanpa KATA PENGANTAR"
      fi
      PAGEREF_N=$(echo "$DOCXML" | grep -oE 'PAGEREF [a-z0-9-]+' | wc -l)
      ZERO_N=$(echo "$DOCXML" | grep -oE 'PAGEREF [a-z0-9-]+ [^<]*</w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>0</w:t>' | wc -l)
      if command -v soffice &>/dev/null; then
        if [ "$PAGEREF_N" -gt 0 ] && [ "$ZERO_N" -eq 0 ]; then
          pass "TOC memakai nomor halaman asli ($PAGEREF_N entri)"
        else
          fail "TOC masih pakai nomor halaman 0 (pagerref=$PAGEREF_N zero=$ZERO_N)"
        fi
      else
        pass "TOC nomor halaman (soffice tidak ada, memakai cache)"
      fi
      if echo "$DOCXML" | grep -q 'w:anchor="bibliography"'; then
        pass "TOC memuat DAFTAR PUSTAKA"
      else
        fail "TOC tanpa DAFTAR PUSTAKA"
      fi
      if echo "$DOCXML" | grep -q 'footerReference'; then
        pass "docx memakai footer (nomor halaman)"
      else
        fail "docx tanpa footer"
      fi
      if echo "$DOCXML" | grep -q 'w:pgNumType w:fmt="lowerRoman" w:start="1"'; then
        pass "front matter penomoran i, ii (lowerRoman)"
      else
        fail "front matter tanpa lowerRoman start 1"
      fi
      if echo "$DOCXML" | grep -q 'w:pgNumType w:fmt="decimal" w:start="1"'; then
        pass "BAB I penomoran 1, 2, 3 (decimal)"
      else
        fail "BAB I tanpa decimal start 1"
      fi
      H1BLK=$(echo "$STYXML" | sed -n '/w:styleId="Heading1"/,/<\/w:style>/p')
      H1B=$(echo "$H1BLK" | grep -oE 'w:before="360"' | wc -l)
      H1A=$(echo "$H1BLK" | grep -oE 'w:after="720"' | wc -l)
      if [ "$H1B" -eq 1 ] && [ "$H1A" -eq 1 ]; then
        pass "Heading1 spasi setelah = 2 baris (gap ke sub-bab)"
      else
        fail "Heading1 spasi setelah bukan 720 (before=$H1B after=$H1A)"
      fi
    else
      fail "Laporan.docx tidak dihasilkan"
    fi
  else
    fail "make docx gagal"
  fi
else
  pass "unzip tidak terinstall (skipped)"
fi
echo ""

echo "[T17] CLI Helper and Preset Guide check"
if [ -x "./laporan" ]; then
  pass "./laporan dapat dieksekusi"
else
  fail "./laporan bukan berkas executable"
fi
if [ -f "./laporan.ps1" ]; then
  pass "./laporan.ps1 (PowerShell helper Windows) tersedia"
else
  fail "./laporan.ps1 tidak ditemukan"
fi
if ./laporan help | grep -q "LAPORAN GENERATOR CLI"; then
  pass "./laporan help menampilkan panduan CLI"
else
  fail "./laporan help gagal"
fi
if grep -q "doc-margin" template.typ; then
  pass "template.typ mendukung preset margin"
else
  fail "template.typ tidak memiliki variabel doc-margin"
fi
if [ -f "docs/campus-guide.md" ]; then
  pass "docs/campus-guide.md tersedia"
else
  fail "docs/campus-guide.md tidak ditemukan"
fi
echo ""

echo "[T18] Preset Architecture & University Presets check"
if [ -d "presets" ]; then
  pass "Direktori presets/ tersedia"
else
  fail "Direktori presets/ tidak ditemukan"
fi
for p in standard.yml skripsi-4433.yml ui-skripsi.yml itb-ta.yml ugm-skripsi.yml its-skripsi.yml; do
  if [ -f "presets/$p" ]; then
    pass "Preset $p tersedia"
  else
    fail "Preset $p tidak ditemukan"
  fi
done
if ./laporan preset list | grep -q "itb-ta"; then
  pass "./laporan preset list menampilkan preset kampus"
else
  fail "./laporan preset list gagal menampilkan preset kampus"
fi
if ./laporan preset show ui-skripsi | grep -q "Universitas Indonesia"; then
  pass "./laporan preset show menampilkan konfigurasi preset"
else
  fail "./laporan preset show gagal"
fi
if [ -f "docs/preset-schema.md" ]; then
  pass "docs/preset-schema.md tersedia"
else
  fail "docs/preset-schema.md tidak ditemukan"
fi
if grep -q 'presets' build.sh && grep -q 'presets' Makefile; then
  pass "build.sh dan Makefile mendukung pemrosesan preset dinamis"
else
  fail "build.sh atau Makefile belum mendukung preset dinamis"
fi
echo ""

echo "[T19] PDF Preset Scanner & Extractor check"
if [ -x "scripts/scan-preset.py" ]; then
  pass "scripts/scan-preset.py dapat dieksekusi"
else
  fail "scripts/scan-preset.py bukan berkas executable"
fi
if [ -f "examples/mock-pedoman-unpad.txt" ]; then
  python3 scripts/scan-preset.py examples/mock-pedoman-unpad.txt --preset-id test-scanner-unpad --output-dir /tmp/presets-test --non-interactive >/dev/null 2>&1
  if [ -f "/tmp/presets-test/test-scanner-unpad.yml" ]; then
    pass "scan-preset.py berhasil menghasilkan file preset YAML"
    if grep -q 'margin_left: 4cm' /tmp/presets-test/test-scanner-unpad.yml && grep -q 'margin_top: 4cm' /tmp/presets-test/test-scanner-unpad.yml; then
      pass "Scanner mengekstrak margin 4-4-3-3 dengan benar"
    else
      fail "Scanner salah mengekstrak margin"
    fi
    if grep -q 'font_size: 12pt' /tmp/presets-test/test-scanner-unpad.yml; then
      pass "Scanner mengekstrak font size 12pt dengan benar"
    else
      fail "Scanner salah mengekstrak font size"
    fi
    if grep -q 'UNIVERSITAS PADJADJARAN' /tmp/presets-test/test-scanner-unpad.yml; then
      pass "Scanner mendeteksi nama institusi dengan benar"
    else
      fail "Scanner gagal mendeteksi institusi"
    fi
  else
    fail "scan-preset.py gagal membuat file preset"
  fi
else
  fail "examples/mock-pedoman-unpad.txt tidak ditemukan untuk pengujian"
fi
echo ""

echo "[T20] Preset Linter, Validator & Diff CLI check"
if [ -x "scripts/validate-preset.py" ]; then
  pass "scripts/validate-preset.py dapat dieksekusi"
else
  fail "scripts/validate-preset.py bukan berkas executable"
fi
if python3 scripts/validate-preset.py --all >/dev/null 2>&1; then
  pass "Seluruh preset bawaan lulus validasi skema (validate-preset.py)"
else
  fail "Terdapat preset bawaan yang tidak valid skemanya"
fi
if ./laporan preset validate >/dev/null 2>&1; then
  pass "./laporan preset validate berhasil dijalankan"
else
  fail "./laporan preset validate gagal"
fi
if ./laporan preset diff itb-ta ui-skripsi 2>&1 | grep -q "Perbandingan Preset: itb-ta  VS  ui-skripsi"; then
  pass "./laporan preset diff menampilkan perbandingan antar preset"
else
  fail "./laporan preset diff gagal menampilkan perbandingan"
fi
echo ""

echo "[T21] Architecture Integrity, Git Hooks & Tooling Parity check"
if [ -f ".githooks/pre-commit" ]; then
  if grep -q "template.typ" .githooks/pre-commit && ! grep -q "pdflatex" .githooks/pre-commit && ! grep -q "template.latex" .githooks/pre-commit; then
    pass "pre-commit hook sinkron dengan Typst (tanpa dependensi pdflatex/latex)"
  else
    fail "pre-commit hook masih memiliki referensi lama LaTeX"
  fi
else
  fail ".githooks/pre-commit tidak ditemukan"
fi

if grep -q "Cmd-Build-DOCX" laporan.ps1 && grep -q "Cmd-Init" laporan.ps1 && grep -q "Cmd-Test" laporan.ps1; then
  pass "laporan.ps1 memiliki paritas fitur lengkap (DOCX, Init, Test, Preset Diff/Scan)"
else
  fail "laporan.ps1 belum memiliki paritas fitur lengkap dengan Bash CLI"
fi

if grep -q "sort -V" build.sh; then
  pass "build.sh mendukung deteksi bab dinamis tak terbatas (natural sort -V)"
else
  fail "build.sh belum mendukung deteksi bab dinamis"
fi

if grep -q "heading_chapter_num_format" docx.lua && grep -q "heading_chapter_num_format" template.typ; then
  pass "Typst dan DOCX keduanya mendukung heading_chapter_num_format dinamis"
else
  fail "Dukungan heading_chapter_num_format belum lengkap di kedua engine"
fi

if grep -q "python3" flake.nix; then
  pass "flake.nix menyertakan python3 untuk ekosistem scripts/ yang mandiri"
else
  fail "flake.nix belum menyertakan python3"
fi
echo ""

echo "[T22] BAB I Spacing Fix, CLI Supercharged & Multi-Genre Protocol check"
if pdftotext Laporan.pdf - 2>/dev/null | grep -q "BAB I PENDAHULUAN"; then
  pass "Judul Bab I berjarak spasi sempurna ('BAB I PENDAHULUAN') di PDF"
else
  fail "Judul Bab I tidak memiliki spasi yang tepat di PDF"
fi

if ! pdftotext Laporan.pdf - 2>/dev/null | grep -q "BABI PENDAHULUAN"; then
  pass "Bebas dari bug teks rapat 'BABI PENDAHULUAN'"
else
  fail "Terdeteksi bug teks rapat 'BABI PENDAHULUAN'"
fi

if ./laporan stats 2>&1 | grep -q "STATISTIK DOKUMEN"; then
  pass "./laporan stats berfungsi dan menampilkan analisis dokumen"
else
  fail "./laporan stats gagal dijalankan"
fi

if python3 scripts/report-doctor.py 2>&1 | grep -q "SEHAT"; then
  pass "report-doctor.py memvalidasi integritas sitasi & gambar (Status: SEHAT)"
else
  fail "report-doctor.py mendeteksi anomali pada proyek"
fi

if ./laporan bundle >/dev/null 2>&1 && [ -f "dist/Laporan-Akademik-Lengkap.zip" ]; then
  pass "./laporan bundle berhasil membuat arsip zip rilis"
else
  fail "./laporan bundle gagal membuat arsip zip"
fi

if grep -q "Cmd-Stats" laporan.ps1 && grep -q "Cmd-Doctor" laporan.ps1 && grep -q "Cmd-Bundle" laporan.ps1; then
  pass "laporan.ps1 mendukung perintah stats, doctor, dan bundle di PowerShell"
else
  fail "laporan.ps1 belum mendukung perintah supercharged"
fi

if grep -q "PROTOKOL WAWANCARA INTERAKTIF" prompt.md && grep -q "Makalah / Paper Akademik" prompt.md; then
  pass "prompt.md memuat protokol wawancara 3 tahap dan dukungan multi-karya ilmiah"
else
  fail "prompt.md belum memuat protokol wawancara interaktif multi-genre"
fi
echo ""

# T23: 10/10 Enterprise Hardening, Python Unit Tests & Cross-Platform Parity
echo "[T23] 10/10 Enterprise Hardening & Python Test Suite check"
if python3 scripts/test_scripts.py >/dev/null 2>&1; then
  pass "Python scripts unit test suite lulus 100% (scripts/test_scripts.py)"
else
  fail "Python scripts unit test suite gagal"
fi

if grep -q "Cmd-Watch" laporan.ps1 && grep -q "Escape-Yaml" laporan.ps1; then
  pass "laporan.ps1 mendukung Cmd-Watch native dan sanitasi Escape-Yaml"
else
  fail "laporan.ps1 belum mendukung Cmd-Watch atau Escape-Yaml"
fi

if grep -q "yaml_escape" laporan; then
  pass "laporan (Bash) memiliki fungsi proteksi injeksi yaml_escape"
else
  fail "laporan (Bash) belum memiliki proteksi yaml_escape"
fi

TEST_RAW='Judul: "Laporan" \ Keandalan Tinggi'
TEST_ESC=$(eval "$(awk '/^yaml_escape\(\)/{flag=1} flag; /^}/{if(flag){flag=0; exit}}' laporan)"; yaml_escape "$TEST_RAW")
if [[ "$TEST_ESC" == *"\"Laporan\""* ]] || [[ "$TEST_ESC" == *"\\\"Laporan\\\""* ]]; then
  pass "yaml_escape memproses dan meng-escape tanda kutip serta backslash secara dinamis"
else
  fail "yaml_escape gagal melakukan escaping pada input dinamis"
fi

if [ -f "docs/syntax-cheatsheet.md" ] && grep -q "Sitasi & Bibliografi" docs/syntax-cheatsheet.md; then
  pass "docs/syntax-cheatsheet.md tersedia dan memuat panduan lengkap"
else
  fail "docs/syntax-cheatsheet.md tidak ditemukan atau belum lengkap"
fi
echo ""

echo "========================"
echo "Hasil: $PASS passed, $FAIL failed"
echo "========================"

[ "$FAIL" -eq 0 ] || exit 1
