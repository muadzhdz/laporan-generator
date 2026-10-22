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

if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

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


def is_front_matter_heading(t):
    norm = t.strip().upper()
    return norm in (
        "LEMBAR PENGESAHAN",
        "HALAMAN PENGESAHAN",
        "KATA PENGANTAR",
        "PRAKATA",
        "ABSTRAK",
        "ABSTRACT",
        "DAFTAR ISI",
        "DAFTAR TABEL",
        "DAFTAR GAMBAR",
        "DAFTAR LAMPIRAN",
    )


def is_chapter_1(t):
    norm = t.strip().upper()
    if re.match(r"^BAB\s+(?:I|1|01)\b", norm):
        return True
    if re.match(r"^(?:1\.|1\s+|I\.)", norm):
        return True
    if norm.startswith("PENDAHULUAN"):
        return True
    return False


def is_chapter_2(t):
    norm = t.strip().upper()
    if re.match(r"^BAB\s+(?:II|2|02)\b", norm):
        return True
    if re.match(r"^(?:2\.|2\s+|II\.)", norm):
        return True
    if any(
        norm.startswith(k)
        for k in (
            "PEMBAHASAN",
            "TINJAUAN PUSTAKA",
            "LANDASAN TEORI",
            "METODOLOGI",
            "METODE PENELITIAN",
        )
    ):
        return True
    return False


def classify(text):
    t = text.strip()
    if is_front_matter_heading(t):
        return "cover"
    if is_chapter_1(t):
        return "roman"
    if is_chapter_2(t):
        return "decimal-start"
    return "body"


def add_pgnum(sect, fmt, start):
    if "<w:pgNumType" in sect:
        return sect
    tag = f'<w:pgNumType w:fmt="{fmt}" w:start="{start}"/>'
    return sect + tag


def sync_section_margins(doc):
    first_mar = re.search(
        r'<w:sectPr[^>]*>.*?(<w:pgMar\b[^>]*/>).*?</w:sectPr>', doc, re.S
    )
    if not first_mar:
        return doc
    target_pgmar = first_mar.group(1)
    return re.sub(r'<w:pgMar\b[^>]*/>', target_pgmar, doc)


def process(doc):
    doc = sync_section_margins(doc)
    matches = list(SECT_IN_PPR.finditer(doc))
    if not matches:
        return doc, 0
    out = []
    last = 0
    changed = 0
    for m in matches:
        out.append(doc[last:m.start()])
        sect = m.group(1)
        kind = classify(next_heading_text(doc, m.end()))
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


def get_tab_pos(doc):
    sz = re.search(r'<w:pgSz\b[^>]*w:w="(\d+)"', doc)
    mar_left = re.search(r'<w:pgMar\b[^>]*w:left="(\d+)"', doc)
    mar_right = re.search(r'<w:pgMar\b[^>]*w:right="(\d+)"', doc)
    if sz and mar_left and mar_right:
        try:
            w = int(sz.group(1))
            left = int(mar_left.group(1))
            right = int(mar_right.group(1))
            pos = w - left - right
            if pos > 1000:
                return pos
        except (ValueError, TypeError):
            pass
    return 9072


def fix_daftar_isi_title(doc):
    pattern = re.compile(
        r'(<w:p\b[^>]*><w:pPr>(?:(?!</w:p>).)*?<w:pStyle\s+w:val=["\x27])Heading1(["\x27](?:(?!</w:p>).)*?<w:t[^>]*>\s*DAFTAR ISI\s*</w:t>(?:(?!</w:p>).)*?</w:p>)',
        re.S,
    )
    return pattern.sub(r"\g<1>TOCHeading\g<2>", doc)


