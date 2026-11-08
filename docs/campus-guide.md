# Panduan Preset & Kustomisasi Format Kampus

Dokumen ini menjelaskan preset awal (`presets/*.yml`) untuk membantu menata laporan akademik. Pedoman dapat berbeda antar fakultas, program studi, dan tahun akademik. Anggap setiap preset sebagai titik awal; cocokkan dengan pedoman resmi program Anda sebelum mengumpulkan dokumen.

---

## 1. Menggunakan Preset Kampus

Setiap perguruan tinggi memiliki aturan tata letak, margin, jenis huruf, dan gaya sampul tersendiri. Anda dapat memilih preset yang diinginkan melalui berkas `metadata.yml`:

```yaml
preset: "itb-ta"   # Ganti dengan ID preset kampus Anda
```

Atau gunakan bantuan CLI interaktif:
```bash
./laporan preset list                # Lihat semua preset yang tersedia
./laporan preset show ui-skripsi      # Lihat rincian konfigurasi preset
./laporan preset apply itb-ta        # Terapkan langsung ke metadata.yml
```

> **Kompatibilitas**: Field lama `margin_preset: "skripsi-4433"` atau `margin_preset: "standard"` tetap didukung penuh.

---

## 2. Daftar Preset Kampus Bawaan

| ID Preset | Institusi / Format | Margin (Atas - Bawah - Kiri - Kanan) | Catatan |
|---|---|---|---|
| `standard` | Standar Modern | 2.0 cm - 3.0 cm - 2.5 cm - 2.5 cm | Format default tugas akhir, magang, praktikum |
| `skripsi-4433` | Skripsi Tradisional | 4.0 cm - 3.0 cm - 4.0 cm - 3.0 cm | Hardcover jilid tebal margin kiri 4cm |
| `ui-skripsi` | Universitas Indonesia (UI) | 3.0 cm - 3.0 cm - 4.0 cm - 3.0 cm | Preset awal; cek pedoman fakultas/prodi dan tahun berlaku |
| `itb-ta` | Institut Teknologi Bandung (ITB) | 4.0 cm - 3.0 cm - 4.0 cm - 3.0 cm | Preset awal; ketentuan dapat berbeda per unit akademik |
| `ugm-skripsi` | Universitas Gadjah Mada (UGM) | 4.0 cm - 3.0 cm - 4.0 cm - 3.0 cm | Preset awal; cek pedoman fakultas/prodi |
| `its-skripsi` | Institut Teknologi Sepuluh Nopember (ITS) | 3.0 cm - 2.5 cm - 3.0 cm - 2.0 cm | Preset awal; cek pedoman departemen dan tahun berlaku |
| `unpad-skripsi` | Universitas Padjadjaran (UNPAD) | 4.0 cm - 3.0 cm - 4.0 cm - 3.0 cm | Preset awal; cek pedoman fakultas/prodi |
| `ub-skripsi` | Universitas Brawijaya (UB) | 4.0 cm - 3.0 cm - 4.0 cm - 3.0 cm | Preset awal; cek pedoman fakultas/prodi |
| `undip-skripsi` | Universitas Diponegoro (UNDIP) | 4.0 cm - 3.0 cm - 4.0 cm - 3.0 cm | Preset awal; cek pedoman fakultas/prodi |
| `unair-skripsi` | Universitas Airlangga (UNAIR) | 4.0 cm - 3.0 cm - 4.0 cm - 3.0 cm | Preset awal; cek pedoman fakultas/prodi |
| `ipb-ppki` | IPB University (PPKI) | 3.0 cm - 3.0 cm - 4.0 cm - 3.0 cm | PPKI edisi 4; mahasiswa baru perlu cek PPTA yang berlaku |
| `telkom-ta` | Telkom University (Tel-U) | 3.0 cm - 3.0 cm - 4.0 cm - 3.0 cm | Preset awal; cek pedoman program studi |
| `jurnal-uajy` | Univ. Atma Jaya Yogyakarta (UAJY) | 3.0 cm - 3.0 cm - 3.0 cm - 3.0 cm | Titik awal; ikuti template author guideline jurnal terbaru |
| `jurnal-standar` | Jurnal Nasional / SINTA | 3.0 cm - 3.0 cm - 3.0 cm - 3.0 cm | Format artikel jurnal nasional standar (IEEE/APA, tanpa cover/TOC) |

