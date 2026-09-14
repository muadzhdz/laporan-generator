# Claimed vs Reality

| AC | Claimed | Reality |
|---|---|---|
| **AC-1** | Windows CLI Doctor: `npx laporan-generator doctor` executes correctly without python3 hardcode error | `bin/laporan-generator.js` implements `getPythonCommand()` detecting `python` vs `python3` dynamically on Windows. Executed `node bin/laporan-generator.js doctor`, returned 100/100 Sehat Sempurna with zero Microsoft Store alias crash. |
| **AC-2** | PowerShell Test Fallback: `.\laporan.ps1 test` gracefully falls back to python unit tests and preset validation | `laporan.ps1` verifies `Test-Path "test.sh"` before invoking bash; when absent, runs `scripts/validate-preset.py --all` (7/7 valid) and `scripts/test_scripts.py` (16/16 passed) without error `/bin/bash: test.sh: No such file or directory`. |
| **AC-3** | Windows Terminal Encoding: `.\laporan.ps1 stats` supports cp1252 without crashing | `scripts/report-stats.py` configures `sys.stdout.reconfigure(encoding="utf-8", errors="replace")` on win32. Visual bar `■` printed cleanly without `UnicodeEncodeError`. |
| **AC-4** | Universal Pandoc Compatibility: `--no-highlight` runs across all Pandoc versions in CI | Replaced `--syntax-highlighting=none` with universal `--no-highlight` in `build.sh` and `laporan.ps1`. GitHub Actions CI build passed 100% (101 passed, 0 failed in 25s). |
| **AC-5** | Unit Test Expansion & Zero Regression | `scripts/test_scripts.py` added `TestReportStats` verifying `count_file_stats`. All 16 unit tests passed in 0.009s; full test suite passed 101/101 assertions. |
