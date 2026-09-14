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
finalize_docx = __import__("finalize-docx")


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


class TestFinalizeDocx(unittest.TestCase):
    def test_classify_front_matter(self):
        self.assertEqual(finalize_docx.classify("KATA PENGANTAR"), "cover")
        self.assertEqual(finalize_docx.classify("ABSTRAK"), "cover")
        self.assertEqual(finalize_docx.classify("DAFTAR ISI"), "cover")

    def test_classify_standard_thesis_headings(self):
        self.assertEqual(finalize_docx.classify("BAB I"), "roman")
        self.assertEqual(finalize_docx.classify("BAB I PENDAHULUAN"), "roman")
        self.assertEqual(finalize_docx.classify("BAB II"), "decimal-start")
        self.assertEqual(
            finalize_docx.classify("BAB II TINJAUAN PUSTAKA"), "decimal-start"
        )
        self.assertEqual(finalize_docx.classify("BAB III METODOLOGI"), "body")
        self.assertEqual(finalize_docx.classify("DAFTAR PUSTAKA"), "body")

    def test_classify_makalah_headings(self):
        self.assertEqual(finalize_docx.classify("1. PENDAHULUAN"), "roman")
        self.assertEqual(finalize_docx.classify("1 PENDAHULUAN"), "roman")
        self.assertEqual(finalize_docx.classify("2. PEMBAHASAN"), "decimal-start")
        self.assertEqual(finalize_docx.classify("2 PEMBAHASAN"), "decimal-start")
        self.assertEqual(finalize_docx.classify("3. PENUTUP"), "body")

    def test_classify_arabic_chapter_headings(self):
        self.assertEqual(finalize_docx.classify("BAB 1 PENDAHULUAN"), "roman")
        self.assertEqual(finalize_docx.classify("BAB 2 PEMBAHASAN"), "decimal-start")
        self.assertEqual(finalize_docx.classify("BAB 3 PENUTUP"), "body")

    def test_get_tab_pos(self):
        sample_standard = '<w:sectPr><w:pgSz w:w="11906"/><w:pgMar w:left="1417" w:right="1417"/></w:sectPr>'
        self.assertEqual(finalize_docx.get_tab_pos(sample_standard), 9072)
        sample_4433 = '<w:sectPr><w:pgSz w:w="11906"/><w:pgMar w:left="2268" w:right="1701"/></w:sectPr>'
        self.assertEqual(finalize_docx.get_tab_pos(sample_4433), 7937)
        self.assertEqual(finalize_docx.get_tab_pos(""), 9072)

    def test_fix_daftar_isi_title(self):
        raw = '<w:p><w:pPr><w:pStyle w:val="Heading1"/><w:outlineLvl w:val="-1"/></w:pPr><w:r><w:t>DAFTAR ISI</w:t></w:r></w:p>'
        fixed = finalize_docx.fix_daftar_isi_title(raw)
        self.assertIn('w:val="TOCHeading"', fixed)
        self.assertNotIn('w:val="Heading1"', fixed)

    def test_fix_toc_styles(self):
        styles = '<w:styles></w:styles>'
        res = finalize_docx.fix_toc_styles(styles, 7937)
        self.assertIn('w:styleId="TOCHeading"', res)
        self.assertIn('w:styleId="TOC1"', res)
        self.assertIn('w:styleId="TOC2"', res)
        self.assertIn('w:styleId="TOC3"', res)
        self.assertIn('w:pos="7937"', res)
        self.assertIn('w:left="360"', res)
        self.assertIn('w:left="720"', res)


report_stats = __import__("report-stats")


class TestReportStats(unittest.TestCase):
    def test_count_file_stats_structure(self):
        sample_md = os.path.join(ROOT_DIR, "cover.md")
        if os.path.exists(sample_md):
            stats = report_stats.count_file_stats(sample_md)
            self.assertIsInstance(stats, dict)
            self.assertIsInstance(stats["words"], int)
            self.assertIsInstance(stats["chars"], int)
            self.assertGreaterEqual(stats["words"], 0)


if __name__ == "__main__":
    unittest.main(verbosity=2)

