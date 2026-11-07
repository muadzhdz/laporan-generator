# PEMBAHASAN DAN ANALISIS

## Karakteristik Protokol Keamanan Cloud

Protokol Transport Layer Security (TLS 1.3) menyederhanakan proses jabat tangan (*handshake*) dari dua fase pertukaran (*round-trip times*) menjadi satu fase tunggal. Efeknya instan. Latensi inisiasi koneksi terpangkas hingga separuh durasi pada beban kerja terdistribusi [@tanenbaum2011computer].

Di sisi lain, arsitektur IPsec pada lapisan jaringan menyediakan enkripsi paket secara transparan terhadap lapisan aplikasi, namun membutuhkan parameter *overhead* header paket yang lebih besar. Hal ini menambah beban transmisi pada jaringan berkecepatan tinggi.

## Perbandingan Metrik Kinerja

Tabel berikut merangkum data komparasi teknis:

: Karakteristik Komparatif Protokol Keamanan Jaringan Cloud

| Parameter | TLS 1.3 | IPsec (ESP-Tunnel) | WireGuard |
|:---|:---:|:---:|:---:|
| Lapisan OSI | Aplikasi / Transport | Jaringan (Layer 3) | Jaringan (Layer 3) |
| Latensi Jabat Tangan | 1-RTT / 0-RTT | 2-RTT (IKEv2) | 1-RTT Noise Protocol |
| Overhead Header | 20-40 Byte | 50-70 Byte | 32 Byte |
| Kompleksitas Kode | Tinggi (OpenSSL) | Tinggi | Minimalis (~4000 baris) |

Berdasarkan tabel di atas, protokol dengan basis kode ringkas memberikan efisiensi verifikasi keamanan yang lebih mudah diaudit [@pressman2014software].
