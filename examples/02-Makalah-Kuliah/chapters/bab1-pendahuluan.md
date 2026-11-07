# PENDAHULUAN

## Latar Belakang

Infrastruktur awan menuntut standar keamanan ketat. Risiko kebocoran data terus mengancam integritas sistem komputasi modern [@stallings2017cryptography]. Karena itulah, berbagai protokol enkripsi dan autentikasi wajib diterapkan guna mengamankan pertukaran paket data antara pengguna dan pusat data.

Meskipun protokol standar seperti TLS dan IPsec telah banyak diadopsi, perbedaan karakteristik latensi, beban pemrosesan (*cryptographic overhead*), dan skalabilitas menimbulkan tantangan teknis tersendiri dalam implementasi skala besar [@sommerville2011software]. Analisis terukur sangat dibutuhkan.

## Rumusan Masalah

Rumusan masalah dalam makalah ini adalah:
1. Bagaimana karakteristik performa protokol keamanan jaringan pada lingkungan komputasi awan?
2. Bagaimana perbandingan efisiensi pertukaran data dan beban komputasi enkripsi antar protokol?

## Tujuan

Tujuan penulisan makalah ini adalah:
1. Menganalisis kinerja enkripsi dan mekanisme transmisi aman pada arsitektur cloud.
2. Memberikan evaluasi komparatif performa jaringan berdasarkan latensi dan *throughput*.
