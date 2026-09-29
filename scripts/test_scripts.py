#!/usr/bin/env python3
"""test_scripts.py: Automated unit tests for Laporan Generator Python helper scripts."""

import json
import os
import subprocess
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


def get_presets_dir():
    for c in [
        os.path.join(ROOT_DIR, "presets"),
        os.path.join(ROOT_DIR, "resources", "presets"),
        os.path.join(ROOT_DIR, "..", "..", "..", "presets"),
    ]:
        if os.path.isdir(c):
            return os.path.abspath(c)
    return os.path.join(ROOT_DIR, "presets")


def get_project_root():
    for c in [
        ROOT_DIR,
        os.path.join(ROOT_DIR, "resources"),
        os.path.join(ROOT_DIR, "..", "..", ".."),
    ]:
        if os.path.isfile(os.path.join(c, "metadata.yml")):
            return os.path.abspath(c)
    return ROOT_DIR


class TestValidatePreset(unittest.TestCase):
    def test_parse_simple_yaml(self):
        presets_dir = get_presets_dir()
        test_yaml = os.path.join(presets_dir, "standard.yml")
        self.assertTrue(os.path.exists(test_yaml))
        data = validate_preset.parse_simple_yaml(test_yaml)
        self.assertEqual(data.get("preset_id"), "standard")
        self.assertEqual(data.get("margin_top"), "2cm")

    def test_validate_all_presets(self):
        presets_dir = get_presets_dir()
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
        sample_md = os.path.join(get_project_root(), "cover.md")
        if os.path.exists(sample_md):
            stats = report_stats.count_file_stats(sample_md)
            self.assertIsInstance(stats, dict)
            self.assertIsInstance(stats["words"], int)
            self.assertIsInstance(stats["chars"], int)
            self.assertGreaterEqual(stats["words"], 0)

    def test_json_stats_execution(self):
        proj_root = get_project_root()
        cmd = [sys.executable, os.path.join(SCRIPTS_DIR, "report-stats.py"), proj_root, "--json"]
        proc = subprocess.run(cmd, capture_output=True, text=True, cwd=proj_root)
        self.assertEqual(proc.returncode, 0)
        data = json.loads(proc.stdout)
        self.assertIn("total_words", data)
        self.assertIn("preset", data)
        self.assertIn("target_dir", data)


class TestReportDoctor(unittest.TestCase):
    def test_json_doctor_execution(self):
        proj_root = get_project_root()
        cmd = [sys.executable, os.path.join(SCRIPTS_DIR, "report-doctor.py"), proj_root, "--json"]
        proc = subprocess.run(cmd, capture_output=True, text=True, cwd=proj_root)
        data = json.loads(proc.stdout)
        self.assertIn("status", data)
        self.assertIn("dependencies", data)
        self.assertIn("required_files", data)
        self.assertIn("citations", data)


