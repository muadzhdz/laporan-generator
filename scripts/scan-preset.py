#!/usr/bin/env python3
"""scan-preset.py: Ekstraktor otomatis aturan format & preset kampus dari berkas PDF.

Mengekstrak aturan tata letak (margin, font, spasi baris, penomoran heading,
dan nama institusi) dari dokumen PDF Buku Pedoman Penulisan Skripsi / Tugas Akhir.

Usage:
  python3 scripts/scan-preset.py <input.pdf> [options]

Options:
  --preset-id <id>      ID unik preset (default: slug nama kampus/file)
  --name <name>         Nama lengkap preset/institusi
  --output-dir <dir>    Direktori output (default: presets/)
  --non-interactive     Jalankan tanpa konfirmasi interaktif
  --apply               Otomatis terapkan ke metadata.yml setelah scan
"""

import argparse
import os
import re
import subprocess
import sys


def extract_text_from_pdf(pdf_path):
    """Ekstraksi teks dari PDF menggunakan pdftotext (poppler-utils) atau fallback."""
    if not os.path.exists(pdf_path):
        print(f"[ERROR] Berkas '{pdf_path}' tidak ditemukan.", file=sys.stderr)
        sys.exit(1)

    # Jika file teks/mock markdown diberikan langsung
    if pdf_path.endswith(".txt") or pdf_path.endswith(".md"):
        with open(pdf_path, "r", encoding="utf-8", errors="ignore") as f:
            return f.read()

    # Cek pdftotext
    if subprocess.run(["which", "pdftotext"], capture_output=True).returncode == 0:
        try:
            # Ambil maksimal 40 halaman pertama (bab pedoman format biasanya di bagian awal)
            res = subprocess.run(
                ["pdftotext", "-f", "1", "-l", "40", "-layout", pdf_path, "-"],
                capture_output=True,
                text=True,
                check=True,
            )
            return res.stdout
        except Exception as e:
            print(f"[WARN] pdftotext gagal: {e}", file=sys.stderr)

    # Fallback jika file binary PDF tidak bisa diurai via pdftotext
    print("[WARN] pdftotext tidak tersedia, membaca teks mentah...", file=sys.stderr)
    try:
        with open(pdf_path, "rb") as f:
            raw = f.read().decode("latin1", errors="ignore")
            # Ekstraksi string teks dalam kurung PDF (Tj / TJ)
            strings = re.findall(r"\(([^\)]+)\)\s*Tj", raw)
            return "\n".join(strings) if strings else raw
    except Exception as e:
        print(f"[ERROR] Gagal membaca berkas: {e}", file=sys.stderr)
        sys.exit(1)


def detect_institution(text, filename):
    """Deteksi nama universitas / institut / politeknik."""
    patterns = [
        r"(UNIVERSITAS\s+[A-Z0-9\s]+)",
        r"(INSTITUT\s+[A-Z0-9\s]+)",
        r"(POLITEKNIK\s+[A-Z0-9\s]+)",
        r"(SEKOLAH\s+TINGGI\s+[A-Z0-9\s]+)",
        r"(Universitas\s+[A-Za-z0-9\s]+)",
        r"(Institut\s+[A-Za-z0-9\s]+)",
        r"(Politeknik\s+[A-Za-z0-9\s]+)",
    ]
    for pat in patterns:
        m = re.search(pat, text)
        if m:
            found = m.group(1).strip()
            # Bersihkan baris berlebih
            found = found.split("\n")[0].strip()
            if len(found) > 8 and len(found) < 60:
                return found

    # Fallback dari nama file (contoh: pedoman-its.pdf -> ITS)
    base = os.path.basename(pdf_slug(filename)).replace("-", " ").title()
    return base


def pdf_slug(path):
    """Buat slug ID dari nama berkas atau nama institusi."""
    base = os.path.basename(path).rsplit(".", 1)[0]
    base = re.sub(r"^(pedoman|buku|panduan|skripsi|ta|format)[-_]?", "", base, flags=re.I)
    base = re.sub(r"[^a-zA-Z0-9]+", "-", base).strip("-").lower()
    return base if base else "custom-kampus"


