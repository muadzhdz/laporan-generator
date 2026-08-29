# Spesifikasi Skema Metadata (metadata.yml)

File `metadata.yml` digunakan oleh Pandoc, Typst, dan engine DOCX untuk mengisikan informasi sampul (cover page), lembar pengesahan, abstrak dwibahasa, identitas penyusun, dosen pengampu, serta konfigurasi preset format.

---

## Struktur File & Contoh Lengkap

```yaml
---
title: "Otomatisasi Pembuatan Dokumen Laporan Akademik Menggunakan Pandoc, Typst, dan Markdown"
subtitle: "Laporan Dokumentasi Pipeline dan Arsitektur Multi-Engine"
author:
  - name: "Ahmad Dahlan"
    nim: "101234567"
  - name: "Budi Santoso"
    nim: "101234568"
lecturer: "Dr. Ir. Hendra Wijaya, M.T."
course: "Pengolahan Citra Digital dan Pembelajaran Mesin"
institution: "Universitas Gadjah Mada"
faculty: "Departemen Teknik Elektro dan Teknologi Informasi"
year: "2025/2026"
date: "Juli 2026"
preset: "standard"

# --- Lembar Pengesahan (Opsional) ---
approval:
  enable: true
  title: "LEMBAR PENGESAHAN"
  city: "Yogyakarta"
  date: "28 Agustus 2026"
  degree: "Sarjana Komputer (S.Kom.)"
  advisors:
    - name: "Dr. Ir. Hendra Wijaya, M.T."
      nip: "197508152000031002"
      role: "Pembimbing Utama"
    - name: "Dr. Techn. Saiful Akbar, S.T., M.T."
      nip: "197203101997021001"
      role: "Pembimbing Pendamping"
  head_of_department:
    name: "Prof. Dr. Eng. Budi Rahardjo, M.T."
    nip: "196503121990031003"
    role: "Ketua Departemen Teknik Elektro dan Teknologi Informasi"

# --- Abstrak Dwibahasa (Opsional) ---
abstrak: |
  Laporan ini membahas perancangan dan implementasi pipeline otomatisasi pembuatan
  dokumen akademik modern menggunakan Markdown, Pandoc, Typst, Lua Filter, dan
  multi-pass DOCX engine.
kata_kunci:
  - "Otomatisasi Dokumen"
  - "Pandoc"
  - "Typst"
  - "Skripsi"

abstract_en: |
  This report discusses the design and implementation of a modern academic
  document automation pipeline using Markdown, Pandoc, Typst, Lua Filter, and
  multi-pass DOCX engine.
keywords_en:
  - "Document Automation"
  - "Pandoc"
  - "Typst"
  - "Thesis"
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
| `lecturer` | String | **Ya** | Nama lengkap dan gelar Dosen / Guru Pengampu. |
| `course` | String | **Ya** | Nama Mata Kuliah atau Mata Pelajaran. |
| `institution` | String | **Ya** | Nama Universitas, Institut, Politeknik, atau Sekolah. |
| `faculty` | String | **Ya** | Nama Fakultas, Departemen, atau Program Studi. |
| `year` | String | **Ya** | Tahun Ajaran (contoh: `2025/2026`). |
| `date` | String | Opsional | Bulan dan Tahun pembuatan (contoh: `Juli 2026`). |
| `preset` | String | Opsional | ID Preset kampus (contoh: `standard`, `skripsi-4433`, `itb-ta`, `ui-skripsi`). |
| `approval` | Object | Opsional | Konfigurasi Lembar Pengesahan (lihat rincian di bawah). |
| `abstrak` (atau `abstract`) | Multiline String | Opsional | Teks Abstrak Bahasa Indonesia. |
| `kata_kunci` | List / String | Opsional | Daftar kata kunci Bahasa Indonesia. |
| `abstract_en` | Multiline String | Opsional | Teks Abstract Bahasa Inggris (diformat cetak miring / *italic*). |
| `keywords_en` | List / String | Opsional | Daftar keywords Bahasa Inggris (cetak miring / *italic*). |

---

## Rincian Konfigurasi Lembar Pengesahan (`approval`)

| Field | Tipe Data | Keterangan |
|---|---|---|
| `approval.enable` | Boolean | `true` untuk mengaktifkan rendering lembar pengesahan. |
| `approval.title` | String | Judul halaman (default: `LEMBAR PENGESAHAN`). |
| `approval.city` | String | Nama kota pengesahan (contoh: `Bandung`, `Jakarta`, `Yogyakarta`). |
| `approval.date` | String | Tanggal pengesahan dokumen. |
| `approval.degree` | String | Program studi / gelar akademik yang dituju. |
| `approval.advisors` | List of Objects | Daftar dosen pembimbing (`name`, `nip`, `role`). |
| `approval.head_of_department` | Object | Data pimpinan jurusan / ketua program studi (`name`, `nip`, `role`). |

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