Preset kampus tidak menjamin kepatuhan pada pedoman tertentu. Variasi tingkat fakultas terlihat pada pedoman resmi [UI](https://pascakomunikasi.fisip.ui.ac.id/pedoman-teknis-penulisan-tugas-akhir-mahasiswa/), [ITS](https://www.its.ac.id/pendidikan/2022/03/24/pedoman-penyusunan-laporan-tugas-proyek-akhir-program-sarjana-dan-sarjana-terapan/), [UNAIR FST](https://fst.unair.ac.id/wp-content/uploads/2024/05/Panduan-Skripsi-FST-UNAIR_2022-REVISI.pdf), dan [UB FIA](https://fia.ub.ac.id/wp-content/uploads/2025/01/Pedoman-Tugas-Akhir-FIA-UB-2024.pdf). [IPB mengumumkan PPTA baru berlaku mulai semester ganjil 2026/2027](https://panduan.ipb.ac.id/panduan-ppta/); preset `ipb-ppki` mewakili PPKI edisi 4 dan bukan klaim kepatuhan terhadap pedoman baru itu.

---

## 3. Contoh Konfigurasi Berbagai Kampus

### A. Format Universitas Indonesia (UI)
```yaml
title: "IMPLEMENTASI DEEP LEARNING UNTUK DETEKSI PENYAKIT PADA CITRA MEDIS"
subtitle: "LAPORAN TUGAS AKHIR"
course: "Proyek Perangkat Lunak Lanjut"
lecturer: "Prof. Dr. Ir. Dosen Pengampu, M.Sc."
author:
  - name: "Nama Mahasiswa"
    nim: "2106012345"
institution: "UNIVERSITAS INDONESIA"
faculty: "FAKULTAS ILMU KOMPUTER"
year: "2026"
preset: "ui-skripsi"
```

### B. Format Institut Teknologi Bandung (ITB)
```yaml
title: "RANCANG BANGUN SISTEM KONTROL DAN MONITORING SMART GRID BERBASIS IOT"
subtitle: "LAPORAN TUGAS AKHIR"
course: "Sistem Tertanam"
author:
  - name: "Nama Mahasiswa"
    nim: "13521001"
institution: "INSTITUT TEKNOLOGI BANDUNG"
faculty: "SEKOLAH TEKNIK ELEKTRO DAN INFORMATIKA"
year: "2026"
preset: "itb-ta"
```

### C. Format Universitas Gadjah Mada (UGM)
```yaml
title: "ANALISIS PERFORMA ARSITEKTUR MICROSERVICES PADA CLOUD COMPUTING"
subtitle: "LAPORAN PRAKTIKUM LAPANGAN"
course: "Rekayasa Perangkat Lunak"
lecturer: "Dr. Dosen Pengampu, S.Kom., M.Cs."
author:
  - name: "Mahasiswa Satu"
    nim: "21/475123/TK/52123"
  - name: "Mahasiswa Dua"
    nim: "21/475124/TK/52124"
institution: "UNIVERSITAS GADJAH MADA"
faculty: "FAKULTAS TEKNIK"
year: "2026"
preset: "ugm-skripsi"
```

### D. Format Artikel Jurnal UAJY (Jurnal Berita Informatika)
```yaml
title: "RANCANG BANGUN PLATFORM INTERAKTIF BERBASIS WEB DENGAN METODE MULTIMEDIA DEVELOPMENT LIFE CYCLE"
author:
  - name: "Mu'adz Hudzaifah"
    nim: "24903460014"
    affiliation: "Program Studi Informatika, Universitas Atma Jaya Yogyakarta"
    email: "muadz@students.uajy.ac.id"
institution: "Universitas Atma Jaya Yogyakarta"
faculty: "Fakultas Teknologi Industri"
department: "Informatika"
year: "2026"
preset: "jurnal-uajy"
doc_type: "journal"
abstract_id: |
  Penelitian ini merancang platform web interaktif menggunakan metode MDLC...
keywords_id: ["MDLC", "Web Platform", "Robotika"]
abstract_en: |
  This study designs an interactive web platform using MDLC method...
keywords_en: ["MDLC", "Web Platform", "Robotics"]
```

---

## 4. Mengganti Logo Kampus
Cukup salin gambar logo resmi kampus Anda ke direktori utama dengan nama **`logo.jpg`** (atau format PNG yang dikonversi ke JPEG):
```bash
cp /path/ke/logo-kampus.png logo.jpg
```
Pipeline akan secara otomatis menyesuaikan ukuran dan memposisikannya secara proporsional di tengah halaman sampul sesuai konfigurasi `cover_logo_width` pada preset.

---

## 5. Memindai Otomatis Pedoman Kampus Baru (PDF Scanner)

Jika kampus Anda belum tersedia di daftar preset bawaan, Anda dapat memindai berkas PDF Buku Pedoman Penulisan Skripsi / Tugas Akhir kampus Anda secara otomatis:

```bash
./laporan preset scan /path/ke/pedoman-penulisan-kampus.pdf
```

Sistem pemindai cerdas akan:
1. Mengekstraksi teks dokumen dan mencari pasal format fisik/tata cara pengetikan.
2. Mendeteksi margin (kiri, atas, kanan, bawah), jenis dan ukuran font, spasi baris, format penomoran bab/sub-bab, dan nama institusi.
3. Menampilkan ringkasan temuan aturan format di terminal.
4. Menyimpan konfigurasi otomatis ke berkas `presets/<preset-id>.yml`.

Contoh pemindaian dengan opsi khusus:
```bash
./laporan preset scan pedoman-unpad.pdf --preset-id unpad-skripsi --name "Universitas Padjadjaran" --apply
```

---

## 6. Membuat Preset Kustom Secara Manual
Selain pemindaian otomatis, Anda juga dapat menulis berkas preset YAML baru secara manual di direktori `presets/`. Baca panduan lengkapnya di [docs/preset-schema.md](preset-schema.md).
