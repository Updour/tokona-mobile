import 'package:flutter/material.dart';
import 'package:tokona/core/providers/alert_notification_provider.dart';
import 'package:tokona/features/backup/presentation/widgets/backup_restore_bottom_sheet.dart';
import 'package:tokona/features/customer/presentation/widgets/customer_list_bottom_sheet.dart';
import 'package:tokona/features/customer/presentation/widgets/kasbon_due_monitor_sheet.dart';
import 'package:tokona/features/dashboard/presentation/widgets/about_app_dialog.dart';
import 'package:tokona/features/dashboard/presentation/widgets/profile_menu_data.dart';
import 'package:tokona/features/payment/presentation/widgets/payment_account_management_sheet.dart';
import 'package:tokona/features/payment/presentation/widgets/store_capital_management_sheet.dart';
import 'package:tokona/features/pos/presentation/widgets/sales_history_sheet.dart';
import 'package:tokona/features/product/presentation/widgets/category_type_sheet.dart';
import 'package:tokona/features/product/presentation/widgets/packaging_info_dialog.dart';
import 'package:tokona/features/purchase/presentation/widgets/add_purchase_bottom_sheet.dart';
import 'package:tokona/features/purchase/presentation/widgets/device_management_sheet.dart';
import 'package:tokona/features/purchase/presentation/widgets/incoming_orders_sheet.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_history_sheet.dart';
import 'package:tokona/features/purchase/presentation/widgets/refund_monitor_sheet.dart';
import 'package:tokona/features/settings/presentation/widgets/pos_rounding_settings_sheet.dart';
import 'package:tokona/features/supplier/presentation/widgets/supplier_list_bottom_sheet.dart';