def detect_margins(text):
    """Deteksi batas margin (top, bottom, left, right)."""
    # Pola shorthand 4-4-3-3 atau 4 4 3 3 (kiri-atas-kanan-bawah atau atas-kiri-bawah-kanan)
    if re.search(r"4\s*[-–,]\s*4\s*[-–,]\s*3\s*[-–,]\s*3", text):
        return {"top": "4cm", "bottom": "3cm", "left": "4cm", "right": "3cm"}
    if re.search(r"3\s*[-–,]\s*3\s*[-–,]\s*3\s*[-–,]\s*3", text):
        return {"top": "3cm", "bottom": "3cm", "left": "3cm", "right": "3cm"}

    margins = {"top": "2.5cm", "bottom": "2.5cm", "left": "2.5cm", "right": "2.5cm"}

    # Pola spesifik bahasa Indonesia
    m_left = re.search(r"(?:kiri|left)\s*[:=]?\s*([0-9]+(?:[.,][0-9]+)?)\s*cm", text, re.I)
    m_top = re.search(r"(?:atas|top)\s*[:=]?\s*([0-9]+(?:[.,][0-9]+)?)\s*cm", text, re.I)
    m_right = re.search(r"(?:kanan|right)\s*[:=]?\s*([0-9]+(?:[.,][0-9]+)?)\s*cm", text, re.I)
    m_bottom = re.search(r"(?:bawah|bottom)\s*[:=]?\s*([0-9]+(?:[.,][0-9]+)?)\s*cm", text, re.I)

    if m_left:
        margins["left"] = f"{m_left.group(1).replace(',', '.')}cm"
    if m_top:
        margins["top"] = f"{m_top.group(1).replace(',', '.')}cm"
    if m_right:
        margins["right"] = f"{m_right.group(1).replace(',', '.')}cm"
    if m_bottom:
        margins["bottom"] = f"{m_bottom.group(1).replace(',', '.')}cm"

    # Deteksi format skripsi jilid umum jika terdeteksi teks jilid
    if re.search(r"(jilid|hardcover|penjilidan)", text, re.I) and not m_left:
        margins["left"] = "4cm"
        margins["top"] = "4cm"
        margins["right"] = "3cm"
        margins["bottom"] = "3cm"

    return margins


def detect_typography(text):
    """Deteksi font family, size, line spacing, dan indent."""
    typo = {
        "font_family": "Libertinus Serif",
        "font_size": "12pt",
        "line_spacing": "0.75em",  # 0.75em = 1.5 spasi di Typst
        "first_line_indent": "1.25cm",
    }

    # Deteksi Font
    if re.search(r"Arial", text, re.I):
        typo["font_family"] = "Arial"
    elif re.search(r"Calibri", text, re.I):
        typo["font_family"] = "Calibri"
    elif re.search(r"Times\s*New\s*Roman", text, re.I):
        typo["font_family"] = "Libertinus Serif"

    # Deteksi Ukuran Font
    m_sz = re.search(r"(?:ukuran|font\s*size|size)\s*[:=]?\s*([0-9]+)\s*(?:pt|point)?", text, re.I)
    if m_sz:
        typo["font_size"] = f"{m_sz.group(1)}pt"

    # Deteksi Spasi Baris
    if re.search(r"(?:spasi|line\s*spacing)\s*[:=]?\s*(?:ganda|2(?:\.0)?|double)", text, re.I):
        typo["line_spacing"] = "1.0em"  # double spacing
    elif re.search(r"(?:spasi|line\s*spacing)\s*[:=]?\s*1[,.]15", text, re.I):
        typo["line_spacing"] = "0.55em"
    elif re.search(r"(?:spasi|line\s*spacing)\s*[:=]?\s*(?:1[,.]5|satu\s*setengah)", text, re.I):
        typo["line_spacing"] = "0.75em"

    # Deteksi Indentasi
    m_ind = re.search(r"(?:indentasi|alinea|awal\s*paragraf)\s*[:=]?\s*([0-9]+(?:[.,][0-9]+)?)\s*cm", text, re.I)
    if m_ind:
        typo["first_line_indent"] = f"{m_ind.group(1).replace(',', '.')}cm"

    return typo


def detect_headings(text):
    """Deteksi format penomoran bab dan sub-bab."""
    headings = {
        "chapter_prefix": "BAB ",
        "chapter_num_format": "roman",
        "sub_dot": True,
        "subsub_dot": False,
    }

    # Cek BAB 1 vs BAB I
    if re.search(r"BAB\s+[0-9]+\b", text) and not re.search(r"BAB\s+[IVXLCDM]+\b", text):
        headings["chapter_num_format"] = "arabic"

    # Cek sub-bab trailing dot (1.1. vs 1.1)
    if re.search(r"\b1\.1\s+[A-Z]", text):
        headings["sub_dot"] = False
    elif re.search(r"\b1\.1\.\s+[A-Z]", text):
        headings["sub_dot"] = True

    return headings


def detect_cover(text):
    """Deteksi opsi sampul depan (apakah dosen pembimbing dicantumkan)."""
    cover = {
        "show_lecturer": True,
        "logo_width": "4cm",
    }
    # Jika ada klausul eksplisit bahwa sampul luar tidak mencantumkan pembimbing (seperti ITB)
    if re.search(r"sampul\s*(?:luar|depan)?\s*tanpa\s*(?:nama)?\s*(?:dosen|pembimbing)", text, re.I):
        cover["show_lecturer"] = False
    return cover


