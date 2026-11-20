enum AppPermission {
  // 1. Kasir & Penjualan
  posCheckout('pos_checkout', 'Transaksi Kasir POS', 'Melakukan scan barcode, keranjang & pembayaran kasir', 'Kasir & Penjualan'),
  holdCart('hold_cart', 'Tahan Pesanan & Booking', 'Menyimpan pesanan ditahan dan jadwal reminder WA', 'Kasir & Penjualan'),
  closingShift('closing_shift', 'Tutup Kasir (Closing)', 'Rekapitulasi fisik uang laci kasir dan kirim rekap ke owner', 'Kasir & Penjualan'),

  // 2. Produk & Inventaris
  viewProducts('view_products', 'Lihat Katalog & Stok', 'Melihat daftar master produk, sisa stok, dan harga jual', 'Produk & Inventaris'),
  manageProducts('manage_products', 'Tambah / Edit Produk', 'Input barang baru, ganti nama barang, foto dan harga jual', 'Produk & Inventaris'),
  deleteProducts('delete_products', 'Hapus Produk', 'Menghapus produk dari sistem database toko', 'Produk & Inventaris'),
  viewHppCost('view_hpp_cost', 'Lihat Modal Barang (HPP)', 'Melihat harga kulakan/beli dan estimasi modal stok', 'Produk & Inventaris'),
  deviceStock('device_stock', 'Multi Perangkat & Alokasi', 'Pantau pembagian stok per HP kasir dan perangkat', 'Produk & Inventaris'),

  // 3. Pengadaan & Supplier
  restockPurchase('restock_purchase', 'Faktur Restok / Kulakan', 'Catat nota pembelian barang masuk dari supplier', 'Pengadaan & Kulakan'),
  purchaseHistory('purchase_history', 'Riwayat Kulakan', 'Daftar nota kulakan dan faktur supplier masa lalu', 'Pengadaan & Kulakan'),
  manageSuppliers('manage_suppliers', 'Master Supplier', 'Kelola kontak distributor dan sales keliling', 'Pengadaan & Kulakan'),

  // 4. Keuangan & Laporan
  salesHistory('sales_history', 'Riwayat Nota Kasir', 'Melihat struk transaksi penjualan toko', 'Keuangan & Laporan'),
  viewProfit('view_profit', 'Laporan Laba / Profit Bersih', 'Melihat keuntungan bersih toko dan margin laba', 'Keuangan & Laporan'),
  paymentAccounts('payment_accounts', 'Rekening & Saldo Bank', 'Melihat saldo kas, rekening bank, dan ShopeePay', 'Keuangan & Laporan'),
  storeCapital('store_capital', 'Modal Toko & Tarik Prive', 'Pantau modal awal dan penarikan kas pribadi', 'Keuangan & Laporan'),
  exportReports('export_reports', 'Export Laporan', 'Download laporan toko dalam bentuk PDF / Excel', 'Keuangan & Laporan'),

  // 5. Pelanggan & Kasbon
  manageCustomers('manage_customers', 'Data Pelanggan', 'Kelola daftar pelanggan, member, dan riwayat belanja', 'Pelanggan & Relasi'),
  createKasbon('create_kasbon', 'Transaksi Kasbon / Hutang', 'Izinkan kasir memproses transaksi tempo/kasbon', 'Pelanggan & Relasi'),
  viewKasbonDue('view_kasbon_due', 'Jatuh Tempo Kasbon', 'Pantau kasbon lewat tempo dan kirim pesan penagihan', 'Pelanggan & Relasi'),

  // 6. Pengaturan & Sistem
  storeSettings('store_settings', 'Informasi & Pengaturan Toko', 'Ubah nama toko, alamat, printer, dan suara', 'Pengaturan & Sistem'),
  manageRbac('manage_rbac', 'Kelola Hak Akses (RBAC)', 'Mengatur izin dan visibilitas menu untuk staf kasir', 'Pengaturan & Sistem');

  final String key;
  final String label;
  final String description;
  final String category;

  const AppPermission(this.key, this.label, this.description, this.category);

  static AppPermission? fromKey(String key) {
    for (final p in AppPermission.values) {
      if (p.key == key) return p;
    }
    return null;
  }
}

class RolePermissionConfig {
  final Map<String, Set<String>> permissionsByRole;

  const RolePermissionConfig({required this.permissionsByRole});

  factory RolePermissionConfig.defaults() {
    return RolePermissionConfig(
      permissionsByRole: {
        'cashier': {
          AppPermission.posCheckout.key,
          AppPermission.holdCart.key,
          AppPermission.closingShift.key,
          AppPermission.viewProducts.key,
          AppPermission.salesHistory.key,
          AppPermission.createKasbon.key,
          AppPermission.manageCustomers.key,
        },
        'manager': {
          AppPermission.posCheckout.key,
          AppPermission.holdCart.key,
          AppPermission.closingShift.key,
          AppPermission.viewProducts.key,
          AppPermission.manageProducts.key,
          AppPermission.viewHppCost.key,
          AppPermission.deviceStock.key,
          AppPermission.restockPurchase.key,
          AppPermission.purchaseHistory.key,
          AppPermission.manageSuppliers.key,
          AppPermission.salesHistory.key,
          AppPermission.manageCustomers.key,
          AppPermission.createKasbon.key,
          AppPermission.viewKasbonDue.key,
        },
        'owner': {
          for (final p in AppPermission.values) p.key,
        },
      },
    );
  }

  bool hasPermission(String roleKey, String permissionKey) {
    if (roleKey == 'owner' || roleKey == 'super_admin') return true;
    final set = permissionsByRole[roleKey];
    return set?.contains(permissionKey) ?? false;
  }

  RolePermissionConfig copyWithPermission({
    required String roleKey,
    required String permissionKey,
    required bool isAllowed,
  }) {
    final updatedMap = <String, Set<String>>{};
    for (final entry in permissionsByRole.entries) {
      updatedMap[entry.key] = Set<String>.from(entry.value);
    }

    final roleSet = updatedMap.putIfAbsent(roleKey, () => <String>{});
    if (isAllowed) {
      roleSet.add(permissionKey);
    } else {
      roleSet.remove(permissionKey);
    }

    return RolePermissionConfig(permissionsByRole: updatedMap);
  }

  Map<String, dynamic> toMap() {
    return {
      for (final entry in permissionsByRole.entries) entry.key: entry.value.toList(),
    };
  }

  factory RolePermissionConfig.fromMap(Map<String, dynamic> map) {
    final parsed = <String, Set<String>>{};
    for (final entry in map.entries) {
      if (entry.value is List) {
        parsed[entry.key] = (entry.value as List).map((e) => e.toString()).toSet();
      }
    }
    return RolePermissionConfig(permissionsByRole: parsed);
  }
}
