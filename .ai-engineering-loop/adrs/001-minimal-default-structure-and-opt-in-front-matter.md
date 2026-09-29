# ADR 001: Minimal Default Document Structure and Opt-In Front Matter

## Status
Accepted

## Context
Previously, document scaffolding and compilation unconditionally generated Daftar Tabel, Daftar Gambar, and Abstrak placeholders whenever figures/tables existed or by default. Users drafting standard academic documents (makalah, proposal, laporan magang/PKL) were burdened by unwanted outlines and dummy abstract sections that had to be manually deleted or bypassed.

## Decision
1. Establish a strict 5-element minimal default document baseline:
   - Cover
   - Kata Pengantar
   - Daftar Isi
   - Batang Tubuh (BAB 1..n)
   - Daftar Pustaka
2. Make Daftar Gambar, Daftar Tabel, and Abstrak strictly opt-in:
   - Typst: outline generation gated by metadata flags `opt-daftar-gambar` and `opt-daftar-tabel`.
   - DOCX: OpenXML TOC generation in `docx.lua` gated by `meta_bool` on `daftar_gambar` / `list_of_figures` and `daftar_tabel` / `list_of_tables`.
   - `metadata.yml`: explicit `daftar_gambar: false`, `daftar_tabel: false`, commented abstract blocks.
   - MCP `laporan_init` and `lib/init.js`: accept boolean or string flags defaulting to false with `isTruthy` coercion.
3. AI agent interaction protocols (`prompt.md` and `SKILL.md`) must conduct an explicit document structure interview before writing files.

## Consequences
- Clean, minimal academic output by default for both Typst and DOCX engines.
- AI agents will not auto-insert unwanted tables of figures or abstracts without user confirmation.
- Testing suites in `scripts/test_scripts.py` verify dual-engine parity and boolean coercion for opt-in flags.
