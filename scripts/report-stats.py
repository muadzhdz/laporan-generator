#!/usr/bin/env python3
"""report-stats.py: Menghitung statistik komprehensif dokumen laporan akademik."""

import glob
import os
import re
import sys

GREEN = "\033[0;32m"
BLUE = "\033[0;34m"
CYAN = "\033[0;36m"
YELLOW = "\033[1;33m"
BOLD = "\033[1m"
NC = "\033[0m"


def count_file_stats(filepath):
    with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()

    clean_text = re.sub(r"```.*?```", "", content, flags=re.S)
    clean_text = re.sub(r"<!--.*?-->", "", clean_text, flags=re.S)
    clean_text = re.sub(r"[#*_`~>|]", " ", clean_text)
    words = clean_text.split()

    h1 = len(re.findall(r"^#[^#].*$", content, re.M))
    h2 = len(re.findall(r"^##[^#].*$", content, re.M))
    h3 = len(re.findall(r"^###[^#].*$", content, re.M))

    images = len(re.findall(r"!\[.*?\]\(.*?\)", content))
    tables = len(re.findall(r"^\|.*\|[ \t]*$", content, re.M))
    equations = len(re.findall(r"\$\$.*?\$\$", content, re.S)) + len(
        re.findall(r"(?<!\$)\$(?!\$).+?(?<!\$)\$(?!\$)", content)
    )
    citations = re.findall(r"@([a-zA-Z0-9_:-]+)", content)

    return {
        "words": len(words),
        "chars": len(content),
        "h1": h1,
        "h2": h2,
        "h3": h3,
        "images": images,
        "tables": max(0, tables // 3),
        "equations": equations,
        "citations": citations,
    }


def main():
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    os.chdir(root)

    title = "Laporan Akademik"
    preset = "standard"

    if os.path.isfile("metadata.yml"):
        with open("metadata.yml", "r", encoding="utf-8") as f:
            for line in f:
                if line.startswith("title:"):
                    title = line.split(":", 1)[1].strip().strip('"\'')
                elif line.startswith("preset:"):
                    preset = line.split(":", 1)[1].strip().strip('"\'')

    chapter_files = sorted(glob.glob("chapters/*.md"))
    all_files = (["cover.md"] if os.path.isfile("cover.md") else []) + chapter_files

    total_words = 0
    total_chars = 0
    total_h1 = 0
    total_h2 = 0
    total_h3 = 0
    total_images = 0
    total_tables = 0
    total_equations = 0
    all_citations = set()

    file_breakdown = []

    for f in all_files:
        if os.path.isfile(f):
            st = count_file_stats(f)
            total_words += st["words"]
            total_chars += st["chars"]
            total_h1 += st["h1"]
            total_h2 += st["h2"]
            total_h3 += st["h3"]
            total_images += st["images"]
            total_tables += st["tables"]
            total_equations += st["equations"]
            all_citations.update(st["citations"])
            file_breakdown.append((os.path.basename(f), st["words"]))

    bib_count = 0
    if os.path.isfile("references.bib"):
        with open("references.bib", "r", encoding="utf-8") as f:
            bib_count = len(re.findall(r"@\w+\s*\{", f.read()))

    est_pages = max(1, round(total_words / 280))
    read_mins = max(1, round(total_words / 200))

    pdf_size = "-"
    if os.path.isfile("Laporan.pdf"):
        sz = os.path.getsize("Laporan.pdf")
        pdf_size = f"{sz / 1024:.1f} KB"

    docx_size = "-"
    if os.path.isfile("Laporan.docx"):
        sz = os.path.getsize("Laporan.docx")
        docx_size = f"{sz / 1024:.1f} KB"

    print(f"{CYAN}{BOLD}")
    print("  ========================================================")
    print("                 LAPORAN GENERATOR - STATISTIK DOKUMEN    ")
    print("  ========================================================")
    print(f"{NC}")
    print(f"  {BOLD}Judul Laporan    :{NC} {title}")
    print(f"  {BOLD}Preset Aktif     :{NC} {preset}")
    print(f"  {BOLD}Total Berkas Bab :{NC} {len(chapter_files)} berkas")
    print("")
    print(f"  {BLUE}{BOLD}[Metrik Konten]{NC}")
    print(f"  * Total Kata            : {GREEN}{BOLD}{total_words:,}{NC} kata")
    print(f"  * Total Karakter        : {total_chars:,} karakter")
    print(f"  * Estimasi Halaman      : {CYAN}{BOLD}~{est_pages}{NC} halaman (standar A4 1.5 spasi)")
    print(f"  * Estimasi Durasi Baca  : ~{read_mins} menit")
    print("")
    print(f"  {BLUE}{BOLD}[Struktur & Elemen Akademik]{NC}")
    print(f"  * Bab Utama (Heading 1) : {total_h1}")
    print(f"  * Sub-Bab (Heading 2)   : {total_h2}")
    print(f"  * Sub-Sub-Bab (Heading 3): {total_h3}")
    print(f"  * Gambar / Diagram      : {total_images}")
    print(f"  * Tabel Terdeteksi      : {total_tables}")
    print(f"  * Persamaan Matematika  : {total_equations}")
    print(f"  * Sitasi Digunakan      : {len(all_citations)} sitasi unik")
    print(f"  * Entri Daftar Pustaka  : {bib_count} referensi di .bib")
    print("")
    print(f"  {BLUE}{BOLD}[Ukuran Berkas Terkompilasi]{NC}")
    print(f"  * Laporan.pdf           : {pdf_size}")
    print(f"  * Laporan.docx          : {docx_size}")
    print("")
    print(f"  {BLUE}{BOLD}[Rincian Kata per Berkas]{NC}")
    for fname, cnt in file_breakdown:
        bar = "■" * max(1, min(25, cnt // 100))
        print(f"  {fname:<28} : {cnt:>5} kata {CYAN}{bar}{NC}")
    print("  ========================================================")


if __name__ == "__main__":
    main()
