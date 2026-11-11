import 'package:flutter/material.dart';

class ShortcutMenuItem {
  final String id;
  final String label;
  final String category;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String description;

  const ShortcutMenuItem({
    required this.id,
    required this.label,
    required this.category,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.description,
  });
}

class AppShortcutRegistry {
  AppShortcutRegistry._();

  static const List<String> defaultPinnedIds = [
    'kasir',
    'jadwal_wa',
    'jatuh_tempo',
    'tutup_toko',
    'katalog',
    'tambah_produk',
    'restok',
  ];

  static const List<ShortcutMenuItem> all = [
    // --- Kategori Kasir & Penjualan ---
    ShortcutMenuItem(
      id: 'kasir',
      label: 'Kasir POS',
      category: 'Kasir & Penjualan',
      icon: Icons.point_of_sale_rounded,
      iconColor: Color(0xFFD97706),
      bgColor: Color(0xFFFEF3C7),
      description: 'Transaksi penjualan kasir langsung',
    ),
    ShortcutMenuItem(
      id: 'jadwal_wa',
      label: 'Jadwal & WA',
      category: 'Kasir & Penjualan',
      icon: Icons.schedule_send_rounded,
      iconColor: Color(0xFF059669),
      bgColor: Color(0xFFECFDF5),
      description: 'Pengingat pengambilan barang & jatuh tempo via WhatsApp',
    ),
    ShortcutMenuItem(
      id: 'jatuh_tempo',
      label: 'Jatuh Tempo',
      category: 'Kasir & Penjualan',
      icon: Icons.event_busy_rounded,
      iconColor: Color(0xFFDC2626),
      bgColor: Color(0xFFFEE2E2),
      description: 'Monitor tagihan kasbon yang mendekati/lewat tempo',
    ),
    ShortcutMenuItem(
      id: 'pesanan_masuk',
      label: 'Pesanan Masuk',
      category: 'Kasir & Penjualan',
      icon: Icons.local_shipping_rounded,
      iconColor: Color(0xFFEA580C),
      bgColor: Color(0xFFFFEDD5),
      description: 'Daftar pesanan & pre-order pelanggan',
    ),
    ShortcutMenuItem(
      id: 'riwayat_transaksi',
      label: 'Riwayat Kasir',
      category: 'Kasir & Penjualan',
      icon: Icons.receipt_long_rounded,
      iconColor: Color(0xFF2563EB),
      bgColor: Color(0xFFEFF6FF),
      description: 'Lihat daftar nota dan cetak ulang struk kasir',
    ),
    ShortcutMenuItem(
      id: 'tutup_toko',
      label: 'Tutup Toko',
      category: 'Kasir & Penjualan',
      icon: Icons.store_mall_directory_rounded,
      iconColor: Color(0xFF4338CA),
      bgColor: Color(0xFFEEF2FF),
      description: 'Rekap kas harian, tutup sesi kasir, & cadangkan data',
    ),

    // --- Kategori Produk & Inventaris ---
    ShortcutMenuItem(
      id: 'katalog',
      label: 'Katalog',
      category: 'Produk & Inventaris',
      icon: Icons.inventory_2_rounded,
      iconColor: Color(0xFF6366F1),
      bgColor: Color(0xFFEEF2FF),
      description: 'Daftar master produk, stok, dan harga',
    ),
    ShortcutMenuItem(
      id: 'tambah_produk',
      label: 'Tambah Item',
      category: 'Produk & Inventaris',
      icon: Icons.add_circle_outline_rounded,
      iconColor: Color(0xFF0D9488),
      bgColor: Color(0xFFCCFBF1),
      description: 'Input produk baru ke sistem toko',
    ),
    ShortcutMenuItem(
      id: 'restok',
      label: 'Restok Barang',
      category: 'Produk & Inventaris',
      icon: Icons.add_shopping_cart_rounded,
      iconColor: Color(0xFF0284C7),
      bgColor: Color(0xFFE0F2FE),
      description: 'Catat pembelian barang dari supplier (kulakan)',
    ),
    ShortcutMenuItem(
      id: 'kategori',
      label: 'Kategori Item',
      category: 'Produk & Inventaris',
      icon: Icons.category_rounded,
      iconColor: Color(0xFF7C3AED),
      bgColor: Color(0xFFF5F3FF),
      description: 'Kelola kategori dan jenis klasifikasi produk',
    ),
    ShortcutMenuItem(
      id: 'riwayat_kulakan',
      label: 'Riwayat Kulak',
      category: 'Produk & Inventaris',
      icon: Icons.history_rounded,
      iconColor: Color(0xFF0891B2),
      bgColor: Color(0xFFECFEFF),
      description: 'Daftar riwayat nota pembelian dan faktur supplier',
    ),
    ShortcutMenuItem(
      id: 'stok_perangkat',
      label: 'Multi Perangkat',
      category: 'Produk & Inventaris',
      icon: Icons.devices_rounded,
      iconColor: Color(0xFF475569),
      bgColor: Color(0xFFF1F5F9),
      description: 'Monitor alokasi stok per perangkat kasir',
    ),

    // --- Kategori Keuangan & Laporan ---
    ShortcutMenuItem(
      id: 'laba_rugi',
      label: 'Laba Rugi',
      category: 'Keuangan & Laporan',
      icon: Icons.insights_rounded,
      iconColor: Color(0xFF8B5CF6),
      bgColor: Color(0xFFEDE9FE),
      description: 'Analisis omzet, margin keuntungan, & laporan toko',
    ),
    ShortcutMenuItem(
      id: 'modal_toko',
      label: 'Modal Toko',
      category: 'Keuangan & Laporan',
      icon: Icons.account_balance_wallet_rounded,
      iconColor: Color(0xFF16A34A),
      bgColor: Color(0xFFDCFCE7),
      description: 'Kelola catatan modal awal & penarikan kas',
    ),
    ShortcutMenuItem(
      id: 'rekening_bayar',
      label: 'Rekening/QRIS',
      category: 'Keuangan & Laporan',
      icon: Icons.credit_card_rounded,
      iconColor: Color(0xFF0284C7),
      bgColor: Color(0xFFE0F2FE),
      description: 'Daftar nomor rekening bank & QRIS toko',
    ),
    ShortcutMenuItem(
      id: 'cadangan',
      label: 'Cadangan Data',
      category: 'Keuangan & Laporan',
      icon: Icons.cloud_sync_rounded,
      iconColor: Color(0xFF0F766E),
      bgColor: Color(0xFFE6FFFA),
      description: 'Cadangkan database ke Cloud Supabase atau lokal HP',
    ),

    // --- Kategori Pelanggan & Relasi ---
    ShortcutMenuItem(
      id: 'daftar_pelanggan',
      label: 'Pelanggan',
      category: 'Pelanggan & Relasi',
      icon: Icons.people_alt_rounded,
      iconColor: Color(0xFFD97706),
      bgColor: Color(0xFFFEF3C7),
      description: 'Buku pelanggan, saldo kasbon, & riwayat belanja',
    ),
    ShortcutMenuItem(
      id: 'daftar_supplier',
      label: 'Supplier',
      category: 'Pelanggan & Relasi',
      icon: Icons.local_shipping_outlined,
      iconColor: Color(0xFF64748B),
      bgColor: Color(0xFFF8FAFC),
      description: 'Daftar mitra distributor & pemasok barang',
    ),
  ];

  static ShortcutMenuItem? findById(String id) {
    try {
      return all.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }
}

