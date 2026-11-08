# Rilis ke npm

Paket [`laporan-generator`](https://www.npmjs.com/package/laporan-generator) sudah terdaftar di npm. Workflow `.github/workflows/release.yml` menerbitkan versi baru ketika tag rilis dibuat, setelah validasi Windows, macOS, dan Nix lulus.

## Konfigurasi satu kali di npm

1. Masuk ke akun npm yang memiliki paket `laporan-generator`.
2. Buka halaman paket → **Settings** → **Trusted Publisher**.
3. Pilih **GitHub Actions**, lalu isi:
   - Organization or user: `muadzhdz`
   - Repository: `laporan-generator`
   - Workflow filename: `release.yml`
   - Environment: kosongkan
4. Izinkan direct publishing (`npm publish`) untuk publisher ini.
5. Selesaikan publish pertama dalam 2 hari setelah membuat konfigurasi trusted publisher.

Trusted Publishing memakai OIDC GitHub Actions, sehingga workflow tidak membutuhkan `NPM_TOKEN`. npm juga menerbitkan provenance untuk paket publik dari repository publik. Lihat [dokumentasi resmi npm](https://docs.npmjs.com/trusted-publishers/) untuk kebijakan dan detail terkini.

## Alur rilis

1. Perbarui `package.json` dan seluruh banner/metadata versi ke versi yang sama.
2. Pindahkan catatan versi dari `[Unreleased]` ke heading versi rilis di `CHANGELOG.md`.
3. Pastikan perubahan sudah masuk ke `main` dan CI lintas platform lulus.
4. Buat dan dorong tag yang sama dengan versi paket, dengan awalan `v` (contoh `v4.0.0`). Workflow menolak tag jika versinya tidak sama dengan `package.json`.
5. Pantau job validasi dan job `release` di GitHub Actions. Setelah validasi lulus, job itu menerbitkan paket npm dan membuat GitHub Release.

Jangan buat tag rilis sebelum trusted publisher di npm dikonfigurasi dan workflow yang memuat publisher tersebut sudah ada di GitHub. Membuat tag akan memulai proses publikasi.

## Pemeriksaan sebelum rilis

```sh
npm pack --dry-run
npm view laporan-generator version
```

Periksa daftar berkas tarball sebelum rilis dan pastikan versi npm saat ini memang lebih rendah daripada versi yang akan diterbitkan.
