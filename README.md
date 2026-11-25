# 🛒 TOKONA POS — Manual Book & Panduan Pengguna Lengkap

> **Smart POS Retail Store App** — Aplikasi Kasir & Manajemen Toko Retail Modern berbasis *Offline-First* dengan Sinkronisasi Cloud Otomatis, Multi-Device Pairing QR, Keamanan Biometrik, dan Cetak Struk Bluetooth Thermal.

---

## 📑 Daftar Isi
1. [Tentang Tokona POS](#-1-tentang-tokona-pos)
2. [Langkah Awal: Pendaftaran & Profil Toko](#-2-langkah-awal-pendaftaran--profil-toko)
3. [Manajemen Karyawan & Pairing Multi-Device](#-3-manajemen-karyawan--pairing-multi-device)
4. [Sistem Keamanan Toko & Auto-Lock](#-4-sistem-keamanan-toko--auto-lock)
5. [Operasional Kasir & Transaksi Penjualan](#-5-operasional-kasir--transaksi-penjualan)
6. [Cetak Struk Thermal Bluetooth (58mm & 80mm)](#-6-cetak-struk-thermal-bluetooth-58mm--80mm)
7. [Manajemen Kasbon, Pelanggan & WhatsApp Notifikasi](#-7-manajemen-kasbon-pelanggan--whatsapp-notifikasi)
8. [Manajemen Produk, Stok & Pembelian (PO)](#-8-manajemen-produk-stok--pembelian-po)
9. [Sinkronisasi Cloud & Audit Trail Otomatis](#-9-sinkronisasi-cloud--audit-trail-otomatis)
10. [Panduan Teknis & Build Developer](#-10-panduan-teknis--build-developer)

---

## 🚀 1. Tentang Tokona POS

Tokona POS dirancang khusus untuk toko kelontong, retail, dan grosir yang membutuhkan keandalan tinggi tanpa khawatir kendala koneksi internet.

### Fitur Unggulan:
* **Offline-First:** Semua transaksi kasir, input produk, dan pencatatan kasbon disimpan langsung di database lokal SQLite pada ponsel Anda. Aplikasi tetap berjalan 100% lancar walau tanpa koneksi internet.
* **Multi-Device Pairing (Offline QR):** HP Owner dapat menerbitkan kredensial untuk HP Kasir atau HP Admin cukup dengan memindai kode QR secara langsung tanpa butuh koneksi server.
* **Auto-Sync Polling ke HP Owner:** Setiap 30 detik saat terhubung ke jaringan, data penjualan dan aktivitas kasir disinkronkan ke Cloud sehingga Owner dapat memantau omzet toko secara real-time dari mana saja.
* **Audit Trail Komprehensif:** Setiap tindakan penting (tambah produk, ubah harga, opname stok, terima barang belanja, pendaftaran kasir, perubahan PIN) dicatat secara otomatis lengkap dengan waktu, nama staf, dan perannya.
* **Cetak Struk Thermal Bluetooth:** Mendukung printer thermal 58mm dan 80mm dengan protokol ESC/POS standar.
* **Sistem Keamanan Ganda:** Proteksi PIN 6-digit dan autentikasi biometrik (Fingerprint / Sidik Jari) dengan fitur *Auto-Lock* saat aplikasi diminimize.

---

## 🏬 2. Langkah Awal: Pendaftaran & Profil Toko

### A. Registrasi Akun Owner (1-Step Fast Register)
1. Buka aplikasi Tokona POS.
2. Pada layar utama, pilih tab **Daftar Akun Baru**.
3. Masukkan:
   - **Nama Toko / Outlet**
   - **Nama Pemilik (Owner)**
   - **Nomor WhatsApp Toko** (Format otomatis normalisasi ke `08xx` atau `+628xx`)
   - **Kata Sandi Akun**
4. Tekan tombol **Daftar Sekarang**. Akun Anda otomatis menjadi peran **Owner (Pemilik Toko)**.

### B. Melengkapi Alamat Toko (Banner ala Shopee)
Jika alamat toko belum diisi, aplikasi akan menampilkan banner pengingat berwarna oranye di tab Produk:
> *"Lengkapi Profil Toko Anda: Tambahkan alamat lengkap dan nomor kontak toko agar nota kasir resmi dapat dicetak."*

1. Klik tombol **Lengkapi Sekarang** pada banner tersebut, atau buka tab **Profil** lalu klik kartu toko.
2. Anda dapat mengisi alamat toko secara manual atau otomatis:
   - **Ambil Kontak HP:** Membuka buku telepon HP Anda untuk mengisi No. HP dan Nama.
   - **Ambil Alamat di HP:** Mengambil alamat pos yang tersimpan pada kontak perangkat secara instan.
3. Tekan **Simpan Perubahan**.
> ⚠️ **Catatan Penting:** Input produk baru akan terkunci sampai alamat toko berhasil dilengkapi untuk menjaga keabsahan struk dan identitas toko.

---

## 👥 3. Manajemen Karyawan & Pairing Multi-Device

Sebagai Owner, Anda dapat mendaftarkan karyawan agar kasir dan admin dapat mengoperasikan aplikasi dari smartphone mereka masing-masing.

### A. Mendaftarkan Staf Baru
1. Masuk ke tab **Profil**.
2. Pada kartu modern **Karyawan & Pairing Kasir**, tekan tombol **+ Tambah Staf**.
3. Isi data staf:
   - **Nama Lengkap Karyawan**
   - **Username Login**
   - **Kata Sandi Awal**
   - **Peran / Jabatan:** Pilih `Kasir` (hanya transaksi & nota) atau `Admin` (operasional & stok).
4. Tekan **Simpan & Terbitkan Akun**.

### B. Pairing HP Kasir via Scan QR (Offline)
1. Di HP Owner: Buka kartu **Karyawan & Pairing Kasir** > pilih nama kasir > tekan icon **QR Code**.
2. Di HP Kasir:
   - Buka aplikasi Tokona POS pada halaman Login.
   - Tekan opsi **Pairing via QR (Offline)**.
   - Arahkan kamera HP Kasir ke QR Code yang tampil di layar HP Owner.
3. Dalam hitungan detik, seluruh identitas toko dan akun kasir otomatis terkonfigurasi di HP Kasir tanpa perlu input manual.

### C. Pengaturan Hak Akses Menu Dinamis (RBAC)
Owner dapat membatasi menu mana saja yang boleh dibuka oleh Kasir maupun Admin:
1. Tekan tombol **Atur Hak Akses Menu Kasir & Admin (RBAC)** di menu Profil.
2. Pilih peran yang ingin dikonfigurasi (`Kasir` atau `Admin`).
3. Aktifkan atau nonaktifkan izin menu secara granular:
   - Mengubah harga produk saat transaksi
   - Memberikan diskon kasir
   - Menghapus transaksi yang sudah tersimpan
   - Mengakses laporan laba rugi dan modal
4. Perubahan hak akses langsung berlaku seketika.

---

## 🔒 4. Sistem Keamanan Toko & Auto-Lock

Untuk mencegah akses yang tidak berwenang saat HP kasir ditinggalkan di meja kasir:

### A. Mengaktifkan PIN & Sidik Jari (Fingerprint)
1. Buka tab **Profil** > pilih **Kunci Aplikasi & PIN Keamanan**.
2. Masukkan 6-digit angka PIN rahasia Anda dan konfirmasi ulang.
3. Aktifkan sakelar **Gunakan Sidik Jari (Biometrik)**.

### B. Fitur Auto-Lock Otomatis
* Setiap kali aplikasi Tokona POS diminimize, layar ponsel mati, atau berpindah ke aplikasi lain, aplikasi akan langsung **mengunci secara otomatis**.
* Saat aplikasi dibuka kembali, muncul layar kunci modern dengan indikator PIN dan tombol Sidik Jari.
* Sentuh sensor sidik jari ponsel Anda atau tekan tombol **Fingerprint** di layar untuk membuka kunci dalam 1 detik. Anda juga dapat mengetikkan 6-digit PIN sebagai alternatif.

---

## 💵 5. Operasional Kasir & Transaksi Penjualan

### A. Memulai Transaksi
1. Buka tab **Kasir**.
2. Cari barang menggunakan salah satu cara berikut:
   - Ketik nama barang pada kolom pencarian cepat.
   - Tekan icon **Barcode Scanner** untuk memindai barcode produk via kamera HP.
   - Pilih barang dari daftar kategori populer.
3. Klik produk untuk memasukkan ke keranjang belanja. Tekan produk di keranjang untuk menyesuaikan jumlah atau memilih satuan kemasan (Pcs, Lusin, Dus).

### B. Metode Pembayaran
Tekan tombol **Bayar** di bagian bawah, lalu pilih metode:
* **Tunai (Cash):** Masukkan uang yang diterima atau pilih pecahan uang cepat (Rp 50.000, Rp 100.000). Aplikasi otomatis menghitung uang kembalian.
* **Transfer Bank / QRIS:** Catat nomor referensi pembayaran non-tunai.
* **Kasbon / Tempo (Piutang):** Pilih pelanggan yang berhutang dan tentukan tanggal jatuh tempo pembayaran.

### C. Tutup Kasir & Rekap Shift Harian
Di akhir jam operasional toko, kasir dapat melakukan tutup kasir:
1. Buka tab Kasir > tekan menu **Tutup Kasir / Setor Saldo**.
2. Masukkan total uang fisik di laci kasir untuk diverifikasi dengan total penjualan sistem.
3. Simpan dan cetak laporan tutup shift kasir.

---

## 🖨️ 6. Cetak Struk Thermal Bluetooth (58mm & 80mm)

Tokona POS mendukung pencetakan nota fisik menggunakan printer thermal mini portabel (Bluetooth ESC/POS).

### A. Menghubungkan Printer Bluetooth
1. Nyalakan printer thermal Anda dan aktifkan Bluetooth di ponsel.
2. Di Tokona POS, buka tab **Profil** > pilih **Pengaturan Printer Thermal**.
3. Aktifkan opsi **Gunakan Printer Thermal**.
4. Pilih lebar kertas yang sesuai:
   - **58 mm** (Lebar standar printer kasir mini / 32 karakter per baris).
   - **80 mm** (Printer kasir besar / 48 karakter per baris).
5. Masukkan nama Bluetooth printer (misalnya: `RPP02N`, `MP-58`, atau `Thermal Printer`).
6. Atur header nota (Nama toko & alamat) dan pesan footer (misalnya: *"Terima kasih atas kunjungan Anda"*).

### B. Mencetak Struk Transaksi
* Setelah transaksi berhasil disimpan, dialog struk akan otomatis muncul.
* Tekan tombol **Cetak Struk Thermal (ESC/POS)** untuk langsung mencetak nota fisik ke printer.
* Anda juga dapat membagikan nota digital ke pelanggan lewat WhatsApp dengan menekan **Kirim Struk via WA**.

---

## 📋 7. Manajemen Kasbon, Pelanggan & WhatsApp Notifikasi

### A. Monitoring Jatuh Tempo Kasbon
1. Buka menu **Jatuh Tempo Kasbon** dari Beranda atau tab Pelanggan.
2. Sistem menyajikan kartu ringkasan KPI:
   - Total Piutang Belum Lunas
   - Jumlah Transaksi Kasbon yang Lewat Jatuh Tempo
   - Kasbon yang Jatuh Tempo Hari Ini
3. Pelanggan yang telah melewati batas tempo akan ditandai dengan lencana merah darurat.

### B. Kirim Tagihan Otomatis ke WhatsApp
1. Tekan icon **WhatsApp** di samping nama pelanggan pada daftar piutang.
2. Aplikasi akan otomatis menyusun pesan penagihan yang santun dan profesional berisi:
   - Nama Toko & Nama Pelanggan
   - Rincian nota dan tanggal transaksi
   - Sisa saldo yang wajib dibayarkan
   - Nomor rekening transfer toko
3. Aplikasi langsung membuka aplikasi WhatsApp menuju kontak pelanggan yang bersangkutan.

---

## 📦 8. Manajemen Produk, Stok & Pembelian (PO)

### A. Menambahkan Produk Baru
1. Buka tab **Produk** > tekan tombol **+ Tambah Produk** di kanan bawah.
2. Isi informasi produk:
   - Nama Produk & Kategori
   - Kode Barcode (dapat diketik atau discan langsung)
   - Harga Beli Pokok (HPP)
   - Harga Jual Eceran
   - Stok Awal & Batas Peringatan Stok Minimum
   - Satuan Kemasan Bertingkat ( 1 Dus = 24 Pcs dengan harga grosir khusus)
3. Tekan **Simpan Produk**.

### B. Kulakan & Pemesanan Barang (Purchase Order)
1. Buka tab Beranda > pilih menu **Pengadaan & Kulakan (PO)**.
2. Catat pembelian barang dari supplier/distributor lengkap dengan nomor faktur, estimasi kedatangan, dan uang muka (DP).
3. Saat barang tiba di toko, klik **Terima Barang** untuk otomatis menambahkan kuantitas barang ke stok gudang.

### C. Pelacakan Ekspedisi J&T Cargo
Untuk pembelian barang dalam jumlah besar yang dikirim melalui ekspedisi logistik:
* Masukkan nomor resi pada detail pesanan.
* Sistem Tokona terintegrasi dengan pelacakan status pengiriman cargo untuk memantau perjalanan logistik barang kulakan Anda.

### D. Skema Cicilan Shopee PayLater (BNPL) & Alokasi Celengan Harian
Bagi toko yang kulakan belanja modal barang dagangan lewat Shopee PayLater / SPayLater:
1. **Tenor Cicilan Fleksibel (1x, 3x, 6x, 12x):**
   * Saat mencatat pembelian baru atau mengedit faktur belanja yang sudah ada, pemilik toko dapat memilih skema cicilan: **1 Bulan (Tempo)**, **3 Bulan**, **6 Bulan**, atau **12 Bulan**.
   * Masukkan nominal cicilan per bulan persis sesuai yang tertera di aplikasi Shopee (otomatis diberi estimasi bunga rata-rata SPayLater ~2.95%/bulan).
2. **Pengecekan Margin vs Bunga (Safety Indicator):**
   * Tokona otomatis menghitung total bunga cicilan dari tenor yang dipilih.
   * Apabila persentase bunga di atas 10%, sistem memberikan peringatan (*Safety Margin Warning*) agar pemilik toko memastikan harga jual eceran di toko dinaikkan secukupnya agar margin laba tidak tergerus bunga cicilan.
3. **Siklus Tanggal Jatuh Tempo Akun Shopee (Tgl 1, 5, 11, 25):**
   * Akun Shopee setiap pemilik toko memiliki tanggal siklus penagihan jatuh tempo yang berbeda-beda.
   * Di layar **Monitor Tagihan PayLater**, pemilik toko dapat memilih tanggal siklus jatuh tempo akun Shopee miliknya (Tanggal 1, 5, 11, atau 25), sehingga perhitungan tagihan jatuh tempo bulan berjalan selalu presisi.
4. **Celengan Harian PayLater (Alokasi Tutup Kasir & Beranda):**
   * Muncul kartu **Celengan Harian PayLater** saat kasir melakukan **Tutup Kasir Harian** maupun di Beranda Owner.
   * Memberikan rekomendasi nominal uang kas harian yang sebaiknya disisihkan ke celengan/amplop bayar PayLater agar saat tanggal jatuh tempo tiba, uang pelunasan sudah terkumpul tanpa mengganggu modal operasional harian.
5. **Pembayaran Fleksibel / Bayar Lebih Awal:**
   * Tombol pelunasan dan cicil PayLater tidak dikunci hanya di akhir bulan, sehingga pemilik toko dapat mencicil atau melunasi tagihan Shopee PayLater lebih awal kapan saja saat kas toko sedang longgar.
6. **Form Rapi & Tombol Sejajar:**
   * Pada dialog **Ubah Item Belanja** dan form **Edit & Tambah Barang Faktur**, tombol aksi *Batal* dan *Simpan* ditata sejajar berdampingan (50:50) dalam satu baris dengan field input terstandarisasi.

### E. Modal Toko & Penarikan Kas (Prive)
Menu **Profil > Kas Toko & Pembayaran > Modal Toko & Prive** menyediakan pencatatan arus modal pemilik toko yang akurat:
1. **Catat Modal Awal & Tambahan Modal:**
   * Mencatat suntikan dana segar ke akun kas/bank toko lengkap dengan tanggal, sumber dana, dan catatan transaksi.
2. **Tarik Kas Toko (Prive):**
   * Pemilik toko dapat menarik laba atau modal toko (prive).
   * **Proteksi Saldo Defisit (*Overdrawn Protection*):** Sistem memvalidasi saldo akun kas yang dipilih secara real-time. Jika nominal yang ingin ditarik melebihi saldo kas riil, sistem otomatis mencegah penarikan agar akun tidak minus fiktif.
   * **Proyeksi Sisa Saldo Langsung:** Ditampilkan simulasi sisa saldo kas dan sisa modal bersih toko setelah penarikan dilakukan.
3. **Riwayat & Pembatalan:**
   * Seluruh riwayat penarikan kas dapat dibatalkan (dihapus). Jika dihapus, nominal penarikan otomatis dikembalikan ke saldo rekening yang bersangkutan.

### F. Master Rekening Pembayaran & Reset Saldo
Menu **Profil > Kas Toko & Pembayaran > Metode Pembayaran & Bank**:
1. **Dukungan Multi-Akun:**
   * Mengelola akun Kasir (Kas Tunai Laci), Rekening Bank (BCA, BRI, Mandiri, BNI, SeaBank), E-Wallet (DANA, GoPay, ShopeePay), dan QRIS Toko.
2. **Fitur Reset Saldo Saat Ini:**
   * Pemilik toko dapat mengedit rekening dan menggunakan field **Reset Saldo Saat Ini (Rp)** untuk me-reset saldo akun yang minus atau salah rekap transaksi lama secara langsung tanpa perlu menghapus riwayat faktur.

### G. Pembelian Co-Order & Pengalihan Sumber Dana
1. **Pilihan Sumber Dana Belanja:**
   * Saat kulakan barang, Anda dapat memilih apakah pembayaran menggunakan akun kas toko atau **Dana Rekan / Non-Kas Toko** (dana talangan pribadi).
   * Jika memilih *Non-Kas Toko*, kas operasional toko tidak akan terpotong.
2. **Faktur Khusus Biaya Pengiriman (Ongkir Saja):**
   * Jika barang belanjaan ditalangi pihak luar dan kas toko hanya menanggung ongkos kirim, pemilik toko cukup mengedit faktur barang dan mengosongkan item produk dengan tetap mengisi nilai pada field **Ongkos Kirim**. Sistem akan otomatis mengembalikan selisih harga barang ke kas toko.

### H. Master Pembulatan Harga Kasir (POS Rounding)
Menu **Profil > Kas Toko & Pembayaran > Master Pembulatan Harga**:
* **Mode Pembulatan:** *Bulatkan ke Atas (Round Up)*, *Bulatkan ke Bawah (Round Down)*, atau *Terdekat (Nearest)*.
* **Kelipatan:** Mendukung kelipatan Rp 50, Rp 100, Rp 500, dan Rp 1.000.
* Dilengkapi simulator pembulatan interaktif agar staf kasir dapat melihat simulasi total kembalian uang pelanggan sebelum disimpan.

### I. Standar Tampilan Bersih (Zero-Emoji Clean UI)
* Seluruh antarmuka aplikasi, pesan notifikasi, rekap penutupan toko, dan bukti nota cetak thermal telah distandarisasi bebas dari teks emoji non-formal demi kerapian dan konsistensi visual di seluruh jenis perangkat Android.

---

## ☁️ 9. Sinkronisasi Cloud & Audit Trail Otomatis

### A. Sinkronisasi Otomatis Dinamis (Cloud Polling Bebas Diatur)
* Di ponsel Owner & Kasir, jeda waktu sinkronisasi otomatis kini dapat **disetel bebas** sesuai kebutuhan:
  - **15 Detik:** Real-time super cepat saat jam sibuk toko.
  - **30 Detik (Standar Rekomendasi):** Keseimbangan ideal antara kecepatan dan penggunaan data.
  - **1 Menit / 5 Menit / 15 Menit / 30 Menit:** Untuk toko dengan volume transaksi santai.
  - **1 Jam:** Mode hemat baterai dan kuota internet maksimal.
* Pengaturan dapat diubah kapan saja melalui dialog **Sinkronisasi Cloud** (klik status sync di header) atau melalui menu **Profil > Pengaturan & Preferensi > Sinkronisasi Cloud & Interval**.
* Layar **Beranda** Owner secara otomatis menyesuaikan jeda waktu polling untuk menarik transaksi kasir dan audit log sesuai interval yang dipilih tanpa perlu refresh manual.

### B. Audit Trail (Log Aktivitas Seluruh Role)
Setiap tindakan operasional dicatat secara sistematis untuk mencegah kecurangan (*fraud*):
* **Owner:** Menambah staf baru, mencabut hak akses kasir, mengganti pengaturan keamanan.
* **Admin:** Melakukan penyesuaian stok opname, mengubah harga produk, menerima barang kulakan.
* **Kasir:** Melakukan transaksi penjualan, menghapus item pesanan, memproses pembayaran kasbon.

Log dapat dipantau langsung di tab **Profil** > **Audit Log Aktivitas**. Setiap entri mencantumkan:
- Tanggal dan jam presisi (WIB)
- Nama staf dan peran (*Owner / Admin / Kasir*)
- Deskripsi detail aktivitas yang dilakukan

---

## 🛠️ 10. Panduan Teknis & Build Developer

### Prasyarat:
* **Flutter SDK:** 3.47.8 (Direkomendasikan menggunakan FVM)
* **Dart SDK:** ^3.13.7
* **Android:** Min SDK 21, Target SDK 34 (Java 17)

### Perintah Penting:

```bash
# 1. Masuk ke direktori proyek
cd /home/who/Development/Flutter/tokona

# 2. Ambil seluruh dependencies
flutter pub get

# 3. Jalankan unit test & widget test
flutter test test/profile_widget_test.dart

# 4. Verifikasi kompilasi bundle
flutter build bundle

# 5. Jalankan aplikasi pada perangkat Android yang terhubung
flutter run -d <DEVICE_ID>

# 6. Build APK Release
flutter build apk --release
```

### Standar Arsitektur Kode:
* Seluruh file Dart di bawah direktori `lib/` **WAJIB memenuhi aturan $\le 300$ baris**.
* State management menggunakan **Riverpod 2.x**.
* Basis data lokal menggunakan **SQLite (sqflite)**.
* Cloud sync layer terhubung ke **Supabase / PostgreSQL**.

---
*Dibuat dengan ❤️ untuk kemudahan pelaku usaha retail Indonesia bersama Tokona POS.*
