#!/usr/bin/env bash
# setup-deps.sh: Universal Dependency Installer untuk Linux & macOS
# Mendukung: apt (Debian/Ubuntu), pacman (Arch), dnf (Fedora), brew (macOS), nix, dan docker

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${CYAN}${BOLD}==========================================================${NC}"
echo -e "${CYAN}${BOLD}   LAPORAN GENERATOR - DEPENDENCY SETUP (LINUX/MAC)       ${NC}"
echo -e "${CYAN}${BOLD}==========================================================${NC}"
echo ""

# 1. Cek dependensi saat ini
has_cmd() { command -v "$1" >/dev/null 2>&1; }

echo -e "${YELLOW}[1/3] Memeriksa dependensi sistem...${NC}"
missing=()

if has_cmd typst; then
    echo -e "  ${GREEN}[OK]${NC} Typst Engine: $(typst --version 2>/dev/null || echo 'terpasang')"
else
    echo -e "  ${RED}[MISSING]${NC} Typst Engine belum terpasang."
    missing+=("typst")
fi

if has_cmd pandoc; then
    echo -e "  ${GREEN}[OK]${NC} Pandoc Converter: $(pandoc --version 2>/dev/null | head -n1 || echo 'terpasang')"
else
    echo -e "  ${RED}[MISSING]${NC} Pandoc Converter belum terpasang."
    missing+=("pandoc")
fi

if has_cmd magick || has_cmd convert; then
    echo -e "  ${GREEN}[OK]${NC} ImageMagick terpasang."
else
    echo -e "  ${RED}[MISSING]${NC} ImageMagick belum terpasang."
    missing+=("imagemagick")
fi

if [ ${#missing[@]} -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✔ Semua dependensi utama sudah lengkap dan siap digunakan!${NC}"
    exit 0
fi

echo ""
echo -e "${YELLOW}[2/3] Memasang dependensi: ${missing[*]}...${NC}"

# Deteksi OS / Package Manager
if [[ "$OSTYPE" == "darwin"* ]]; then
    if has_cmd brew; then
        echo -e "${CYAN}--> Menggunakan Homebrew (macOS)...${NC}"
        brew install typst pandoc imagemagick
    else
        echo -e "${RED}[ERROR] Homebrew tidak ditemukan. Silakan pasang brew (https://brew.sh) terlebih dahulu.${NC}"
        exit 1
    fi
elif has_cmd nix; then
    echo -e "${CYAN}--> Lingkungan Nix terdeteksi! Kamu bisa langsung menjalankan:${NC}"
    echo -e "    ${BOLD}nix develop${NC}"
    echo -e "    Semua dependensi sudah otomatis terisolasi di flake.nix."
    exit 0
elif has_cmd apt-get; then
    echo -e "${CYAN}--> Menggunakan apt-get (Debian/Ubuntu)...${NC}"
    sudo apt-get update -qq
    sudo apt-get install -y imagemagick poppler-utils xz-utils unzip wget
    
    # Install pandoc deb terbaru jika belum ada
    if ! has_cmd pandoc; then
        echo -e "--> Mengunduh Pandoc official deb..."
        PANDOC_URL="https://github.com/jgm/pandoc/releases/download/3.7.0.2/pandoc-3.7.0.2-1-amd64.deb"
        wget -q "$PANDOC_URL" -O /tmp/pandoc.deb
        sudo dpkg -i /tmp/pandoc.deb
        rm -f /tmp/pandoc.deb
    fi

    # Install typst binary jika belum ada
    if ! has_cmd typst; then
        echo -e "--> Mengunduh Typst standalone binary..."
        ARCH=$(uname -m)
        if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
            TYPST_DIR="typst-aarch64-unknown-linux-musl"
        else
            TYPST_DIR="typst-x86_64-unknown-linux-musl"
        fi
        TYPST_URL="https://github.com/typst/typst/releases/download/v0.15.1/${TYPST_DIR}.tar.xz"
        wget -q "$TYPST_URL" -O /tmp/typst.tar.xz
        tar -xJf /tmp/typst.tar.xz -C /tmp
        sudo mv "/tmp/${TYPST_DIR}/typst" /usr/local/bin/typst
        rm -rf /tmp/typst.tar.xz "/tmp/${TYPST_DIR}"
    fi
elif has_cmd pacman; then
    echo -e "${CYAN}--> Menggunakan pacman (Arch Linux)...${NC}"
    sudo pacman -S --noconfirm typst pandoc imagemagick
elif has_cmd dnf; then
    echo -e "${CYAN}--> Menggunakan dnf (Fedora)...${NC}"
    sudo dnf install -y typst pandoc ImageMagick
else
    echo -e "${YELLOW}[WARN] Package manager native tidak dikenali.${NC}"
    echo -e "Kamu dapat menggunakan Docker container bawaan:"
    echo -e "    ${BOLD}docker run --rm -v \"\$(pwd):/workspace\" muadzhdz/laporan-generator${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}[3/3] Memverifikasi instalasi...${NC}"
if has_cmd typst && has_cmd pandoc; then
    echo -e "${GREEN}==========================================================${NC}"
    echo -e "${GREEN}   PEMASANGAN SELESAI! SEMUA DEPENDENSI SIAP PAKAI!       ${NC}"
    echo -e "${GREEN}==========================================================${NC}"
else
    echo -e "${RED}[WARN] Beberapa dependensi belum terdeteksi di PATH.${NC}"
fi