List<ProfileMenuGroup> buildProfileMenuGroups(BuildContext context, AlertNotificationState alerts) {
  return [
    ProfileMenuGroup(
      title: 'Penjualan & Pelanggan',
      icon: Icons.point_of_sale_rounded,
      iconColor: const Color(0xFF0D9488),
      iconBg: const Color(0xFFCCFBF1),
      initiallyExpanded: true,
      items: [
        ProfileMenuItem(
          icon: Icons.receipt_long_rounded,
          color: const Color(0xFF0D9488),
          bg: const Color(0xFFCCFBF1),
          title: 'Riwayat Penjualan',
          subtitle: 'Pantau nota kasir, cetak struk, dan void',
          onTap: () => SalesHistorySheet.show(context),
        ),
        ProfileMenuItem(
          icon: Icons.people_outline_rounded,
          color: const Color(0xFF6366F1),
          bg: const Color(0xFFEEF2FF),
          title: 'Data Pelanggan',
          subtitle: 'Langganan toko, member, dan piutang kasbon',
          onTap: () => CustomerListBottomSheet.show(context),
        ),
        ProfileMenuItem(
          icon: Icons.event_busy_rounded,
          color: alerts.hasOverdueKasbon ? const Color(0xFFDC2626) : const Color(0xFFD97706),
          bg: alerts.hasOverdueKasbon ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7),
          title: 'Jatuh Tempo Kasbon',
          subtitle: 'Batas pelunasan & kasbon telat bayar',
          badgeText: alerts.hasUrgentKasbon ? '${alerts.totalUrgentKasbon}' : null,
          badgeColor: alerts.hasOverdueKasbon ? const Color(0xFFDC2626) : const Color(0xFFD97706),
          onTap: () => KasbonDueMonitorSheet.show(context),
        ),
      ],
    ),
    ProfileMenuGroup(
      title: 'Pengadaan & Stok',
      icon: Icons.inventory_2_outlined,
      iconColor: const Color(0xFF4F46E5),
      iconBg: const Color(0xFFEEF2FF),
      items: [
        ProfileMenuItem(
          icon: Icons.add_shopping_cart_rounded,
          color: const Color(0xFF0284C7),
          bg: const Color(0xFFE0F2FE),
          title: 'Faktur Belanja Stok',
          subtitle: 'Input kulakan dan modal HPP barang',
          badgeText: alerts.hasUrgentStock ? '${alerts.totalUrgentStock}' : null,
          badgeColor: alerts.outOfStockCount > 0 ? const Color(0xFFDC2626) : const Color(0xFFD97706),
          onTap: () => AddPurchaseBottomSheet.show(context),
        ),
        ProfileMenuItem(
          icon: Icons.receipt_long_rounded,
          color: const Color(0xFF4F46E5),
          bg: const Color(0xFFEEF2FF),
          title: 'Riwayat Pembelian',
          subtitle: 'Daftar transaksi belanja dan nota kulakan',
          onTap: () => PurchaseHistorySheet.show(context),
        ),
        ProfileMenuItem(
          icon: Icons.hourglass_top_rounded,
          color: const Color(0xFFD97706),
          bg: const Color(0xFFFEF3C7),
          title: 'Pesanan Masuk (PO)',
          subtitle: 'Pantau paket PO & pesanan yang sedang OTW',
          onTap: () => IncomingOrdersSheet.show(context),
        ),
        ProfileMenuItem(
          icon: Icons.business_outlined,
          color: const Color(0xFFF59E0B),
          bg: const Color(0xFFFEF3C7),
          title: 'Master Supplier',
          subtitle: 'Kelola distributor dan sales keliling',
          onTap: () => SupplierListBottomSheet.show(context),
        ),
        ProfileMenuItem(
          icon: Icons.category_outlined,
          color: const Color(0xFF7C3AED),
          bg: const Color(0xFFEDE9FE),
          title: 'Kategori Produk',
          subtitle: 'Kelompok barang dagangan toko',
          onTap: () => CategoryTypeSheet.show(context),
        ),
        ProfileMenuItem(
          icon: Icons.layers_outlined,
          color: const Color(0xFF0D9488),
          bg: const Color(0xFFCCFBF1),
          title: 'Bantuan Kemasan & Satuan',
          subtitle: 'Panduan renteng, pak, karton & konversi',
          onTap: () => PackagingInfoDialog.show(context),
        ),
      ],
    ),
    ProfileMenuGroup(
      title: 'Restok Online Marketplace',
      icon: Icons.shopping_bag_outlined,
      iconColor: const Color(0xFFEA580C),
      iconBg: const Color(0xFFFFEDD5),
      items: [
        ProfileMenuItem(
          icon: Icons.devices_other_rounded,
          color: const Color(0xFF6366F1),
          bg: const Color(0xFFEEF2FF),
          title: 'Device Belanja Online',
          subtitle: 'Atur tag device pengadaan akun e-commerce',
          onTap: () => DeviceManagementSheet.show(context),
        ),
        ProfileMenuItem(
          icon: Icons.assignment_return_outlined,
          color: const Color(0xFFEF4444),
          bg: const Color(0xFFFEE2E2),
          title: 'Pengembalian & Refund',
          subtitle: 'Pantau status refund marketplace & J&T',
          onTap: () => RefundMonitorSheet.show(context),
        ),
      ],
    ),
    ProfileMenuGroup(
      title: 'Kas Toko & Pembayaran',
      icon: Icons.account_balance_wallet_outlined,
      iconColor: const Color(0xFF059669),
      iconBg: const Color(0xFFDCFCE7),
      items: [
        ProfileMenuItem(
          icon: Icons.account_balance_outlined,
          color: const Color(0xFF059669),
          bg: const Color(0xFFDCFCE7),
          title: 'Metode Pembayaran & Bank',
          subtitle: 'Daftar rekening toko, kasir, dan QRIS',
          onTap: () => PaymentAccountManagementSheet.show(context),
        ),
        ProfileMenuItem(
          icon: Icons.account_balance_wallet_rounded,
          color: const Color(0xFF4338CA),
          bg: const Color(0xFFEEF2FF),
          title: 'Modal Toko & Prive',
          subtitle: 'Catat pemasukan, modal & tarik kas',
          onTap: () => StoreCapitalManagementSheet.show(context),
        ),
        ProfileMenuItem(
          icon: Icons.exposure_rounded,
          color: const Color(0xFF0D9488),
          bg: const Color(0xFFCCFBF1),
          title: 'Master Pembulatan Harga',
          subtitle: 'Atur round up, round down & kelipatan kasir',
          onTap: () => PosRoundingSettingsSheet.show(context),
        ),
      ],
    ),
    ProfileMenuGroup(
      title: 'Pengaturan & Sistem',
      icon: Icons.tune_rounded,
      iconColor: const Color(0xFF64748B),
      iconBg: const Color(0xFFF1F5F9),
      items: [
        ProfileMenuItem(
          icon: Icons.cloud_sync_outlined,
          color: const Color(0xFF2563EB),
          bg: const Color(0xFFDBEAFE),
          title: 'Cadangan & Pemulihan Data',
          subtitle: 'Backup database otomatis & cloud sync',
          onTap: () => BackupRestoreBottomSheet.show(context),
        ),
        ProfileMenuItem(
          icon: Icons.info_outline_rounded,
          color: const Color(0xFF64748B),
          bg: const Color(0xFFF1F5F9),
          title: 'Tentang Aplikasi Tokona',
          subtitle: 'Versi sistem dan informasi lisensi',
          onTap: () => AboutAppDialog.show(context),
        ),
      ],
    ),
  ];
}
