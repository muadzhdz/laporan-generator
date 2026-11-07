# HASIL DAN PEMBAHASAN

## Hasil Implementasi Visualisasi 3D

Model 3D lengan robot artikulasi enam derajat kebebasan (*6-DOF*) berhasil diintegrasikan ke dalam canvas WebGL. Pengguna dapat memutar, memperbesar, dan memicu animasi gerakan aktuator robot melalui antarmuka sentuh maupun kursor tetikus.

## Pengujian Performa Rendering

Evaluasi performa grafis dilakukan pada tiga variasi perangkat keras pengguna akhir untuk mengukur stabilitas *frames per second* (FPS):

: Hasil Pengujian Framerate Visualisasi Web 3D

| Konfigurasi Perangkat | Tipe GPU | Rata-rata FPS | Waktu Muat Awal (detik) |
|:---|:---|:---:|:---:|
| Desktop Workstation | NVIDIA RTX 4070 | 60.0 | 0.82 |
| Laptop Konsumen | Intel Iris Xe Graphics | 59.4 | 1.45 |
| Perangkat Mobile | Apple A15 Bionic | 60.0 | 1.10 |

Hasil pengujian menunjukkan bahwa model glTF yang telah dioptimasi dengan kompresi Draco mampu dimuat dalam waktu kurang dari 1.5 detik pada seluruh perangkat uji dengan kestabilan rendering mencapai target 60 FPS.
