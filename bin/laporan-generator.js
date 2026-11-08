#!/usr/bin/env node
'use strict';

const path = require('path');
const { spawnSync } = require('child_process');

const args = process.argv.slice(2);
const command = args[0] || 'help';

function getPythonCommand() {
  if (process.platform === 'win32') {
    const testPy = spawnSync('python', ['--version'], { stdio: 'ignore' });
    if (testPy.status === 0) return 'python';
    const testPy3 = spawnSync('python3', ['--version'], { stdio: 'ignore' });
    if (testPy3.status === 0) return 'python3';
    return 'python';
  }
  const testPy3 = spawnSync('python3', ['--version'], { stdio: 'ignore' });
  if (testPy3.status === 0) return 'python3';
  return 'python';
}

function exitWithProcess(proc, operation) {
  if (proc.error) {
    console.error(operation + " could not start: " + proc.error.message);
    process.exit(1);
  }
  process.exit(Number.isInteger(proc.status) ? proc.status : 1);
}

function showHelp() {
  console.log(`
  ======================================================================
               LAPORAN GENERATOR CLI (Multi-Host AI Engine)             
       Otomatisasi Dokumen Akademik & Skripsi (Typst + OpenXML DOCX)    
  ======================================================================
  Versi: 4.0.0

  PENGGUNAAN:
    laporan <perintah> [opsi]
    npx laporan-generator <perintah> [opsi]

  1. KOMPILASI & PRATINJAU:
    build               Kompilasi dokumen ke PDF dan Microsoft Word (DOCX) sekaligus
    pdf                 Kompilasi dokumen PDF berkecepatan tinggi via Typst engine
    docx                Kompilasi dokumen Microsoft Word (.docx) dengan penomoran 2-tingkat
    view                Buka dokumen Laporan.pdf pada PDF viewer sistem
    watch               Pantau perubahan berkas dan kompilasi ulang otomatis (live rebuild)
    clean               Bersihkan berkas hasil kompilasi dan direktori temporer

  2. DIAGNOSTIK & KUALITAS AKADEMIK:
    doctor | check      Audit kesehatan lingkungan, sintaks, broken images, dan sitasi
    audit  | forensics  Tinjau pola tulisan (variasi kalimat, MATTR, frasa berulang)
    citations verify    Verifikasi keabsahan tautan dan metadata DOI via Crossref API
    stats               Hitung statistik komprehensif dokumen (kata, bab, estimasi halaman)
    test                Jalankan automated test suite (test.sh)

  3. MANAJEMEN PROYEK & PRESET:
    init                Inisialisasi template dokumen laporan/skripsi di direktori saat ini
    import              Konversi berkas eksternal (DOCX, PDF, PPTX, XLSX) ke Markdown
    preset list         Tampilkan seluruh 14 preset kampus & jurnal yang didukung
    preset show <id>    Tampilkan detail konfigurasi margin & tipografi preset
    preset apply <id>   Terapkan konfigurasi preset ke berkas metadata.yml lokal
    preset diff <id>    Bandingkan konfigurasi metadata lokal dengan preset acuan
    bundle              Kemas dokumen (PDF, DOCX, Markdown) ke dalam arsip zip rilis

  4. INTEGRASI AI AGENT & LINGKUNGAN:
    mcp                 Jalankan native Model Context Protocol (MCP) Server untuk AI Agent
    sync-hosts          Sinkronkan MCP & skills ke Antigravity, Claude Code, dan OpenCode
    setup               Pasang dependensi sistem otomatis (Typst, Pandoc, ImageMagick)
    uninstall           Hapus integrasi skills & symlinks CLI dari seluruh AI host

  OPSI UMUM:
    --preset <id>       Tentukan preset saat init/build (misal: ui-skripsi, itb-ta, jurnal-uajy)
    --strict            Gagal jika skor pola tulisan heuristik > 15 (bukan detektor AI)
    --json              Keluarkan output dalam format JSON terstruktur (machine-readable)
    --all               Audit seluruh berkas Markdown di dalam proyek (bukan hanya chapters)
    --bib <file>        Gunakan berkas BibTeX kustom pada verifikasi sitasi

  CONTOH PENGGUNAAN:
    laporan init skripsi-ku --preset ui-skripsi
    laporan preset list
    laporan preset apply itb-ta
    laporan doctor
    laporan audit --strict
    laporan build
  `);
}

