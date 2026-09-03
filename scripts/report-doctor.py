#!/usr/bin/env python3
"""report-doctor.py: Audit komprehensif kesehatan dan integritas proyek laporan."""

import glob
import os
import re
import shutil
import sys

GREEN = "\033[0;32m"
BLUE = "\033[0;34m"
CYAN = "\033[0;36m"
YELLOW = "\033[1;33m"
RED = "\033[0;31m"
BOLD = "\033[1m"
NC = "\033[0m"


def check_dependencies():
    tools = [
        ("pandoc", "Pandoc Document Engine", True),
        ("typst", "Typst Typesetting Engine", True),
        ("python3", "Python 3 Runtime", True),
        ("magick", "ImageMagick 7", False),
        ("convert", "ImageMagick 6", False),
        ("pdftotext", "Poppler PDF Utils", False),
        ("soffice", "LibreOffice", False),
    ]

    results = []
    has_im = False
    for cmd, name, req in tools:
        found = shutil.which(cmd) is not None
        if "ImageMagick" in name and found:
            has_im = True
        results.append((cmd, name, req, found))

    return results, has_im


def check_citations(bib_path, markdown_files):
    bib_keys = set()
    if os.path.isfile(bib_path):
        with open(bib_path, "r", encoding="utf-8", errors="ignore") as f:
            bib_keys = set(re.findall(r"@\w+\s*\{\s*([a-zA-Z0-9_:-]+)\s*,", f.read()))

    cited_keys = {}
    for mf in markdown_files:
        with open(mf, "r", encoding="utf-8", errors="ignore") as f:
            for line_no, line in enumerate(f, 1):
                # Abaikan contoh dalam inline code
                clean_line = re.sub(r"`.*?`", "", line)
                matches = re.findall(r"@([a-zA-Z0-9_:-]+)", clean_line)
                for m in matches:
                    if m not in cited_keys:
                        cited_keys[m] = []
                    cited_keys[m].append((os.path.basename(mf), line_no))

    missing_keys = {}
    for key, locs in cited_keys.items():
        if key not in bib_keys:
            missing_keys[key] = locs

    orphan_keys = bib_keys - set(cited_keys.keys())

    return bib_keys, cited_keys, missing_keys, orphan_keys


def check_images(markdown_files):
    broken_images = []
    total_images = 0
    for mf in markdown_files:
        with open(mf, "r", encoding="utf-8", errors="ignore") as f:
            for line_no, line in enumerate(f, 1):
                clean_line = re.sub(r"`.*?`", "", line)
                matches = re.findall(r"!\[.*?\]\((.*?)\)", clean_line)
                for img_path in matches:
                    total_images += 1
                    clean_path = img_path.split()[0].strip("<>\"'")
                    if not os.path.isfile(clean_path):
                        broken_images.append((clean_path, os.path.basename(mf), line_no))
    return total_images, broken_images


def check_style_anomalies(markdown_files):
    anomalies = []
    box_draw_regex = re.compile(r"[┌─┐│└┘├┤┬┴┼═║╔╗╚╝╠╣╦╩╬]")
    manual_num_regex = re.compile(r"^#{2,4}\s+[0-9]+(\.[0-9]+)+")

    for mf in markdown_files:
        with open(mf, "r", encoding="utf-8", errors="ignore") as f:
            for line_no, line in enumerate(f, 1):
                if box_draw_regex.search(line):
                    anomalies.append((os.path.basename(mf), line_no, "Karakter box-drawing terdeteksi (gunakan tabel/ASCII)"))
                if manual_num_regex.search(line):
                    anomalies.append((os.path.basename(mf), line_no, f"Manual numbering di heading: '{line.strip()}'"))
    return anomalies


