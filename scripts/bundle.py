#!/usr/bin/env python3
"""bundle.py: Mengemas hasil laporan PDF, DOCX, dan sumber Markdown menjadi arsip rilis zip."""

import glob
import os
import shutil
import sys
import zipfile

GREEN = "\033[0;32m"
BLUE = "\033[0;34m"
CYAN = "\033[0;36m"
BOLD = "\033[1m"
NC = "\033[0m"


def main():
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    os.chdir(root)

    print(f"{CYAN}{BOLD}")
    print("  ========================================================")
    print("             LAPORAN GENERATOR - BUNDLE PACKAGER          ")
    print("  ========================================================")
    print(f"{NC}")

    # Cek apakah PDF & DOCX sudah ada
    if not os.path.isfile("Laporan.pdf") or not os.path.isfile("Laporan.docx"):
        print(f"  {BLUE}[1/3] Menjalankan build PDF dan DOCX...{NC}")
        ret = os.system("./build.sh && make docx")
        if ret != 0:
            print("Gagal mengompilasi dokumen untuk bundling.")
            return 1
    else:
        print(f"  {GREEN}[OK]{NC} Berkas Laporan.pdf dan Laporan.docx siap dikemas.")

    out_dir = "dist"
    os.makedirs(out_dir, exist_ok=True)
    zip_path = os.path.join(out_dir, "Laporan-Akademik-Lengkap.zip")

    files_to_pack = [
        "Laporan.pdf",
        "Laporan.docx",
        "metadata.yml",
        "references.bib",
        "cover.md",
    ]

    for f in glob.glob("chapters/*.md"):
        files_to_pack.append(f)

    if os.path.isdir("gambar"):
        for f in glob.glob("gambar/**/*", recursive=True):
            if os.path.isfile(f):
                files_to_pack.append(f)

    print(f"  {BLUE}[2/3] Mengompresi berkas ke dalam {zip_path}...{NC}")
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
        for f in files_to_pack:
            if os.path.isfile(f):
                zf.write(f, arcname=f)
                sz = os.path.getsize(f) / 1024
                print(f"    + {f:<30} ({sz:.1f} KB)")

    total_sz = os.path.getsize(zip_path) / 1024
    print("")
    print(f"  {GREEN}{BOLD}[3/3] BUNDLE SELESAI DIBUAT!{NC}")
    print(f"  * Lokasi Arsip : {CYAN}{BOLD}{os.path.abspath(zip_path)}{NC}")
    print(f"  * Ukuran Arsip : {total_sz:.1f} KB ({len(files_to_pack)} berkas)")
    print("  ========================================================")
    return 0


if __name__ == "__main__":
    sys.exit(main())
