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

function showHelp() {
  console.log(`
  ========================================================
         LAPORAN GENERATOR CLI (Multi-Host AI Engine)     
  ========================================================
  Versi: 2.8.0
  
  Penggunaan:
    npx laporan-generator <perintah> [opsi]

  Perintah Utama:
    mcp               Jalankan Model Context Protocol (MCP) Server untuk AI Agent
    sync-hosts        Pasang/sinkronkan AI agent skills & MCP ke Antigravity, Claude, OpenCode
    uninstall         Hapus/bersihkan skill dan perintah dari seluruh AI agent host
    setup             Jalankan installer dependensi otomatis multi-OS (Typst, Pandoc, ImageMagick)
    init              Inisialisasi template dokumen laporan/skripsi di direktori saat ini
    doctor            Audit kesehatan lingkungan dan dependensi dokumen
    stats             Hitung statistik komprehensif dokumen (kata, bab, estimasi halaman)
    build             Kompilasi dokumen ke PDF dan DOCX
    help              Tampilkan panduan ini
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
  case 'stats':
    const statsScript = path.join(__dirname, '../scripts/report-stats.py');
    const pyStatsCmd = getPythonCommand();
    const statsProc = spawnSync(pyStatsCmd, [statsScript, ...args.slice(1)], { stdio: 'inherit' });
    process.exit(statsProc.status || 0);
    break;
  case 'doctor':
  case 'check':
    const doctorScript = path.join(__dirname, '../scripts/report-doctor.py');
    const pyCmd = getPythonCommand();
    const proc = spawnSync(pyCmd, [doctorScript, ...args.slice(1)], { stdio: 'inherit' });
    process.exit(proc.status || 0);
    break;
  case 'build':
    const isWin = process.platform === 'win32';
    if (isWin) {
      const psScript = path.join(__dirname, '../laporan.ps1');
      const winProc = spawnSync('powershell', ['-ExecutionPolicy', 'Bypass', '-File', psScript, 'build'], { stdio: 'inherit' });
      process.exit(winProc.status || 0);
    } else {
      const shScript = path.join(__dirname, '../build.sh');
      const unixProc = spawnSync('bash', [shScript], { stdio: 'inherit' });
      process.exit(unixProc.status || 0);
    }
    break;
  case 'help':
  case '--help':
  case '-h':
  default:
    showHelp();
    break;
}