def main():
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    os.chdir(root)

    print(f"{CYAN}{BOLD}")
    print("  ========================================================")
    print("             LAPORAN GENERATOR - DOCTOR & AUDIT SUITE     ")
    print("  ========================================================")
    print(f"{NC}")

    errors = 0
    warnings = 0

    # 1. Dependensi
    print(f"  {BLUE}{BOLD}[1/4] Audit Toolchain & Dependensi Sistem{NC}")
    deps, has_im = check_dependencies()
    for cmd, name, req, found in deps:
        if "ImageMagick" in name:
            continue
        if found:
            print(f"    {GREEN}[OK]{NC} {name:<26}: Terpasang ({cmd})")
        else:
            if req:
                print(f"    {RED}[FAIL]{NC} {name:<24}: TIDAK DITEMUKAN (Wajib)")
                errors += 1
            else:
                print(f"    {YELLOW}[INFO]{NC} {name:<24}: Tidak ditemukan (Opsional)")

    if has_im:
        print(f"    {GREEN}[OK]{NC} {'ImageMagick':<26}: Terpasang")
    else:
        print(f"    {YELLOW}[INFO]{NC} {'ImageMagick':<24}: Tidak ditemukan (Opsional untuk kompresi gambar)")
    print("")

    # 2. Berkas & Struktur
    print(f"  {BLUE}{BOLD}[2/4] Audit Struktur Direktori & Berkas Wajib{NC}")
    req_files = [
        "metadata.yml", "template.typ", "reference.docx",
        "references.bib", "docx.lua", "cover.md"
    ]
    for rf in req_files:
        if os.path.isfile(rf):
            print(f"    {GREEN}[OK]{NC} Berkas {rf}")
        else:
            print(f"    {RED}[FAIL]{NC} Berkas {rf} TIDAK DITEMUKAN")
            errors += 1

    chapter_files = sorted(glob.glob("chapters/*.md"))
    if chapter_files:
        print(f"    {GREEN}[OK]{NC} Direktori chapters/ ({len(chapter_files)} bab ditemukan)")
    else:
        print(f"    {RED}[FAIL]{NC} Tidak ada berkas markdown di chapters/")
        errors += 1
    print("")

    # 3. Sitasi & Referensi
    print(f"  {BLUE}{BOLD}[3/4] Audit Sitasi & Integritas Bibliografi{NC}")
    bib_keys, cited_keys, missing_keys, orphan_keys = check_citations("references.bib", chapter_files)
    print(f"    * Total entri .bib     : {len(bib_keys)}")
    print(f"    * Total sitasi di teks : {len(cited_keys)}")

    if missing_keys:
        for k, locs in missing_keys.items():
            loc_str = ", ".join([f"{f}:{l}" for f, l in locs])
            print(f"    {RED}[ERROR]{NC} Sitasi '@{k}' TIDAK DITEMUKAN di references.bib ({loc_str})")
            errors += 1
    else:
        print(f"    {GREEN}[OK]{NC} Semua sitasi dalam teks valid terdaftar di references.bib")

    if orphan_keys:
        print(f"    {YELLOW}[WARN]{NC} {len(orphan_keys)} entri di references.bib belum disitir dalam teks:")
        for ok in list(orphan_keys)[:5]:
            print(f"      - @{ok}")
        if len(orphan_keys) > 5:
            print(f"      - ... dan {len(orphan_keys) - 5} lainnya")
        warnings += 1
    print("")

    # 4. Gambar & Format Teks
    print(f"  {BLUE}{BOLD}[4/4] Audit Media Citra & Anomali Tipografi{NC}")
    total_imgs, broken_imgs = check_images(chapter_files)
    if broken_imgs:
        for p, f, l in broken_imgs:
            print(f"    {RED}[ERROR]{NC} Berkas gambar tidak ditemukan: '{p}' (di {f}:{l})")
            errors += 1
    else:
        print(f"    {GREEN}[OK]{NC} Semua tautan gambar ({total_imgs} gambar) valid dan ada di disk")

    anomalies = check_style_anomalies(chapter_files)
    if anomalies:
        for f, l, msg in anomalies:
            print(f"    {YELLOW}[WARN]{NC} {f}:{l} - {msg}")
            warnings += 1
    else:
        print(f"    {GREEN}[OK]{NC} Bebas dari manual heading numbering dan box-drawing characters")
    print("")

    # Skor Kesehatan
    print("  ========================================================")
    if errors == 0 and warnings == 0:
        print(f"  {GREEN}{BOLD}STATUS: SEHAT SEMPURNA (100/100) - SIAP DIPUBLIKASIKAN!{NC}")
    elif errors == 0:
        print(f"  {YELLOW}{BOLD}STATUS: SEHAT DENGAN CATATAN (95/100) - {warnings} Peringatan Terdeteksi{NC}")
    else:
        print(f"  {RED}{BOLD}STATUS: DITEMUKAN MASALAH - {errors} Error, {warnings} Warning{NC}")
    print("  ========================================================")

    return 1 if errors > 0 else 0


if __name__ == "__main__":
    sys.exit(main())
