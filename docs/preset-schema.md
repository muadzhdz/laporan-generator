# Spesifikasi Skema Preset Format Kampus (Preset Schema)

File preset format kampus disimpan di dalam direktori `presets/<preset-id>.yml`. File ini mendefinisikan aturan tata letak visual (*page geometry*), tipografi, gaya penomoran heading, serta susunan sampul (*cover page*) untuk dokumen PDF (Typst) dan Word (DOCX).

---

## Contoh Lengkap Skema Preset

```yaml
# presets/itb-ta.yml
preset_id: "itb-ta"
name: "Institut Teknologi Bandung (ITB)"
description: "Format Tugas Akhir / Tesis sesuai Pedoman Penulisan Karya Ilmiah ITB."

# 1. Geometri & Margin Halaman
margin_top: 4cm
margin_bottom: 3cm
margin_left: 4cm
margin_right: 3cm

# 2. Tipografi & Spasi
font_family: "Libertinus Serif"   # Font utama (Times New Roman standard)
font_size: 12pt                  # Ukuran teks isi
line_spacing: 0.75em             # Spasi antar baris (1.5 spasi)
first_line_indent: 1.25cm        # Indentasi awal paragraf

# 3. Penomoran Heading
heading_chapter_prefix: "BAB "   # Prefix bab ("BAB ")
heading_chapter_num_format: "roman" # Angka Romawi ("roman") atau Arab ("arabic")
heading_sub_dot: true            # true: "1.1." | false: "1.1"
heading_subsub_dot: false        # true: "1.1.1." | false: "1.1.1"

# 4. Pengaturan Halaman Sampul (Cover)
cover_show_lecturer: false       # true: tampilkan dosen | false: sembunyikan
cover_hide_lecturer: true        # Flag pembantu untuk parser
cover_logo_width: 4.5cm          # Lebar logo di sampul depan
```

---

## Daftar Field & Tipe Data

| Kategori | Field | Tipe Data | Nilai Bawaan (Default) | Keterangan |
|---|---|---|---|---|
| **Identitas** | `preset_id` | String | *Nama file tanpa .yml* | ID unik preset (contoh: `ui-skripsi`). |
| | `name` | String | - | Nama lengkap format / institusi. |
| | `description` | String | - | Penjelasan singkat karakteristik preset. |
| | `doc_type` | String | `thesis` | Tipe dokumen (`thesis` atau `journal`). |
| **Margin** | `margin_top` | String / Satuan | `2cm` | Jarak batas atas halaman. |
| | `margin_bottom` | String / Satuan | `3cm` | Jarak batas bawah halaman. |
| | `margin_left` | String / Satuan | `2.5cm` | Jarak batas kiri halaman (misal: `4cm` untuk jilid). |
| | `margin_right` | String / Satuan | `2.5cm` | Jarak batas kanan halaman. |
| **Tipografi** | `font_family` | String | `Libertinus Serif` | Keluarga font dokumen (TNR standard Typst). |
| | `font_size` | String / pt | `12pt` | Ukuran font teks isi. |
| | `line_spacing` | String / em | `0.75em` | Jarak leading baris (0.75em = setara 1.5 line). |
| | `first_line_indent` | String / cm | `1.25cm` | Lebar indentasi baris pertama paragraf. |
| **Heading** | `heading_chapter_prefix` | String | `BAB ` | Awalan judul bab level 1 (bisa kosong untuk jurnal). |
| | `heading_chapter_num_format` | String | `roman` | Format angka bab (`roman` atau `arabic`). |
| | `heading_sub_dot` | Boolean | `true` | Apakah nomor sub-bab diakhiri titik (`1.1.` vs `1.1`). |
| | `heading_subsub_dot` | Boolean | `false` | Apakah nomor sub-sub-bab diakhiri titik (`1.1.1`). |
| **Sitasi** | `citation_style` | String | `apa` | Gaya sitasi bawaan (`apa` atau `ieee`). |
| | `csl` | String | `apa.csl` | Berkas format CSL (`apa.csl` atau `ieee.csl`). |
| **Cover** | `cover_show` | Boolean | `true` | Apakah cover jilid ditampilkan (set `false` untuk jurnal). |
| | `cover_show_lecturer` | Boolean | `true` | Tampilkan blok Dosen Pengampu di cover depan. |
| | `cover_logo_width` | String / cm | `4cm` | Lebar visual gambar logo di halaman cover. |

---

## Cara Membuat Preset Kampus Baru

1. Buat berkas baru di direktori `presets/`, misalnya `presets/its-skripsi.yml`.
2. Isi nilai sesuai buku pedoman kampus Anda.
3. Terapkan preset pada dokumen dengan menambahkan field `preset` di `metadata.yml`:
   ```yaml
   preset: "its-skripsi"
   ```
   Atau gunakan perintah CLI helper:
   ```bash
   ./laporan preset apply its-skripsi
   ```
4. Jalankan kompilasi:
   ```bash
   ./laporan build
   ```