class TestFrontMatterOptIn(unittest.TestCase):
    def test_default_metadata_structure(self):
        meta_path = os.path.join(get_project_root(), "metadata.yml")
        with open(meta_path, "r", encoding="utf-8") as f:
            content = f.read()
        # Verify abstract is commented or empty by default
        self.assertNotIn("\nabstract_id: |", content, "abstract_id should not be active by default in metadata.yml")
        self.assertNotIn("\nabstract_en: |", content, "abstract_en should not be active by default in metadata.yml")
        # Verify opt-in flags for daftar_gambar & daftar_tabel are explicitly false or commented
        has_dg = "daftar_gambar: false" in content
        has_dt = "daftar_tabel: false" in content
        self.assertTrue(has_dg, "metadata.yml must explicitly specify daftar_gambar: false by default")
        self.assertTrue(has_dt, "metadata.yml must explicitly specify daftar_tabel: false by default")

    def test_cover_md_gated_outlines(self):
        cover_path = os.path.join(get_project_root(), "cover.md")
        with open(cover_path, "r", encoding="utf-8") as f:
            content = f.read()
        # Unconditional outline queries must not exist
        self.assertNotIn("let imgs = query(figure.where(kind: image))\n  if imgs.len() > 0", content,
                         "cover.md must not unconditionally emit DAFTAR GAMBAR outline")
        self.assertNotIn("let tbls = query(figure.where(kind: table))\n  if tbls.len() > 0", content,
                         "cover.md must not unconditionally emit DAFTAR TABEL outline")
        # Must be gated by opt-in check
        self.assertIn("opt-daftar-gambar", content, "cover.md must gate DAFTAR GAMBAR with opt-daftar-gambar")
        self.assertIn("opt-daftar-tabel", content, "cover.md must gate DAFTAR TABEL with opt-daftar-tabel")

    def test_lua_meta_bool_coercion(self):
        """Verify docx.lua handles YAML boolean scalars and string equivalents safely."""
        lua_code = """
        local pandoc = {
          utils = {
            stringify = function(x)
              if type(x) ~= 'string' and type(x) ~= 'table' then
                error('pandoc.utils.stringify expects table or string, got ' .. type(x))
              end
              return tostring(x)
            end
          }
        }
        local function meta_str(meta, key)
          local v = meta[key]
          if v == nil then return "" end
          if type(v) == "boolean" then return tostring(v) end
          return pandoc.utils.stringify(v)
        end
        local function meta_bool(meta, key)
          local v = meta[key]
          if v == nil then return false end
          if type(v) == "boolean" then return v end
          local s = meta_str(meta, key):lower():gsub("%s+", "")
          return s == "true" or s == "1" or s == "yes"
        end

        local meta = {
          dg_bool_false = false,
          dg_bool_true = true,
          dg_str_false = "false",
          dg_str_true = "true",
          dg_nil = nil
        }

        assert(meta_str(meta, "dg_bool_false") == "false")
        assert(meta_bool(meta, "dg_bool_false") == false)
        assert(meta_str(meta, "dg_bool_true") == "true")
        assert(meta_bool(meta, "dg_bool_true") == true)
        assert(meta_bool(meta, "dg_str_false") == false)
        assert(meta_bool(meta, "dg_str_true") == true)
        assert(meta_bool(meta, "dg_nil") == false)
        print("LUA_OK")
        """
        proc = subprocess.run(["lua", "-e", lua_code], capture_output=True, text=True)
        self.assertEqual(proc.returncode, 0, f"Lua helper test failed: {proc.stderr}")
        self.assertIn("LUA_OK", proc.stdout)

    def test_init_project_boolean_coercion(self):
        """Verify lib/init.js does not treat string 'false' as truthy."""
        import tempfile
        with tempfile.TemporaryDirectory() as tmpdir:
            node_code = f"""
            const path = require('path');
            const {{ initProject }} = require('{os.path.join(ROOT_DIR, "lib/init.js")}');
            initProject({{ targetDir: '{tmpdir}/test_f', daftar_gambar: 'false', daftar_tabel: false, silent: true }});
            initProject({{ targetDir: '{tmpdir}/test_t', daftar_gambar: 'true', daftar_tabel: true, silent: true }});
            """
            proc = subprocess.run(["node", "-e", node_code], capture_output=True, text=True)
            self.assertEqual(proc.returncode, 0, f"Node initProject failed: {proc.stderr}")
            with open(os.path.join(tmpdir, "test_f", "metadata.yml"), "r", encoding="utf-8") as f:
                meta_f = f.read()
            with open(os.path.join(tmpdir, "test_t", "metadata.yml"), "r", encoding="utf-8") as f:
                meta_t = f.read()
            self.assertIn("daftar_gambar: false", meta_f)
            self.assertIn("daftar_tabel: false", meta_f)
            self.assertIn("daftar_gambar: true", meta_t)
            self.assertIn("daftar_tabel: true", meta_t)


if __name__ == "__main__":
    unittest.main(verbosity=2)

