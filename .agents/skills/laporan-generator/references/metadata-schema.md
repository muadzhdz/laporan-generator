# Spesifikasi Skema Metadata (metadata.yml)

File `metadata.yml` digunakan oleh Pandoc, template Typst (`template.typ`), dan filter DOCX (`docx.lua`) untuk mengisikan informasi sampul (cover page), judul laporan, identitas penyusun, dosen pengampu/pembimbing, serta abstrak laporan.

---

## Struktur File & Contoh Lengkap

```yaml
---
title: "Otomatisasi Pembuatan Dokumen Laporan Akademik Menggunakan Pandoc, Typst, dan Markdown"
subtitle: "Laporan Projek Akhir Pipeline Dokumentasi"
author:
  - name: "Ahmad Dahlan"
    nim: "101234567"
  - name: "Budi Santoso"
    nim: "101234568"
lecturer: "Dr. Ir. Hendra Wijaya, M.T."
lecturer_label: "Dosen Pengampu:"   # Opsional: "Dosen Pembimbing:", "Pembimbing 1:", dll.
course: "Pengolahan Citra Digital dan Pembelajaran Mesin"
institution: "Universitas Gadjah Mada"
faculty: "Departemen Teknik Elektro dan Teknologi Informasi"
department: "Teknologi Informasi"
city: "Yogyakarta"
year: "2025/2026"
date: "Juli 2026"
preset: "ugm-skripsi"
daftar_gambar: false
daftar_tabel: false
# Komponen opsional (aktifkan sesuai kebutuhan):
# approval:
#   city: "Yogyakarta"
#   date: "20 Juli 2026"
#   supervisors:
#     - name: "Dr. Ir. Hendra Wijaya, M.T."
#       nip: "197501012000031001"
#       role: "Pembimbing Utama"
#   dean:
#     name: "Prof. Dr. Eng. Dekan Fakultas, M.T."
#     nip: "196803031992031003"
#     role: "Dekan Fakultas Teknik"
# abstract_id: |
#   Laporan ini membahas pipeline otomatisasi dokumen akademik
#   menggunakan Markdown, Pandoc, Typst, dan Bash.
# keywords_id: ["Pandoc", "Typst", "OpenXML", "Otomatisasi Dokumen"]
# abstract_en: |
#   This report discusses an automated academic document pipeline
#   built with Markdown, Pandoc, Typst, and Bash.
# keywords_en: ["Pandoc", "Typst", "OpenXML", "Document Automation"]
...
```

---

## Penjelasan Field Metadata

| Field | Tipe Data | Wajib? | Keterangan |
|---|---|---|---|
| `title` | String | **Ya** | Judul utama laporan (tampil tebal piramida terbalik di halaman sampul). |
| `subtitle` | String | Opsional | Sub-judul atau keterangan tambahan laporan. |
| `author` | List of Objects | **Ya** | Daftar penulis. Setiap entri memiliki `name` dan `nim`. |
| `author[].name` | String | **Ya** | Nama lengkap mahasiswa / penyusun. |
| `author[].nim` | String | **Ya** | Nomor Induk Mahasiswa (NIM / NPM / NISN). |
| `lecturer` | String | **Ya** | Nama lengkap dan gelar Dosen / Guru Pengampu / Pembimbing. |
| `lecturer_label` | String | Opsional | Label peran dosen (default: `"Dosen Pengampu:"`, bisa `"Dosen Pembimbing:"`). |
| `course` | String | **Ya** | Nama Mata Kuliah atau Jenis Karya Tulis. |
| `institution` | String | **Ya** | Nama Universitas, Institut, Politeknik, atau Sekolah. |
| `faculty` | String | **Ya** | Nama Fakultas, Sekolah, atau Departemen. |
| `department` | String | Opsional | Nama Program Studi atau Jurusan. |
| `city` | String | Opsional | Kota tempat institusi berada (digunakan pada lembar pengesahan). |
| `year` | String | **Ya** | Tahun Ajaran atau Tahun Kelulusan (contoh: `2026` atau `2025/2026`). |
| `date` | String | Opsional | Bulan dan Tahun pembuatan (contoh: `Juli 2026`). |
| `preset` | String | Opsional | ID preset format kampus (`standard`, `skripsi-4433`, `ui-skripsi`, `itb-ta`, `ugm-skripsi`, `its-skripsi`, `unpad-skripsi`, `ub-skripsi`, `undip-skripsi`, `unair-skripsi`, `ipb-ppki`, `telkom-ta`). |
| `daftar_gambar` | Boolean | Opsional | Aktifkan halaman DAFTAR GAMBAR (`true`/`false`, default: `false`). |
| `daftar_tabel` | Boolean | Opsional | Aktifkan halaman DAFTAR TABEL (`true`/`false`, default: `false`). |
| `approval` | Object | Opsional | Konfigurasi Lembar Pengesahan (`city`, `date`, `supervisors[]`, `dean`). |
| `abstract_id` | Multiline String | Opsional | Ringkasan/Abstrak laporan dalam Bahasa Indonesia (Opt-In). |
| `keywords_id` | List of Strings | Opsional | Daftar kata kunci Bahasa Indonesia. |
| `abstract_en` | Multiline String | Opsional | Ringkasan/Abstract laporan dalam Bahasa Inggris (Opt-In). |
| `keywords_en` | List of Strings | Opsional | Daftar kata kunci Bahasa Inggris (Keywords). |

---

## Dukungan Multi-Author (Individu / Kelompok)

Skema ini mendukung jumlah penulis dinamis (1 orang hingga banyak orang):

* **Single Author (Individu)**:
  ```yaml
  author:
    - name: "Budi Santoso"
      nim: "101234567"
  ```

* **Multi Author (Kelompok)**:
  ```yaml
  author:
    - name: "Mahasiswa A"
      nim: "101234561"
    - name: "Mahasiswa B"
      nim: "101234562"
    - name: "Mahasiswa C"
      nim: "101234563"
  ```
