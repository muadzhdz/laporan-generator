# METODE PENELITIAN

## Tahapan Multimedia Development Life Cycle (MDLC)

Pengembangan sistem dilaksanakan melalui enam fase sekuensial MDLC [@luther1994authoring]:
1. *Concept*: Menentukan tujuan sistem, sasaran pengguna (siswa, instruktur, admin), dan spesifikasi kebutuhan interaksi 3D.
2. *Design*: Merancang arsitektur sistem, storyboard antarmuka, dan struktur kendali model 3D.
3. *Material Collecting*: Menyiapkan model 3D berformat glTF/GLB, tekstur visual, dan materi pembelajaran kurikulum robotika.
4. *Assembly*: Mengintegrasikan komponen frontend (React/Next.js) dengan library rendering Three.js dan backend API.
5. *Testing*: Melakukan verifikasi fungsional *black-box* dan pengujian beban grafis (framerate).
6. *Distribution*: Melakukan penyebaran (*deployment*) pada infrastruktur cloud.

## Arsitektur Sistem

Arsitektur sistem dibangun di atas tumpukan teknologi modern: antarmuka web interaktif dirender pada peramban klien, sementara autentikasi pengguna dan pencatatan progres modul ditangani oleh service terpusat.
