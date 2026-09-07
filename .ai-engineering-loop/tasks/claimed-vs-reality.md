# Claimed vs Reality

| AC | Claimed | Reality |
|---|---|---|
| AC-1 | ShellCheck zero-warning pass on build.sh, laporan, and test.sh | `shellcheck build.sh laporan test.sh` exited 0 with 0 warnings, 0 errors. |
| AC-2 | YAML input sanitization in laporan/laporan.ps1 and robust validate-preset.py parser with domain-specific exception handling | `yaml_escape` verified by behavioral execution in test.sh line 522 (`\"Laporan\" \ Keandalan`); `validate-preset.py` handles `(ImportError, ModuleNotFoundError)` and passed 7/7 presets. |
| AC-3 | Subprocess timeout and defensive exception handling in docx-pagenum.py | `docx-pagenum.py` specifies timeout=15 for pdfinfo/pdftotext and timeout=45 for soffice, catching TimeoutExpired and SubprocessError gracefully. |
| AC-4 | Native PowerShell watch command with scriptPath resolution and docs/syntax-cheatsheet.md | `laporan.ps1` contains Cmd-Watch resolving `$using:scriptPath` or `Cmd-Build`; `docs/syntax-cheatsheet.md` created with APA citations, math, tables, images. |
| AC-5 | Python unit test suite and 100% test.sh pass | `python3 scripts/test_scripts.py` ran 8 tests in 0.045s (OK); `./test.sh` passed 96/96 assertions (0 failed). |
