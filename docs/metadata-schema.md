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
year: "2025/2026"
date: "Juli 2026"
abstract: |
  Laporan ini membahas pipeline otomatisasi dokumen akademik
  menggunakan Markdown, Pandoc, Typst, dan Bash. Pipeline ini
  memungkinkan penulisan konten laporan dalam format Markdown
  yang kemudian dikonversi menjadi PDF berkualitas percetakan
  melalui Pandoc dan Typst serta berkas Microsoft Word (.docx).
...
```

---

## Penjelasan Field Metadata

| Field | Tipe Data | Wajib? | Keterangan |
|---|---|---|---|
| `title` | String | **Ya** | Judul utama laporan (tampil tebal di halaman sampul). |
| `subtitle` | String | Opsional | Sub-judul atau keterangan tambahan laporan. |
| `author` | List of Objects | **Ya** | Daftar penulis. Setiap entri memiliki `name` dan `nim`. |
| `author[].name` | String | **Ya** | Nama lengkap mahasiswa / penyusun. |
| `author[].nim` | String | **Ya** | Nomor Induk Mahasiswa (NIM / NPM / NISN). |
| `lecturer` | String | **Ya** | Nama lengkap dan gelar Dosen / Guru Pengampu / Pembimbing. |
| `lecturer_label` | String | Opsional | Label peran dosen (default: `"Dosen Pengampu:"`, bisa `"Dosen Pembimbing:"`). |
| `course` | String | **Ya** | Nama Mata Kuliah atau Mata Pelajaran. |
| `institution` | String | **Ya** | Nama Universitas, Institut, Politeknik, atau Sekolah. |
| `faculty` | String | **Ya** | Nama Fakultas, Departemen, atau Program Studi. |
| `year` | String | **Ya** | Tahun Ajaran (contoh: `2025/2026`). |
| `date` | String | Opsional | Bulan dan Tahun pembuatan (contoh: `Juli 2026`). |
| `abstract` | Multiline String | Opsional | Ringkasan/Abstrak laporan dalam Bahasa Indonesia. |

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