switch (command) {
  case 'mcp':
  case 'server':
    require('../lib/mcp').start();
    break;
  case 'uninstall':
  case 'clean-skills':
    require('../lib/uninstall').run(args.slice(1));
    break;
  case 'sync-hosts':
  case 'sync-skills':
    require('../lib/sync-hosts').run(args.slice(1));
    break;
  case 'setup':
  case 'install-deps':
    require('../lib/setup').run(args.slice(1));
    break;
  case 'init':
    require('../lib/init').run(args.slice(1));
    break;
  case 'import':
  case 'ingest': {
    const ingestScript = path.join(__dirname, '../scripts/ingest.py');
    const pyCmd = getPythonCommand();
    const proc = spawnSync(pyCmd, [ingestScript, ...args.slice(1)], { stdio: 'inherit' });
    exitWithProcess(proc, 'Import');
    break;
  }
  case 'stats': {
    const statsScript = path.join(__dirname, '../scripts/report-stats.py');
    const pyStatsCmd = getPythonCommand();
    const statsProc = spawnSync(pyStatsCmd, [statsScript, ...args.slice(1)], { stdio: 'inherit' });
    exitWithProcess(statsProc, 'Stats');
    break;
  }
  case 'audit':
  case 'forensics': {
    const auditScript = path.join(__dirname, '../scripts/audit-forensics.py');
    const pyCmd = getPythonCommand();
    const proc = spawnSync(pyCmd, [auditScript, ...args.slice(1)], { stdio: 'inherit' });
    exitWithProcess(proc, 'Audit');
    break;
  }
  case 'citations': {
    if (args[1] === 'verify') {
      const citeScript = path.join(__dirname, '../scripts/verify-citations.py');
      const pyCmd = getPythonCommand();
      const proc = spawnSync(pyCmd, [citeScript, ...args.slice(2)], { stdio: 'inherit' });
      exitWithProcess(proc, 'Citation verification');
      break;
    }
    console.log('Penggunaan: ./laporan citations verify [--bib path/to/references.bib]');
    process.exit(0);
    break;
  }
  case 'doctor':
  case 'check': {
    const doctorScript = path.join(__dirname, '../scripts/report-doctor.py');
    const pyCmd = getPythonCommand();
    const proc = spawnSync(pyCmd, [doctorScript, ...args.slice(1)], { stdio: 'inherit' });
    exitWithProcess(proc, 'Doctor');
    break;
  }
  case 'bundle': {
    const bundleScript = path.join(__dirname, '../scripts/bundle.py');
    const pyBundleCmd = getPythonCommand();
    const bundleProc = spawnSync(pyBundleCmd, [bundleScript, ...args.slice(1)], { stdio: 'inherit' });
    exitWithProcess(bundleProc, 'Bundle');
    break;
  }
  case 'preset': {
    const isWinPreset = process.platform === 'win32';
    if (isWinPreset) {
      const psPreset = path.join(__dirname, '../laporan.ps1');
      const winPresetProc = spawnSync('powershell', ['-ExecutionPolicy', 'Bypass', '-File', psPreset, 'preset', ...args.slice(1)], { stdio: 'inherit' });
      exitWithProcess(winPresetProc, 'Preset command');
    } else {
      const shPreset = path.join(__dirname, '../laporan');
      const unixPresetProc = spawnSync('bash', [shPreset, 'preset', ...args.slice(1)], { stdio: 'inherit' });
      exitWithProcess(unixPresetProc, 'Preset command');
    }
    break;
  }
  case 'build': {
    const isWin = process.platform === 'win32';
    if (isWin) {
      const psScript = path.join(__dirname, '../laporan.ps1');
      const winProc = spawnSync('powershell', ['-ExecutionPolicy', 'Bypass', '-File', psScript, 'build'], { stdio: 'inherit' });
      exitWithProcess(winProc, 'Build');
    } else {
      const shScript = path.join(__dirname, '../build.sh');
      const docxScript = path.join(__dirname, '../build-docx.sh');
      const pdfProc = spawnSync('bash', [shScript, ...args.slice(1)], { stdio: 'inherit' });
      if (pdfProc.error || pdfProc.status !== 0) exitWithProcess(pdfProc, 'PDF build');
      const docxProc = spawnSync('bash', [docxScript, ...args.slice(1)], { stdio: 'inherit' });
      exitWithProcess(docxProc, 'DOCX build');
    }
    break;
  }
  case 'pdf': {
    const isWin = process.platform === 'win32';
    if (isWin) {
      const psScript = path.join(__dirname, '../laporan.ps1');
      const winProc = spawnSync('powershell', ['-ExecutionPolicy', 'Bypass', '-File', psScript, 'pdf'], { stdio: 'inherit' });
      exitWithProcess(winProc, 'PDF build');
    } else {
      const shScript = path.join(__dirname, '../build.sh');
      const pdfProc = spawnSync('bash', [shScript, ...args.slice(1)], { stdio: 'inherit' });
      exitWithProcess(pdfProc, 'PDF build');
    }
    break;
  }
  case 'docx': {
    const isWin = process.platform === 'win32';
    if (isWin) {
      const psScript = path.join(__dirname, '../laporan.ps1');
      const winProc = spawnSync('powershell', ['-ExecutionPolicy', 'Bypass', '-File', psScript, 'docx'], { stdio: 'inherit' });
      exitWithProcess(winProc, 'DOCX build');
    } else {
      const docxScript = path.join(__dirname, '../build-docx.sh');
      const docxProc = spawnSync('bash', [docxScript, ...args.slice(1)], { stdio: 'inherit' });
      exitWithProcess(docxProc, 'DOCX build');
    }
    break;
  }
  case 'view': {
    const shScript = path.join(__dirname, '../laporan');
    const proc = spawnSync('bash', [shScript, 'view'], { stdio: 'inherit' });
    exitWithProcess(proc, 'View');
    break;
  }
  case 'watch': {
    const shScript = path.join(__dirname, '../laporan');
    const proc = spawnSync('bash', [shScript, 'watch'], { stdio: 'inherit' });
    exitWithProcess(proc, 'Watch');
    break;
  }
  case 'clean': {
    const shScript = path.join(__dirname, '../laporan');
    const proc = spawnSync('bash', [shScript, 'clean'], { stdio: 'inherit' });
    exitWithProcess(proc, 'Clean');
    break;
  }
  case 'test': {
    const shScript = path.join(__dirname, '../test.sh');
    const proc = spawnSync('bash', [shScript, ...args.slice(1)], { stdio: 'inherit' });
    exitWithProcess(proc, 'Test');
    break;
  }
  case 'help':
  case '--help':
  case '-h':
  default:
    showHelp();
    break;
}
