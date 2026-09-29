# Goal Contract Draft

**Run:** `20260929T095018Z-a1ee16bb`  
**Revision:** 1  
**Status:** DRAFT — not frozen  
**Content hash:** `cd76338b8837e70af80af3aa6de403eeef6c80c24fc1051a39d096517a788bea`

## Objective

Establish clean minimalist default document structure (Cover -> Kata Pengantar -> Daftar Isi -> Batang Tubuh -> Daftar Pustaka) by making Daftar Gambar, Daftar Tabel, and Abstrak strictly opt-in, updating AI interview protocols, and maintaining dual-engine parity.

## Acceptance criteria and failure table

| AC | Required behavior | Evidence seam | Failure cases |
|---|---|---|---|
| AC-1 | Default compilation produces clean minimal structure: Cover, Kata Pengantar, Daftar Isi, Chapters (BAB I..V), and Daftar Pustaka, without unconditionally emitting Daftar Gambar, Daftar Tabel, or Abstrak. | Default metadata.yml and cover.md in Typst and DOCX engines do not generate Daftar Gambar, Daftar Tabel, or Abstrak pages when not opted-in. | Typst PDF unconditionally emits DAFTAR GAMBAR or DAFTAR TABEL outline because images or tables exist in chapters/; Default metadata.yml emits placeholder ABSTRAK / ABSTRACT without user opt-in; Page numbering restarts or page breaks misalign due to omitted front-matter sections |
| AC-2 | Explicit opt-in controls for Daftar Gambar and Daftar Tabel (daftar_gambar: true, daftar_tabel: true) and Abstrak (abstract_id, abstract_en) deterministically activate each section in both Typst and DOCX output. | When daftar_gambar: true is set and images exist, DAFTAR GAMBAR is rendered; when daftar_gambar: false or omitted, it is omitted. Same behavior for daftar_tabel. | Setting daftar_gambar: true fails to render DAFTAR GAMBAR in Typst or DOCX; Setting daftar_tabel: false still renders DAFTAR TABEL; DOCX and Typst engines drift in outline behavior |
| AC-3 | AI Agent prompt instructions (prompt.md) and Skill specification (.agents/skills/laporan-generator/SKILL.md) enforce an explicit document structure interview step prior to file creation. | prompt.md and SKILL.md state the default 5-element baseline and require asking the user whether they need Abstrak, Lembar Pengesahan, Daftar Gambar, Daftar Tabel, or Lampiran. | AI prompts default to auto-selecting Daftar Gambar and Daftar Tabel; Missing user interview protocol for document structure options in prompt.md or SKILL.md |
| AC-4 | Scaffolding templates and MCP initialization tools reflect the clean minimal default with clear opt-in comments. | Root metadata.yml, skill resource metadata.yml, lib/init.js, and lib/mcp.js provide commented or false default settings for daftar_gambar and daftar_tabel, and commented abstract placeholders. | Freshly initialized project still contains pre-filled dummy abstract text by default; Init script fails or crashes when optional keys are omitted |
| AC-5 | Zero regressions on existing Python and MCP test suites, with new unit tests validating the opt-in logic. | python3 scripts/test_scripts.py passes with new tests for opt-in front matter, and npm run test:mcp passes 100%. | Any existing unit test in test_scripts.py fails; MCP integration tests in tests/test_mcp.js fail |
