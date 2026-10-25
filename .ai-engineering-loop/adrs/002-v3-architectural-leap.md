# ADR 002: v3.0.0 Architectural Leap - Ingestion Pipeline, Single-Pass OpenXML, and Documentation Modernization

## Status
Accepted

## Context
In v2.x, Laporan Generator evolved as a dual-engine compiler (Markdown to Typst PDF and Pandoc DOCX) with native MCP integration and university presets. However, several architectural bottlenecks were identified:
1. Ingestion bottleneck: The pipeline was strictly one-directional (Markdown -> Output). Users with pre-existing Word (.docx), PDF, or slide (.pptx) documents had to manually convert content to Markdown.
2. DOCX processing overhead: Post-processing DOCX required double unzipping to disk and raw regex replacements on XML strings (`finalize-docx.py` and `docx-pagenum.py`), resulting in unnecessary I/O and schema fragility.
3. Documentation clutter: `README.md` was overly verbose (~600 lines / 24 KB), obscuring the tool's core capabilities and hurting onboarding developer experience.
4. Release naming: GitHub release action defaulted to generic `Release ${{ github.ref_name }}` instead of tool-identified `laporan-generator ${{ github.ref_name }}`.

## Decision
1. Ingestion Pipeline: Integrate Microsoft MarkItDown (`scripts/ingest.py`) to support bidirectional workflows, enabling direct ingestion of DOCX, PDF, PPTX, and XLSX into structured Markdown chapters with graceful fallback.
2. Single-Pass OpenXML Engine: Consolidate DOCX post-processing into an atomic, in-memory pass using Python's standard `zipfile` and `xml.etree.ElementTree` DOM parser, eliminating double-unzip roundtrips and regex replacements.
3. Next-Gen MCP 2.0: Expand the native Model Context Protocol server to expose standard MCP Resources (`laporan://presets`, `laporan://docs`) and MCP Prompts alongside Tools.
4. Minimalist Documentation: Overhaul `README.md` into an ultra-clean, senior-developer aesthetic (<= 120 lines), delegating detailed campus guides and schemas to `docs/`.
5. Release Pipeline Standardization: Configure `.github/workflows/release.yml` to publish releases with the standardized prefix `laporan-generator ${{ github.ref_name }}`.

## Consequences
- Transforms Laporan Generator into a complete bidirectional academic workflow engine.
- DOCX compilation performance improves significantly with zero XML corruption risks.
- Developer experience matches world-class modern developer CLI tools.
- Backward compatibility for existing Markdown chapters and presets is fully preserved.
