#!/usr/bin/env python3
"""Isi nilai halaman asli ke field PAGEREF di daftar isi DOCX.

Dua-pass:
  1. Render DOCX (yang sudah di-finalize section-nya) via LibreOffice
     (soffice --headless) menjadi PDF.
  2. Baca nomor halaman setiap heading dari teks PDF (footer per halaman),
     lalu tulis sebagai nilai cache PAGEREF di daftar isi.

Hasil: daftar isi menampilkan nomor halaman asli di aplikasi manapun
(Word, LibreOffice, Google Docs) tanpa perlu update field manual.

Kalau soffice/pdftotext tidak tersedia, output = input (Word tetap
memperbarui field saat dibuka karena updateFields=true).

Usage:
  python3 scripts/docx-pagenum.py input.docx output.docx
"""

import os
import re
import shutil
import subprocess
import sys
import tempfile
import zipfile

ROMAN = re.compile(r"^[ivxlcdm]+$", re.I)
DECIMAL = re.compile(r"^\d+$")


def page_count(pdf):
    out = subprocess.check_output(["pdfinfo", pdf], text=True, timeout=15)
    m = re.search(r"^Pages:\s+(\d+)", out, re.M)
    return int(m.group(1)) if m else 0


def page_texts(pdf):
    n = page_count(pdf)
    pages = {}
    for p in range(1, n + 1):
        out = subprocess.check_output(
            ["pdftotext", "-f", str(p), "-l", str(p), "-layout", pdf, "-"],
            text=True,
            timeout=15,
        )
        lines = [l.strip() for l in out.splitlines() if l.strip()]
        pages[p] = lines
    return pages


def footer_of(lines):
    if not lines:
        return ""
    return lines[-1]


def find_toc_start(pages):
    for p, lines in sorted(pages.items()):
        for l in lines:
            if l == "DAFTAR ISI":
                return p
    return None


def first_decimal_page(pages, start):
    for p, lines in sorted(pages.items()):
        if p <= start:
            continue
        if DECIMAL.match(footer_of(lines)):
            return p
    return None


def find_page(pages, needle, start, end):
    for p in range(start, end + 1):
        text = "\n".join(pages.get(p, []))
        if needle in text:
            return p
    return None


def parse_entries(doc):
    entries = []
    par_pat = re.compile(r"<w:p>(?:(?!</w:p>).)*?</w:p>", re.S)
    for pm in par_pat.finditer(doc):
        p = pm.group(0)
        m = re.search(
            r'<w:hyperlink w:anchor="([^"]+)"[^>]*>.*?<w:t[^>]*>([^<]*)</w:t>', p, re.S
        )
        r = re.search(
            r"<w:instrText[^>]*>\s*PAGEREF\s+(\S+)\s+\\h\s*</w:instrText>", p
        )
        if m and r and m.group(1) == r.group(1):
            entries.append((p, m.group(1), m.group(2)))
    return entries


def needle_of(entry_text):
    if entry_text.startswith("BAB "):
        parts = entry_text.split(" ", 2)
        return parts[2] if len(parts) == 3 else parts[1]
    return entry_text


def render_pdf(docx):
    tmp = tempfile.mkdtemp(prefix="lo_pagenum_")
    profile = os.path.join(tmp, "profile")
    subprocess.run(
        [
            "soffice", "--headless", "--norestore",
            "-env:UserInstallation=file://" + profile,
            "--convert-to", "pdf", "--outdir", tmp, docx,
        ],
        check=True,
        capture_output=True,
        timeout=45,
    )
    base = os.path.basename(docx).rsplit(".", 1)[0] + ".pdf"
    return os.path.join(tmp, base)


def main():
    src, dst = sys.argv[1], sys.argv[2]
    shutil.copy(src, dst)

    if not shutil.which("soffice") or not shutil.which("pdftotext"):
        print("[warn] docx-pagenum: soffice/pdftotext tidak ada, nomor halaman "
              "daftar isi memakai nilai cache (Word tetap update saat dibuka)")
        return

    with zipfile.ZipFile(src, "r") as zin:
        names = zin.namelist()
        items = {n: zin.read(n) for n in names}
    doc = items["word/document.xml"].decode("utf-8")

    try:
        pdf = render_pdf(src)
    except (subprocess.TimeoutExpired, subprocess.SubprocessError) as err:
        print(f"[warn] docx-pagenum: render LibreOffice gagal/timeout ({err}), nomor halaman memakai nilai cache default.")
        return

    try:
        pages = page_texts(pdf)
    except (subprocess.TimeoutExpired, subprocess.SubprocessError) as err:
        print(f"[warn] docx-pagenum: ekstraksi teks PDF gagal/timeout ({err}), nomor halaman memakai nilai cache default.")
        return
    finally:
        shutil.rmtree(os.path.dirname(pdf), ignore_errors=True)

    toc_start = find_toc_start(pages)
    if not toc_start:
        print("[warn] docx-pagenum: halaman DAFTAR ISI tidak ditemukan di render")
        return
    first_dec = first_decimal_page(pages, toc_start)
    if not first_dec:
        print("[warn] docx-pagenum: halaman body (decimal) tidak ditemukan")
        return

    entries = parse_entries(doc)
    injected = 0
    for para, pid, text in entries:
        if pid == "kata-pengantar":
            page = find_page(pages, "KATA PENGANTAR", 1, toc_start - 1)
        else:
            page = find_page(pages, needle_of(text), first_dec, max(pages))
        if not page:
            print(f"[warn] docx-pagenum: heading '{text}' tidak ditemukan di render")
            continue
        value = footer_of(pages[page])
        if not (ROMAN.match(value) or DECIMAL.match(value)):
            print(f"[warn] docx-pagenum: footer halaman {page} tidak valid: {value!r}")
            continue
        new_para = re.sub(
            r'(<w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t[^>]*>)[^<]*(</w:t>)',
            r"\g<1>" + value + r"\g<2>",
            para,
            count=1,
        )
        doc = doc.replace(para, new_para)
        injected += 1
        print(f"[OK] {text} -> halaman {page} (nomor {value})")

    items["word/document.xml"] = doc.encode("utf-8")
    with zipfile.ZipFile(dst, "w", zipfile.ZIP_DEFLATED) as zout:
        for n, content in items.items():
            zout.writestr(n, content)
    print(f"[OK] docx-pagenum: {injected} nomor halaman diisi -> {dst}")


if __name__ == "__main__":
    main()