def build_preset_yaml(preset_id, name, margins, typo, headings, cover):
    """Hasilkan string YAML preset standar."""
    hide_lecturer_yaml = ""
    if not cover["show_lecturer"]:
        hide_lecturer_yaml = "\ncover_hide_lecturer: true"

    return f"""# Preset: {name}
# Dihasilkan secara otomatis oleh scan-preset.py
preset_id: "{preset_id}"
name: "{name}"
description: "Format otomatis hasil pemindaian pedoman akademik {name}."

# 1. Geometri & Margin Halaman
margin_top: {margins['top']}
margin_bottom: {margins['bottom']}
margin_left: {margins['left']}
margin_right: {margins['right']}

# 2. Tipografi & Spasi
font_family: "{typo['font_family']}"
font_size: {typo['font_size']}
line_spacing: {typo['line_spacing']}
first_line_indent: {typo['first_line_indent']}

# 3. Penomoran Heading
heading_chapter_prefix: "{headings['chapter_prefix']}"
heading_chapter_num_format: "{headings['chapter_num_format']}"
heading_sub_dot: {str(headings['sub_dot']).lower()}
heading_subsub_dot: {str(headings['subsub_dot']).lower()}

# 4. Pengaturan Halaman Sampul
cover_show_lecturer: {str(cover['show_lecturer']).lower()}{hide_lecturer_yaml}
cover_logo_width: {cover['logo_width']}
"""


def main():
    parser = argparse.ArgumentParser(description="Scan pedoman penulisan PDF dan buat preset kampus otomatis.")
    parser.add_argument("pdf_path", help="Path ke berkas PDF pedoman penulisan kampus")
    parser.add_argument("--preset-id", help="ID unik preset (contoh: unpad-skripsi)")
    parser.add_argument("--name", help="Nama lengkap institusi / preset")
    parser.add_argument("--output-dir", default="presets", help="Direktori output penyimpanan preset")
    parser.add_argument("--non-interactive", action="store_true", help="Jalankan otomatis tanpa prompt interaktif")
    parser.add_argument("--apply", action="store_true", help="Terapkan preset langsung ke metadata.yml")

    args = parser.parse_args()

    print(f"\n[1/3] Membaca dan menganalisis berkas: {args.pdf_path}...")
    text = extract_text_from_pdf(args.pdf_path)
    print(f"      Total teks terdeteksi: {len(text.split())} kata")

    print("[2/3] Mengekstraksi aturan penulisan akademik...")
    inst_name = args.name or detect_institution(text, args.pdf_path)
    pid = args.preset_id or pdf_slug(inst_name or args.pdf_path)
    margins = detect_margins(text)
    typo = detect_typography(text)
    headings = detect_headings(text)
    cover = detect_cover(text)

    print("\n" + "=" * 56)
    print("        HASIL DETEKSI ATURAN FORMAT KAMPUS")
    print("=" * 56)
    print(f"  * ID Preset       : {pid}")
    print(f"  * Nama Institusi  : {inst_name}")
    print(f"  * Margin Halaman  : Atas {margins['top']}, Bawah {margins['bottom']}, Kiri {margins['left']}, Kanan {margins['right']}")
    print(f"  * Tipografi       : {typo['font_family']} {typo['font_size']} (Spasi: {typo['line_spacing']}, Indent: {typo['first_line_indent']})")
    print(f"  * Penomoran Bab   : {headings['chapter_prefix']}{'I' if headings['chapter_num_format'] == 'roman' else '1'} (Sub-bab dot: {headings['sub_dot']})")
    print(f"  * Sampul Depan    : Dosen={'Ya' if cover['show_lecturer'] else 'Tidak'}, Lebar Logo={cover['logo_width']}")
    print("=" * 56 + "\n")

    if not args.non_interactive:
        confirm = input("Simpan konfigurasi preset di atas? [Y/n]: ").strip().lower()
        if confirm in ("n", "no"):
            print("[INFO] Pembuatan preset dibatalkan.")
            sys.exit(0)

    os.makedirs(args.output_dir, exist_ok=True)
    out_file = os.path.join(args.output_dir, f"{pid}.yml")
    yaml_content = build_preset_yaml(pid, inst_name, margins, typo, headings, cover)

    with open(out_file, "w", encoding="utf-8") as f:
        f.write(yaml_content)

    print(f"[3/3] [OK] Preset berhasil disimpan ke: {out_file}")

    if args.apply:
        meta_file = "metadata.yml" if os.path.exists("metadata.yml") else ("templates/default/metadata.yml" if os.path.exists("templates/default/metadata.yml") else "metadata.yml")
        if os.path.exists(meta_file):
            with open(meta_file, "r", encoding="utf-8") as f:
                content = f.read()
            if re.search(r"^\s*preset:", content, re.M):
                content = re.sub(r"^\s*preset:.*", f'preset: "{pid}"', content, flags=re.M)
            elif re.search(r"^\s*margin_preset:", content, re.M):
                content = re.sub(r"^\s*margin_preset:.*", f'preset: "{pid}"', content, flags=re.M)
            elif "..." in content:
                content = content.replace("...", f'preset: "{pid}"\n...')
            else:
                content += f'\npreset: "{pid}"\n'
            with open(meta_file, "w", encoding="utf-8") as f:
                f.write(content)
            print(f"[OK] Preset '{pid}' telah diterapkan ke metadata.yml!")

    print(f"\nUntuk menggunakan preset ini, jalankan:")
    print(f"  ./laporan preset apply {pid}")
    print(f"  ./laporan build\n")


if __name__ == "__main__":
    main()
