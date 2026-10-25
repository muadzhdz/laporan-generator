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
    pos_args = [a for a in sys.argv[1:] if not a.startswith("-")]

    orig_cwd = os.getcwd()
    target_dir = orig_cwd
    if pos_args:
        target_dir = os.path.abspath(pos_args[0])
    elif not (os.path.isfile(os.path.join(target_dir, "metadata.yml")) or os.path.isdir(os.path.join(target_dir, "chapters"))):
        pkg_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        tpl_dir = os.path.join(pkg_root, "templates", "default")
        if os.path.isfile(os.path.join(tpl_dir, "metadata.yml")):
            target_dir = tpl_dir
        elif os.path.isfile(os.path.join(pkg_root, "metadata.yml")):
            target_dir = pkg_root

    pkg_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    os.chdir(target_dir)

    print(f"{CYAN}{BOLD}")
    print("  ========================================================")
    print("             LAPORAN GENERATOR - BUNDLE PACKAGER          ")
    print("  ========================================================")
    print(f"{NC}")

    # Cek apakah PDF & DOCX sudah ada
    if not os.path.isfile("Laporan.pdf") or not os.path.isfile("Laporan.docx"):
        print(f"  {BLUE}[1/3] Menjalankan build PDF dan DOCX...{NC}")
        import subprocess
        sh_pdf = "build.sh" if os.path.isfile("build.sh") else os.path.join(pkg_root, "build.sh")
        sh_docx = "build-docx.sh" if os.path.isfile("build-docx.sh") else os.path.join(pkg_root, "build-docx.sh")
        ps_script = "laporan.ps1" if os.path.isfile("laporan.ps1") else os.path.join(pkg_root, "laporan.ps1")
        if sys.platform == "win32":
            ret = subprocess.run(["powershell", "-ExecutionPolicy", "Bypass", "-File", ps_script, "build"]).returncode
        else:
            ret_pdf = subprocess.run(["bash", sh_pdf]).returncode
            ret_docx = subprocess.run(["bash", sh_docx]).returncode
            ret = ret_pdf or ret_docx
        if ret != 0:
            print("Gagal mengompilasi dokumen untuk bundling.")
            return 1
    else:
        print(f"  {GREEN}[OK]{NC} Berkas Laporan.pdf dan Laporan.docx siap dikemas.")

    out_dirs = [os.path.join(target_dir, "dist")]
    if orig_cwd != target_dir:
        out_dirs.append(os.path.join(orig_cwd, "dist"))

    for od in out_dirs:
        os.makedirs(od, exist_ok=True)
    zip_path = os.path.join(out_dirs[0], "Laporan-Akademik-Lengkap.zip")

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

    import shutil
    for od in out_dirs[1:]:
        shutil.copy2(zip_path, os.path.join(od, "Laporan-Akademik-Lengkap.zip"))

    total_sz = os.path.getsize(zip_path) / 1024
    print("")
    print(f"  {GREEN}{BOLD}[3/3] BUNDLE SELESAI DIBUAT!{NC}")
    print(f"  * Lokasi Arsip : {CYAN}{BOLD}{os.path.abspath(zip_path)}{NC}")
    print(f"  * Ukuran Arsip : {total_sz:.1f} KB ({len(files_to_pack)} berkas)")
    print("  ========================================================")
    return 0


if __name__ == "__main__":
    sys.exit(main())
