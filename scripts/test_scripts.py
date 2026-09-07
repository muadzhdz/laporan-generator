#!/usr/bin/env python3
"""test_scripts.py: Automated unit tests for Laporan Generator Python helper scripts."""

import os
import sys
import unittest

# Tambahkan direktori scripts ke sys.path
SCRIPTS_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR = os.path.dirname(SCRIPTS_DIR)
sys.path.insert(0, SCRIPTS_DIR)

scan_preset = __import__("scan-preset")
validate_preset = __import__("validate-preset")
docx_pagenum = __import__("docx-pagenum")


class TestScanPreset(unittest.TestCase):
    def test_pdf_slug(self):
        self.assertEqual(scan_preset.pdf_slug("pedoman-itb.pdf"), "itb")
        self.assertEqual(scan_preset.pdf_slug("panduan-ugm.pdf"), "ugm")
        self.assertEqual(scan_preset.pdf_slug("buku-ui.pdf"), "ui")

    def test_detect_margins(self):
        text_4433 = "Batas pengetikan adalah 4 - 4 - 3 - 3 cm."
        margins = scan_preset.detect_margins(text_4433)
        self.assertEqual(margins["top"], "4cm")
        self.assertEqual(margins["bottom"], "3cm")
        self.assertEqual(margins["left"], "4cm")
        self.assertEqual(margins["right"], "3cm")

    def test_detect_institution(self):
        sample = "KEMENTERIAN PENDIDIKAN\nUNIVERSITAS INDONESIA\nFAKULTAS ILMU KOMPUTER"
        inst = scan_preset.detect_institution(sample, "ui.pdf")
        self.assertIn("UNIVERSITAS INDONESIA", inst)


class TestValidatePreset(unittest.TestCase):
    def test_parse_simple_yaml(self):
        test_yaml = os.path.join(ROOT_DIR, "presets", "standard.yml")
        self.assertTrue(os.path.exists(test_yaml))
        data = validate_preset.parse_simple_yaml(test_yaml)
        self.assertEqual(data.get("preset_id"), "standard")
        self.assertEqual(data.get("margin_top"), "2cm")

    def test_validate_all_presets(self):
        presets_dir = os.path.join(ROOT_DIR, "presets")
        for f in os.listdir(presets_dir):
            if f.endswith(".yml"):
                path = os.path.join(presets_dir, f)
                errors = validate_preset.validate_preset_file(path)
                self.assertEqual(errors, [], f"Preset {f} gagal validasi: {errors}")


class TestDocxPagenum(unittest.TestCase):
    def test_needle_of(self):
        self.assertEqual(docx_pagenum.needle_of("BAB I PENDAHULUAN"), "PENDAHULUAN")
        self.assertEqual(docx_pagenum.needle_of("1.1 Latar Belakang"), "1.1 Latar Belakang")
        self.assertEqual(docx_pagenum.needle_of("KATA PENGANTAR"), "KATA PENGANTAR")

    def test_roman_pattern(self):
        self.assertTrue(docx_pagenum.ROMAN.match("iv"))
        self.assertTrue(docx_pagenum.ROMAN.match("xii"))
        self.assertFalse(docx_pagenum.ROMAN.match("123"))

    def test_decimal_pattern(self):
        self.assertTrue(docx_pagenum.DECIMAL.match("1"))
        self.assertTrue(docx_pagenum.DECIMAL.match("42"))
        self.assertFalse(docx_pagenum.DECIMAL.match("iv"))


if __name__ == "__main__":
    unittest.main(verbosity=2)
