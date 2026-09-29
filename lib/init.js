'use strict';

const fs = require('fs');
const path = require('path');

const os = require('os');

function copyRecursiveSync(src, dest) {
  if (!fs.existsSync(src)) return;
  const stats = fs.statSync(src);
  if (stats.isDirectory()) {
    if (!fs.existsSync(dest)) {
      fs.mkdirSync(dest, { recursive: true });
    }
    fs.readdirSync(src).forEach((childItemName) => {
      copyRecursiveSync(path.join(src, childItemName), path.join(dest, childItemName));
    });
  } else {
    fs.copyFileSync(src, dest);
  }
}

function initProject(options = {}) {
  const targetDir = options.targetDir ? path.resolve(options.targetDir) : process.cwd();
  const silent = !!options.silent;
  const isTruthy = (val) => val === true || val === 'true';

  if (!fs.existsSync(targetDir)) {
    fs.mkdirSync(targetDir, { recursive: true });
  }

  const metaPath = path.join(targetDir, 'metadata.yml');
  if (fs.existsSync(metaPath) && !options.force) {
    if (!silent) {
      console.log('[WARN] Dokumen laporan sudah ada di direktori ini (metadata.yml ditemukan).');
    }
    return {
      success: false,
      alreadyExists: true,
      targetDir,
      message: 'Dokumen laporan sudah ada di direktori ini (metadata.yml ditemukan).'
    };
  }

  // Cari direktori resources (prioritas: skill resources, package root, global home)
  const candidates = [
    path.join(__dirname, '../.agents/skills/laporan-generator/resources'),
    path.join(__dirname, '..'),
    path.join(os.homedir(), '.agents/skills/laporan-generator/resources'),
    path.join(os.homedir(), '.gemini/config/skills/laporan-generator/resources')
  ];

  let sourceDir = null;
  for (const c of candidates) {
    if (fs.existsSync(path.join(c, 'template.typ')) && fs.existsSync(path.join(c, 'metadata.yml'))) {
      sourceDir = c;
      break;
    }
  }

  const copiedFiles = [];

  if (sourceDir) {
    if (!silent) console.log(`Menyalin template lengkap dari: ${sourceDir} ...\n`);
    const filesToCopy = [
      'metadata.yml',
      'cover.md',
      'references.bib',
      'apa.csl',
      'logo.jpg',
      'template.typ',
      'reference.docx',
      'docx.lua',
      'Makefile',
      'build.sh',
      'build-docx.sh',
      'laporan',
      'laporan.ps1',
      'presets',
      'chapters',
      'scripts'
    ];

    for (const f of filesToCopy) {
      const srcFile = path.join(sourceDir, f);
      const destFile = path.join(targetDir, f);
      if (fs.existsSync(srcFile) && (!fs.existsSync(destFile) || options.force)) {
        copyRecursiveSync(srcFile, destFile);
        copiedFiles.push(f);
        if (!silent) console.log(`  ✔ Disalin: ${f}`);
      }
    }
  } else {
    // Fallback manual jika source resources tidak ditemukan
    const defaultMeta = `---
title: "${options.title || 'Laporan Akademik & Proyek'}"
subtitle: "Laporan Penelitian / Tugas Akhir"
author:
  - name: "${options.authorName || 'Nama Penulis'}"
    nim: "${options.authorId || '1234567890'}"
date: "${options.year || '2026'}"
institution: "${options.institution || 'Universitas / Institusi Akademik'}"
faculty: "${options.faculty || 'Fakultas Teknik'}"
department: "${options.department || 'Program Studi Informatika'}"
year: "${options.year || '2026'}"
preset: "${options.preset || 'skripsi-4433'}"
daftar_gambar: ${isTruthy(options.daftar_gambar) ? 'true' : 'false'}
daftar_tabel: ${isTruthy(options.daftar_tabel) ? 'true' : 'false'}
...
`;
    fs.writeFileSync(metaPath, defaultMeta, 'utf8');
    copiedFiles.push('metadata.yml');

    const coverPath = path.join(targetDir, 'cover.md');
    fs.writeFileSync(coverPath, '# Laporan Akademik\n\nDokumen ini disusun sebagai dokumentasi resmi laporan proyek/penelitian.\n', 'utf8');
    copiedFiles.push('cover.md');

    const chaptersDir = path.join(targetDir, 'chapters');
    if (!fs.existsSync(chaptersDir)) fs.mkdirSync(chaptersDir, { recursive: true });
    const bab1 = `# Pendahuluan\n\n## Latar Belakang\nTuliskan latar belakang masalah di sini.\n\n## Rumusan Masalah\n1. Masalah pertama.\n2. Masalah kedua.\n\n## Tujuan Penelitian\nTujuan dari pelaksanaan proyek ini adalah menghasilkan analisis yang komprehensif.\n`;
    fs.writeFileSync(path.join(chaptersDir, 'bab1-pendahuluan.md'), bab1, 'utf8');
    copiedFiles.push('chapters/bab1-pendahuluan.md');

    const refBibPath = path.join(targetDir, 'references.bib');
    fs.writeFileSync(refBibPath, `@book{contoh2026,\n  title     = {Panduan Penulisan Karya Ilmiah},\n  author    = {Penulis, Contoh},\n  year      = {2026},\n  publisher = {Penerbit Akademik}\n}\n`, 'utf8');
    copiedFiles.push('references.bib');
  }

  // Update metadata.yml if custom options were provided
  if (fs.existsSync(metaPath) && (options.title || options.preset || options.authorName || options.institution || options.daftar_gambar !== undefined || options.daftar_tabel !== undefined)) {
    try {
      let metaContent = fs.readFileSync(metaPath, 'utf8');
      if (options.title) {
        metaContent = metaContent.replace(/^title:\s*".*?"/m, `title: "${options.title.replace(/"/g, '\\"')}"`);
      }
      if (options.preset) {
        metaContent = metaContent.replace(/^preset:\s*".*?"/m, `preset: "${options.preset}"`);
      }
      if (options.institution) {
        metaContent = metaContent.replace(/^institution:\s*".*?"/m, `institution: "${options.institution.replace(/"/g, '\\"')}"`);
      }
      if (options.faculty) {
        metaContent = metaContent.replace(/^faculty:\s*".*?"/m, `faculty: "${options.faculty.replace(/"/g, '\\"')}"`);
      }
      if (options.department) {
        metaContent = metaContent.replace(/^department:\s*".*?"/m, `department: "${options.department.replace(/"/g, '\\"')}"`);
      }
      if (options.year) {
        metaContent = metaContent.replace(/^year:\s*".*?"/m, `year: "${options.year}"`);
      }
      if (options.authorName) {
        metaContent = metaContent.replace(/name:\s*".*?"/, `name: "${options.authorName.replace(/"/g, '\\"')}"`);
        if (options.authorId) {
          metaContent = metaContent.replace(/nim:\s*".*?"/, `nim: "${options.authorId}"`);
        }
      }
      if (options.daftar_gambar !== undefined) {
        const val = isTruthy(options.daftar_gambar) ? 'true' : 'false';
        if (/^daftar_gambar:\s*(true|false)/m.test(metaContent)) {
          metaContent = metaContent.replace(/^daftar_gambar:\s*(true|false)/m, `daftar_gambar: ${val}`);
        } else {
          metaContent = metaContent.replace(/preset:\s*".*?"/m, `daftar_gambar: ${val}\n$&`);
        }
      }
      if (options.daftar_tabel !== undefined) {
        const val = isTruthy(options.daftar_tabel) ? 'true' : 'false';
        if (/^daftar_tabel:\s*(true|false)/m.test(metaContent)) {
          metaContent = metaContent.replace(/^daftar_tabel:\s*(true|false)/m, `daftar_tabel: ${val}`);
        } else {
          metaContent = metaContent.replace(/preset:\s*".*?"/m, `daftar_tabel: ${val}\n$&`);
        }
      }
      fs.writeFileSync(metaPath, metaContent, 'utf8');
    } catch (err) {
      console.warn(`[init] Failed to customize metadata.yml: ${err.message}`);
    }
  }

  // Ensure scripts are executable on Unix
  try {
    if (process.platform !== 'win32') {
      const laporanBin = path.join(targetDir, 'laporan');
      const buildSh = path.join(targetDir, 'build.sh');
      if (fs.existsSync(laporanBin)) fs.chmodSync(laporanBin, '755');
      if (fs.existsSync(buildSh)) fs.chmodSync(buildSh, '755');
    }
  } catch (err) {
    console.warn(`[init] Failed to set executable permissions: ${err.message}`);
  }

  return {
    success: true,
    targetDir,
    copiedFiles,
    message: 'Inisialisasi dokumen selesai dengan sukses.'
  };
}

function run(argv = []) {
  const cwd = process.cwd();
  console.log('\n==========================================================');
  console.log('   LAPORAN GENERATOR - INISIALISASI PROYEK DOKUMEN       ');
  console.log('==========================================================\n');

  const res = initProject({ targetDir: cwd });
  if (res.success) {
    console.log('\n✨ Inisialisasi dokumen selesai!');
    console.log('Jalankan "./laporan build" atau "npx laporan-generator build" untuk mengompilasi dokumen ke PDF & Word!\n');
  }
}

module.exports = { run, initProject };
