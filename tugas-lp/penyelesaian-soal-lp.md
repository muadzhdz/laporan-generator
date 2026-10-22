# Penyelesaian Soal Latihan LP — Cloud Computing & Agensi Desain/Web

## Soal 1 — Alokasi Jam Server Cloud Computing

### 1. Variabel keputusan

- \(X_1\) = jumlah paket **Compute-Optimized**
- \(X_2\) = jumlah paket **Memory-Optimized**

### 2. Fungsi tujuan

Laba per jam:

- Compute-Optimized = Rp12.000/jam
- Memory-Optimized = Rp18.000/jam

Maksimalkan:

\[
\boxed{Z = 12.000X_1 + 18.000X_2}
\]

### 3. Kendala

Kapasitas vCPU tersedia 80:

\[
4X_1 + 2X_2 \le 80
\]

Kapasitas RAM tersedia 120 GB:

\[
2X_1 + 6X_2 \le 120
\]

Ketentuan SLA minimal 5 unit Compute-Optimized:

\[
X_1 \ge 5
\]

Dan:

\[
X_1 \ge 0,\qquad X_2 \ge 0
\]

Model LP lengkap:

\[
\boxed{
\begin{aligned}
\text{Maksimalkan } & Z = 12.000X_1 + 18.000X_2 \\
\text{dengan kendala } &
4X_1 + 2X_2 \le 80 \\
&
2X_1 + 6X_2 \le 120 \\
&
X_1 \ge 5 \\
&
X_2 \ge 0
\end{aligned}}
\]

### 4. Persamaan garis untuk grafik

Kendala vCPU:

\[
4X_1+2X_2=80
\]

\[
X_2=40-2X_1
\]

Titik potong sumbu: \((20,0)\) dan \((0,40)\).

Kendala RAM:

\[
2X_1+6X_2=120
\]

\[
X_2=20-\frac{1}{3}X_1
\]

Titik potong sumbu: \((60,0)\) dan \((0,20)\).

Karena ada syarat \(X_1\ge5\), daerah layak berada di sebelah kanan garis vertikal \(X_1=5\), serta berada di bawah kedua garis sumber daya.

### 5. Titik sudut daerah layak

1. \(A=(5,0)\)
2. \(B=(20,0)\)
3. \(C=(12,16)\) — perpotongan kendala vCPU dan RAM
4. \(D=(5,55/3)\approx(5,18,33)\) — perpotongan \(X_1=5\) dengan kendala RAM

Perpotongan \(C\) diperoleh dari:

\[
4X_1+2X_2=80
\]

\[
2X_1+6X_2=120
\]

Membagi persamaan pertama dengan 2 dan kedua dengan 2:

\[
2X_1+X_2=40
\]

\[
X_1+3X_2=60
\]

Diperoleh:

\[
\boxed{X_1=12,\quad X_2=16}
\]

### 6. Uji fungsi tujuan pada titik sudut

| Titik | \(X_1\) | \(X_2\) | \(Z=12.000X_1+18.000X_2\) |
|---|---:|---:|---:|
| A | 5 | 0 | Rp60.000 |
| B | 20 | 0 | Rp240.000 |
| C | 12 | 16 | **Rp432.000** |
| D | 5 | 18,33 | Rp390.000 |

Jadi alokasi optimal adalah:

\[
\boxed{X_1=12\text{ paket Compute-Optimized}}
\]

\[
\boxed{X_2=16\text{ paket Memory-Optimized}}
\]

Laba maksimum:

\[
\boxed{Z_{maks}=Rp432.000/jam}
\]

Pemakaian sumber daya pada solusi optimal:

- vCPU = \(4(12)+2(16)=80\) vCPU → **habis terpakai**
- RAM = \(2(12)+6(16)=120\) GB → **habis terpakai**

Artinya, kedua kapasitas menjadi aktif tepat pada solusi optimal.

---

## Soal 2 — Alokasi Proyek Agensi Desain & Web

### 1. Variabel keputusan

- \(X_1\) = jumlah proyek **Desain UI/UX**
- \(X_2\) = jumlah proyek **Pengembangan Front-End**

### 2. Fungsi tujuan

Laba:

- UI/UX = Rp6.000.000/proyek
- Front-End = Rp8.000.000/proyek

Maksimalkan:

\[
\boxed{Z=6.000.000X_1+8.000.000X_2}
\]

### 3. Kendala

Waktu riset tersedia 36 jam:

\[
6X_1+3X_2\le36
\]

Waktu prototype tersedia 48 jam:

\[
4X_1+8X_2\le48
\]

Serta:

\[
X_1\ge0,\qquad X_2\ge0
\]

Sederhanakan kendala:

\[
2X_1+X_2\le12
\]

\[
X_1+2X_2\le12
\]

Model LP:

\[
\boxed{
\begin{aligned}
\text{Maksimalkan } & Z=6.000.000X_1+8.000.000X_2 \\
\text{dengan kendala } &
6X_1+3X_2\le36 \\
&
4X_1+8X_2\le48 \\
&
X_1\ge0,\quad X_2\ge0
\end{aligned}}
\]

### 4. Garis untuk metode grafik

Kendala riset:

\[
2X_1+X_2=12
\]

Sehingga:

\[
X_2=12-2X_1
\]

Titik potong sumbu: \((6,0)\) dan \((0,12)\).

Kendala prototype:

\[
X_1+2X_2=12
\]

Sehingga:

\[
X_2=6-\frac{1}{2}X_1
\]

Titik potong sumbu: \((12,0)\) dan \((0,6)\).

### 5. Titik sudut daerah layak

Titik sudutnya:

- \(A=(0,0)\)
- \(B=(6,0)\)
- \(C=(4,4)\)
- \(D=(0,6)\)

Perpotongan dua kendala:

\[
2X_1+X_2=12
\]

\[
X_1+2X_2=12
\]

Dari persamaan pertama:

\[
X_2=12-2X_1
\]

Substitusikan:

\[
X_1+2(12-2X_1)=12
\]

\[
X_1+24-4X_1=12
\]

\[
-3X_1=-12
\]

\[
X_1=4
\]

Kemudian:

\[
X_2=12-2(4)=4
\]

Jadi:

\[
\boxed{X_1=4,\quad X_2=4}
\]

### 6. Uji fungsi tujuan pada titik sudut

| Titik | \(X_1\) | \(X_2\) | \(Z=6.000.000X_1+8.000.000X_2\) |
|---|---:|---:|---:|
| A | 0 | 0 | Rp0 |
| B | 6 | 0 | Rp36.000.000 |
| C | 4 | 4 | **Rp56.000.000** |
| D | 0 | 6 | Rp48.000.000 |

Jadi jumlah proyek optimal:

\[
\boxed{4\text{ proyek UI/UX dan }4\text{ proyek Front-End}}
\]

Laba maksimum:

\[
\boxed{Z_{maks}=Rp56.000.000}
\]

Pemakaian waktu pada solusi optimal:

- Riset = \(6(4)+3(4)=36\) jam → **habis terpakai**
- Prototype = \(4(4)+8(4)=48\) jam → **habis terpakai**

Jadi kedua sumber daya juga tepat digunakan seluruhnya.

---

## Kesimpulan

### Soal 1

\[
\boxed{X_1=12,\;X_2=16,\;Z_{maks}=Rp432.000/jam}
\]

### Soal 2

\[
\boxed{X_1=4,\;X_2=4,\;Z_{maks}=Rp56.000.000}
\]

File `plot_daerah_layak.py` di folder yang sama dapat digunakan untuk menggambar daerah layak dan titik sudut kedua soal secara otomatis.
