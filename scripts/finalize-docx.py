#!/usr/bin/env python3
"""Finalisasi document.xml hasil pandoc agar penomoran halaman DOCX
mengikuti PDF:

  - Cover                  : tanpa nomor halaman (footerReference dihapus)
  - KATA PENGANTAR + ISI   : i, ii  (lowerRoman, start 1)
  - BAB I                  : 1, 2, 3 ...  (decimal, start 1)
  - BAB II dst + PUSTAKA   : lanjut (tanpa restart)

Pandoc otomatis menyisipkan paragraf `w:sectPr` (berisi footerReference
dari reference.docx) sebelum setiap Heading1. Script ini mengklasifikasikan
setiap sectPr berdasarkan heading berikutnya dan menyesuaikan isinya.

Usage:
  python3 scripts/finalize-docx.py input.docx output.docx
"""

import re
import sys
import zipfile

SECT_IN_PPR = re.compile(r"<w:pPr><w:sectPr>(.*?)</w:sectPr></w:pPr>", re.S)
FOOTER_REF = re.compile(r"<w:footerReference[^/]*/>")


def next_heading_text(doc, start):
    nxt = doc[start:]
    m = re.search(r'<w:pStyle w:val="Heading1"[^>]*/>', nxt)
    if not m:
        return ""
    hdr = nxt[m.end():]
    t = re.search(r"<w:t[^>]*>([^<]*)", hdr)
    return t.group(1) if t else ""


def classify(text, idx=0):
    if idx == 0:
        return "cover"
    t = text.strip()
    words = t.split()
    if len(words) >= 2 and words[0] == "BAB":
        if words[1] == "I":
            return "roman"
        if words[1] == "II":
            return "decimal-start"
    return "body"


def add_pgnum(sect, fmt, start):
    if "<w:pgNumType" in sect:
        return sect
    tag = f'<w:pgNumType w:fmt="{fmt}" w:start="{start}"/>'
    return sect + tag


def process(doc):
    matches = list(SECT_IN_PPR.finditer(doc))
    if not matches:
        return doc, 0
    out = []
    last = 0
    changed = 0
    for i, m in enumerate(matches):
        out.append(doc[last:m.start()])
        sect = m.group(1)
        kind = classify(next_heading_text(doc, m.end()), i)
        if kind == "cover":
            sect = FOOTER_REF.sub("", sect)
            changed += 1
        elif kind == "roman":
            sect = add_pgnum(sect, "lowerRoman", "1")
            changed += 1
        elif kind == "decimal-start":
            sect = add_pgnum(sect, "decimal", "1")
            changed += 1
        out.append(f"<w:pPr><w:sectPr>{sect}</w:sectPr></w:pPr>")
        last = m.end()
    out.append(doc[last:])
    return "".join(out), changed



def main():
    src = sys.argv[1]
    dst = sys.argv[2]

    with zipfile.ZipFile(src, "r") as zin:
        names = zin.namelist()
        items = {n: zin.read(n) for n in names}

    doc = items["word/document.xml"].decode("utf-8")
    new_doc, changed = process(doc)
    items["word/document.xml"] = new_doc.encode("utf-8")

    with zipfile.ZipFile(dst, "w", zipfile.ZIP_DEFLATED) as zout:
        for n in items:
            zout.writestr(n, items[n])

    print(f"[OK] finalize-docx: {changed} sectPr disesuaikan -> {dst}")


if __name__ == "__main__":
    main()