def fix_toc_styles(styles, tab_pos):
    tnr = '<w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>'
    defs = {
        "TOCHeading": f"""<w:style w:type="paragraph" w:styleId="TOCHeading">
  <w:name w:val="TOC Heading"/>
  <w:basedOn w:val="Normal"/>
  <w:next w:val="Normal"/>
  <w:uiPriority w:val="39"/>
  <w:qFormat/>
  <w:pPr>
    <w:spacing w:before="360" w:after="360" w:line="240" w:lineRule="auto"/>
    <w:jc w:val="center"/>
    <w:outlineLvl w:val="9"/>
  </w:pPr>
  <w:rPr>
    {tnr}
    <w:color w:val="000000"/>
    <w:sz w:val="28"/>
    <w:szCs w:val="28"/>
    <w:b/>
    <w:bCs/>
  </w:rPr>
</w:style>""",
        "TOC1": f"""<w:style w:type="paragraph" w:styleId="TOC1">
  <w:name w:val="toc 1"/>
  <w:basedOn w:val="Normal"/>
  <w:next w:val="Normal"/>
  <w:qFormat/>
  <w:pPr>
    <w:tabs>
      <w:tab w:val="right" w:leader="dot" w:pos="{tab_pos}"/>
    </w:tabs>
    <w:spacing w:before="120" w:after="40" w:line="260" w:lineRule="auto"/>
    <w:ind w:left="0" w:right="0"/>
    <w:jc w:val="left"/>
  </w:pPr>
  <w:rPr>
    {tnr}
    <w:color w:val="000000"/>
    <w:sz w:val="24"/>
    <w:szCs w:val="24"/>
    <w:b/>
    <w:bCs/>
  </w:rPr>
</w:style>""",
        "TOC2": f"""<w:style w:type="paragraph" w:styleId="TOC2">
  <w:name w:val="toc 2"/>
  <w:basedOn w:val="TOC1"/>
  <w:next w:val="Normal"/>
  <w:qFormat/>
  <w:pPr>
    <w:tabs>
      <w:tab w:val="right" w:leader="dot" w:pos="{tab_pos}"/>
    </w:tabs>
    <w:spacing w:before="20" w:after="20" w:line="240" w:lineRule="auto"/>
    <w:ind w:left="360" w:right="0"/>
    <w:jc w:val="left"/>
  </w:pPr>
  <w:rPr>
    {tnr}
    <w:color w:val="000000"/>
    <w:sz w:val="24"/>
    <w:szCs w:val="24"/>
    <w:b w:val="0"/>
    <w:bCs w:val="0"/>
  </w:rPr>
</w:style>""",
        "TOC3": f"""<w:style w:type="paragraph" w:styleId="TOC3">
  <w:name w:val="toc 3"/>
  <w:basedOn w:val="TOC2"/>
  <w:next w:val="Normal"/>
  <w:qFormat/>
  <w:pPr>
    <w:tabs>
      <w:tab w:val="right" w:leader="dot" w:pos="{tab_pos}"/>
    </w:tabs>
    <w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/>
    <w:ind w:left="720" w:right="0"/>
    <w:jc w:val="left"/>
  </w:pPr>
  <w:rPr>
    {tnr}
    <w:color w:val="000000"/>
    <w:sz w:val="24"/>
    <w:szCs w:val="24"/>
    <w:b w:val="0"/>
    <w:bCs w:val="0"/>
  </w:rPr>
</w:style>""",
    }
    missing = []
    for sid, block in defs.items():
        pattern = re.compile(rf'<w:style\b[^>]*w:styleId="{sid}"[^>]*>.*?</w:style>', re.S)
        if pattern.search(styles):
            styles = pattern.sub(block, styles)
        else:
            missing.append(block)
    if missing:
        styles = styles.replace("</w:styles>", "".join(missing) + "</w:styles>")
    return styles


def main():
    src = sys.argv[1]
    dst = sys.argv[2]

    with zipfile.ZipFile(src, "r") as zin:
        names = zin.namelist()
        items = {n: zin.read(n) for n in names}

    doc = items["word/document.xml"].decode("utf-8")
    tab_pos = get_tab_pos(doc)
    doc = fix_daftar_isi_title(doc)
    # Sesuaikan tab leader pada cached TOC entries agar tepat di margin kanan
    doc = re.sub(
        r'(<w:pStyle w:val="TOC[123]"/>.*?<w:tab w:val="right" w:leader="dot" w:pos=)"\d+"',
        rf'\g<1>"{tab_pos}"',
        doc,
    )
    new_doc, changed = process(doc)
    items["word/document.xml"] = new_doc.encode("utf-8")

    if "word/styles.xml" in items:
        styles = items["word/styles.xml"].decode("utf-8")
        items["word/styles.xml"] = fix_toc_styles(styles, tab_pos).encode("utf-8")

    with zipfile.ZipFile(dst, "w", zipfile.ZIP_DEFLATED) as zout:
        for n in items:
            zout.writestr(n, items[n])

    print(f"[OK] finalize-docx: {changed} sectPr disesuaikan (tab={tab_pos}) -> {dst}")


if __name__ == "__main__":
    main()