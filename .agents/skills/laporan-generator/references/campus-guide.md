# Panduan Preset & Kustomisasi Format Kampus

Dokumen ini berisi panduan untuk menyesuaikan format laporan akademik sesuai dengan pedoman penulisan di berbagai perguruan tinggi di Indonesia menggunakan sistem **Preset Declarative** (`presets/*.yml`).

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

| ID Preset | Institusi / Format | Margin (Atas - Bawah - Kiri - Kanan) | Catatan Khusus |
|---|---|---|---|
| `standard` | Standar Modern | 2.0 cm - 3.0 cm - 2.5 cm - 2.5 cm | Format default tugas akhir, magang, praktikum |
| `skripsi-4433` | Skripsi Tradisional | 4.0 cm - 3.0 cm - 4.0 cm - 3.0 cm | Hardcover jilid tebal margin kiri 4cm |
| `ui-skripsi` | Universitas Indonesia (UI) | 3.0 cm - 3.0 cm - 4.0 cm - 3.0 cm | Sesuai Pedoman Teknis Tugas Akhir UI |
| `itb-ta` | Institut Teknologi Bandung (ITB) | 4.0 cm - 3.0 cm - 4.0 cm - 3.0 cm | Cover minimalis (tanpa dosen pembimbing di cover luar) |
| `ugm-skripsi` | Universitas Gadjah Mada (UGM) | 4.0 cm - 3.0 cm - 4.0 cm - 3.0 cm | Full academic cover |
| `its-skripsi` | Institut Teknologi Sepuluh Nopember (ITS) | 3.0 cm - 2.5 cm - 3.0 cm - 2.0 cm | Sesuai Buku Pedoman TA & Tesis ITS |
| `unpad-skripsi` | Universitas Padjadjaran (UNPAD) | 4.0 cm - 3.0 cm - 4.0 cm - 3.0 cm | Format skripsi & karya ilmiah UNPAD |
| `ub-skripsi` | Universitas Brawijaya (UB) | 4.0 cm - 3.0 cm - 4.0 cm - 3.0 cm | Pedoman penulisan skripsi UB |
| `undip-skripsi` | Universitas Diponegoro (UNDIP) | 4.0 cm - 3.0 cm - 4.0 cm - 3.0 cm | Pedoman akademik skripsi UNDIP |
| `unair-skripsi` | Universitas Airlangga (UNAIR) | 4.0 cm - 3.0 cm - 4.0 cm - 3.0 cm | Pedoman penulisan karya ilmiah UNAIR |
| `ipb-ppki` | IPB University (PPKI) | 3.0 cm - 3.0 cm - 4.0 cm - 3.0 cm | Pedoman PPKI IPB (Indent 1cm, sub-bab tanpa titik akhir) |
| `telkom-ta` | Telkom University (Tel-U) | 3.0 cm - 3.0 cm - 4.0 cm - 3.0 cm | Pedoman Buku Tugas Akhir Telkom University |

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
