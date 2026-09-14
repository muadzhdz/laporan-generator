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
  Versi: 2.6.1
  
  Penggunaan:
    npx laporan-generator <perintah> [opsi]

  Perintah Utama:
    sync-hosts        Pasang/sinkronkan AI agent skills ke Antigravity, Claude, Grok
    uninstall         Hapus/bersihkan skill dan perintah dari seluruh AI agent host
    setup             Jalankan installer dependensi otomatis multi-OS (Typst, Pandoc, ImageMagick)
    init              Inisialisasi template dokumen laporan/skripsi di direktori saat ini
    doctor            Audit kesehatan lingkungan dan dependensi dokumen
    build             Kompilasi dokumen ke PDF dan DOCX
    help              Tampilkan panduan ini
  `);
}

switch (command) {
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
  case 'doctor':
  case 'check':
    const doctorScript = path.join(__dirname, '../scripts/report-doctor.py');
    const pyCmd = getPythonCommand();
    const proc = spawnSync(pyCmd, [doctorScript], { stdio: 'inherit' });
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
