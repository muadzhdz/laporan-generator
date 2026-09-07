#!/usr/bin/env python3
"""validate-preset.py: Validator dan Linter untuk berkas preset format kampus (YAML).

Memeriksa integritas berkas preset terhadap spesifikasi skema resmi (docs/preset-schema.md).

Usage:
  python3 scripts/validate-preset.py [path-to-preset.yml ...]
  python3 scripts/validate-preset.py --all
"""

import argparse
import glob
import os
import re
import sys

DIM_REGEX = re.compile(r"^[0-9]+(\.[0-9]+)?(cm|mm|in|pt)$", re.I)
PT_REGEX = re.compile(r"^[0-9]+(\.[0-9]+)?pt$", re.I)


def parse_simple_yaml(filepath):
    """Parser YAML yang tangguh dengan PyYAML dan fallback aman tanpa dependensi."""
    try:
        import yaml
        with open(filepath, "r", encoding="utf-8") as f:
            content = yaml.safe_load(f)
            if isinstance(content, dict):
                return {str(k): ("" if v is None else str(v)) for k, v in content.items()}
    except (ImportError, ModuleNotFoundError):
        pass

    data = {}
    with open(filepath, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            if ":" in line:
                key, val = line.split(":", 1)
                key = key.strip()
                val = val.strip()
                if val.startswith('"'):
                    end_quote = val.find('"', 1)
                    val = val[1:end_quote] if end_quote != -1 else val.strip('"')
                elif val.startswith("'"):
                    end_quote = val.find("'", 1)
                    val = val[1:end_quote] if end_quote != -1 else val.strip("'")
                else:
                    val = val.split("#")[0].strip()
                data[key] = val
    return data


def validate_preset_file(filepath):
    """Validasi sebuah file preset dan kembalikan daftar error."""
    errors = []
    if not os.path.isfile(filepath):
        return [f"Berkas '{filepath}' tidak ditemukan."]

    try:
        data = parse_simple_yaml(filepath)
    except Exception as e:
        return [f"Gagal mengurai YAML: {e}"]

    # 1. Identitas
    expected_id = os.path.basename(filepath).rsplit(".", 1)[0]
    pid = data.get("preset_id")
    if not pid:
        errors.append("Field wajib 'preset_id' tidak ditemukan.")
    elif pid != expected_id:
        errors.append(f"'preset_id' ('{pid}') tidak cocok dengan nama berkas ('{expected_id}').")

    if not data.get("name"):
        errors.append("Field wajib 'name' tidak ditemukan atau kosong.")

    # 2. Margin
    for m in ["margin_top", "margin_bottom", "margin_left", "margin_right"]:
        val = data.get(m)
        if not val:
            errors.append(f"Field margin '{m}' wajib diisi.")
        elif not DIM_REGEX.match(val):
            errors.append(f"Format satuan '{m}' tidak valid: '{val}' (contoh valid: '4cm', '2.5cm', '12pt').")

    # 3. Tipografi
    if not data.get("font_family"):
        errors.append("Field 'font_family' wajib diisi.")

    fs = data.get("font_size")
    if not fs:
        errors.append("Field 'font_size' wajib diisi.")
    elif not PT_REGEX.match(fs):
        errors.append(f"Format 'font_size' tidak valid: '{fs}' (contoh: '12pt').")

    ls = data.get("line_spacing")
    if not ls:
        errors.append("Field 'line_spacing' wajib diisi.")

    ind = data.get("first_line_indent")
    if not ind:
        errors.append("Field 'first_line_indent' wajib diisi.")
    elif not DIM_REGEX.match(ind):
        errors.append(f"Format 'first_line_indent' tidak valid: '{ind}' (contoh: '1.25cm').")

    # 4. Heading
    fmt = data.get("heading_chapter_num_format")
    if fmt and fmt not in ("roman", "arabic"):
        errors.append(f"'heading_chapter_num_format' harus 'roman' atau 'arabic', bukan '{fmt}'.")

    # 5. Booleans
    for b in ["heading_sub_dot", "heading_subsub_dot", "cover_show_lecturer"]:
        if b in data and str(data[b]).lower() not in ("true", "false"):
            errors.append(f"Field '{b}' harus berupa boolean (true/false), bukan '{data[b]}'.")

    return errors


def main():
    parser = argparse.ArgumentParser(description="Linter dan validator berkas preset format kampus.")
    parser.add_argument("files", nargs="*", help="Path ke berkas preset YAML yang ingin divalidasi")
    parser.add_argument("--all", action="store_true", help="Validasi seluruh preset di folder presets/")
    parser.add_argument("--dir", default="presets", help="Direktori preset (default: presets/)")

    args = parser.parse_args()

    target_files = []
    if args.all or not args.files:
        target_files = sorted(glob.glob(os.path.join(args.dir, "*.yml")))
    else:
        for f in args.files:
            if not f.endswith(".yml"):
                f = os.path.join(args.dir, f"{f}.yml")
            target_files.append(f)

    if not target_files:
        print(f"[WARN] Tidak ada berkas preset YAML yang ditemukan di '{args.dir}'.")
        sys.exit(0)

    print("=" * 60)
    print("           LAPORAN GENERATOR PRESET VALIDATOR")
    print("=" * 60)

    total = len(target_files)
    passed = 0
    failed = 0

    for f in target_files:
        rel_path = os.path.relpath(f)
        errors = validate_preset_file(f)
        if not errors:
            print(f"  [OK] {rel_path}")
            passed += 1
        else:
            print(f"  [FAIL] {rel_path}:")
            for err in errors:
                print(f"         - {err}")
            failed += 1

    print("=" * 60)
    print(f"Hasil: {passed} valid, {failed} error dari total {total} preset.")
    print("=" * 60)

    sys.exit(1 if failed > 0 else 0)


if __name__ == "__main__":
    main()
