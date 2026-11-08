# Sumber dan Cakupan Preset

Preset adalah konfigurasi awal. Tautan di bawah membantu menelusuri asal atau konteksnya, tetapi keberadaan pedoman sumber **tidak berarti seluruh nilai YAML sudah diverifikasi identik**. Cakupan fakultas/prodi, edisi, dan perubahan aturan harus dicek sebelum dipakai untuk dokumen final.

| Preset | Sumber yang dapat ditelusuri | Cakupan sumber | Status pemetaan nilai preset |
|---|---|---|---|
| `standard` | Tidak memakai pedoman kampus tertentu | Format generik proyek | Default proyek; bukan standar institusi |
| `skripsi-4433` | Tidak memakai pedoman kampus tertentu | Konvensi margin jilid yang umum dipakai | Preset generik; jangan dianggap aturan nasional |
| `ui-skripsi` | [Pedoman Teknis Penulisan Tugas Akhir UI, revisi 2025](https://pascakomunikasi.fisip.ui.ac.id/pedoman-teknis-penulisan-tugas-akhir-mahasiswa/) | Pedoman UI; prodi/fakultas dapat menambahkan aturan | Perlu cocokkan seluruh nilai dengan edisi 2025 dan pedoman prodi |
| `itb-ta` | [Persyaratan TA Prodi Teknik Metalurgi ITB](https://multisite.itb.ac.id/metallurgy/wp-content/uploads/sites/123/2016/06/Persyaratan-dan-Ketentuan-Tugas-Akhir-Seminar-dan-Sidang-MG.pdf) | Teknik Metalurgi; dokumen 2016 ini bukan pedoman umum ITB | Belum diverifikasi; sumber mungkin tidak memuat seluruh tata letak |
| `ugm-skripsi` | [Pedoman DTSL FT UGM](https://tsipil.ugm.ac.id/wp-content/uploads/sites/4/2023/02/Pedoman-Penulisan-DTSL_2023_v1-Final.pdf) | Departemen Teknik Sipil dan Lingkungan, edisi 2023 | Belum diverifikasi untuk semua fakultas/prodi UGM |
| `its-skripsi` | [Pedoman TA Sarjana dan Sarjana Terapan ITS](https://www.its.ac.id/pendidikan/2022/03/24/pedoman-penyusunan-laporan-tugas-proyek-akhir-program-sarjana-dan-sarjana-terapan/) | Pedoman tingkat ITS berdasarkan SK Rektor 280/IT2/T/HK.00.01/2022 | Perlu cocokkan margin dan aturan rinci dengan dokumen/template yang berlaku |
| `unpad-skripsi` | [Pedoman Skripsi Prodi Ilmu Komunikasi Unpad](https://ilkom.psdku.unpad.ac.id/wp-content/uploads/2026/04/Buku-Pedoman-Skripsi-Prodi-Ilkom_18122020.pdf) | Prodi Ilmu Komunikasi, edisi 2020 | Belum diverifikasi untuk edisi terbaru atau prodi lain |
| `ub-skripsi` | [Pedoman Tugas Akhir FIA UB 2024](https://fia.ub.ac.id/en/pendidikan/pedoman-skripsi/) | Fakultas Ilmu Administrasi UB | Belum diverifikasi untuk fakultas/prodi lain |
| `undip-skripsi` | [Pedoman Penulisan Skripsi FPIK UNDIP 2026](https://kelautan.undip.ac.id/direktori-v2/) | FPIK UNDIP | Belum diverifikasi untuk unit akademik lain |
| `unair-skripsi` | [Panduan Skripsi FST UNAIR, revisi 2022](https://fst.unair.ac.id/wp-content/uploads/2024/05/Panduan-Skripsi-FST-UNAIR_2022-REVISI.pdf) | Fakultas Sains dan Teknologi UNAIR | Belum diverifikasi untuk fakultas/prodi lain |
| `ipb-ppki` | [PPKI edisi 4](https://simak.ipb.ac.id/Foto/Panduan/Dokumen_38.pdf) dan [informasi PPTA IPB terbaru](https://panduan.ipb.ac.id/panduan-ppta/) | PPKI edisi 4 berlaku dalam masa transisi; PPTA baru berlaku untuk kelompok mahasiswa yang dijelaskan IPB mulai semester ganjil 2026/2027 | Preset ini mewakili PPKI edisi 4; bukan pemetaan PPTA baru |
| `telkom-ta` | [Panduan TA Kelompok Keahlian Informatika Telkom University Purwokerto, April 2026](https://bif-pwt.telkomuniversity.ac.id/wp-content/uploads/2026/04/KK-Sosialisasi-Panduan-TA-Update-April-2026.pdf) | Informatika Tel-U Purwokerto | Belum diverifikasi untuk seluruh Telkom University atau program lain |
| `jurnal-uajy` | [Author Guidelines Jurnal Buana Informatika](https://ojs.uajy.ac.id/index.php/jbi/Author-Guidelines) | JBI; mewajibkan template jurnal terbaru dan gaya IEEE | Margin/font preset belum dipastikan sama dengan template jurnal terkini |
| `jurnal-standar` | Tidak memakai jurnal tertentu | Kerangka artikel generik | Bukan format SINTA atau jurnal tertentu; ikuti template jurnal tujuan |

## Cara Mengusulkan Status Terverifikasi

Untuk menaikkan status preset dari awal menjadi terverifikasi, kontribusi perlu menyertakan sumber resmi yang masih berlaku, cakupan unit akademik, tanggal pemeriksaan, serta pemetaan setiap nilai format (margin, font, spasi, heading, halaman, dan sampul) terhadap halaman atau bagian sumber. Tambahkan fixture atau pengujian yang memeriksa nilai tersebut agar perubahan preset tidak menggeser aturan tanpa sengaja.
