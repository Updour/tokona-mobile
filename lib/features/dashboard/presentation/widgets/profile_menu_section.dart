import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/providers/alert_notification_provider.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/backup/presentation/widgets/backup_restore_bottom_sheet.dart';
import 'package:tokona/features/customer/presentation/widgets/customer_list_bottom_sheet.dart';
import 'package:tokona/features/customer/presentation/widgets/kasbon_due_monitor_sheet.dart';
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
import 'package:tokona/features/supplier/presentation/widgets/supplier_list_bottom_sheet.dart';

class ProfileMenuSection extends ConsumerWidget {
  const ProfileMenuSection({super.key});

  List<ProfileMenuGroup> _getGroups(BuildContext context, AlertNotificationState alerts) {
    return [
      ProfileMenuGroup(
        title: 'Penjualan & Pelanggan',
        count: '3 Menu',
        icon: Icons.point_of_sale_rounded,
        iconColor: const Color(0xFF0D9488),
        iconBg: const Color(0xFFCCFBF1),
        initiallyExpanded: true,
        items: [
          ProfileMenuItem(
            icon: Icons.receipt_long_rounded,
            color: const Color(0xFF0D9488),
            bg: const Color(0xFFCCFBF1),
            title: 'Riwayat Transaksi Penjualan',
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
            title: 'Jatuh Tempo Kasbon Pelanggan',
            subtitle: 'Deteksi batas waktu pelunasan & kasbon telat',
            badgeText: alerts.hasUrgentKasbon ? '${alerts.totalUrgentKasbon}' : null,
            badgeColor: alerts.hasOverdueKasbon ? const Color(0xFFDC2626) : const Color(0xFFD97706),
            onTap: () => KasbonDueMonitorSheet.show(context),
          ),
        ],
      ),
      ProfileMenuGroup(
        title: 'Pengadaan & Stok Barang',
        count: '6 Menu',
        icon: Icons.inventory_2_outlined,
        iconColor: const Color(0xFF4F46E5),
        iconBg: const Color(0xFFEEF2FF),
        items: [
          ProfileMenuItem(
            icon: Icons.add_shopping_cart_rounded,
            color: const Color(0xFF0284C7),
            bg: const Color(0xFFE0F2FE),
            title: 'Faktur Belanja Stok & Restok',
            subtitle: 'Input kulakan dan modal HPP barang',
            badgeText: alerts.hasUrgentStock ? '${alerts.totalUrgentStock}' : null,
            badgeColor: alerts.outOfStockCount > 0 ? const Color(0xFFDC2626) : const Color(0xFFD97706),
            onTap: () => AddPurchaseBottomSheet.show(context),
          ),
          ProfileMenuItem(
            icon: Icons.receipt_long_rounded,
            color: const Color(0xFF4F46E5),
            bg: const Color(0xFFEEF2FF),
            title: 'Riwayat Pembelian & Faktur',
            subtitle: 'Daftar transaksi belanja dan nota kulakan',
            onTap: () => PurchaseHistorySheet.show(context),
          ),
          ProfileMenuItem(
            icon: Icons.hourglass_top_rounded,
            color: const Color(0xFFD97706),
            bg: const Color(0xFFFEF3C7),
            title: 'Pesanan Berjalan & PO Supplier',
            subtitle: 'Pantau pesanan stok yang masih dikirim',
            onTap: () => IncomingOrdersSheet.show(context),
          ),
          ProfileMenuItem(
            icon: Icons.business_outlined,
            color: const Color(0xFFF59E0B),
            bg: const Color(0xFFFEF3C7),
            title: 'Master Supplier & Distributor',
            subtitle: 'Kelola distributor dan sales keliling',
            onTap: () => SupplierListBottomSheet.show(context),
          ),
          ProfileMenuItem(
            icon: Icons.currency_exchange_rounded,
            color: const Color(0xFFE11D48),
            bg: const Color(0xFFFFE4E6),
            title: 'Dana Tertahan & Refund',
            subtitle: 'Pantau pengembalian dana Shopee/TikTok',
            onTap: () => RefundMonitorSheet.show(context),
          ),
          ProfileMenuItem(
            icon: Icons.phone_android_rounded,
            color: const Color(0xFF0D9488),
            bg: const Color(0xFFCCFBF1),
            title: 'Master HP Belanja Online',
            subtitle: 'Kelola perangkat akun Shopee & TikTok',
            onTap: () => DeviceManagementSheet.show(context),
          ),
        ],
      ),
      ProfileMenuGroup(
        title: 'Keuangan & Modal Usaha',
        count: '2 Menu',
        icon: Icons.account_balance_wallet_outlined,
        iconColor: const Color(0xFF2563EB),
        iconBg: const Color(0xFFEFF6FF),
        items: [
          ProfileMenuItem(
            icon: Icons.account_balance_wallet_outlined,
            color: const Color(0xFF2563EB),
            bg: const Color(0xFFEFF6FF),
            title: 'Master Rekening & Saldo Kas',
            subtitle: 'Kelola BCA, BRI, ShopeePay & pantau saldo',
            onTap: () => PaymentAccountManagementSheet.show(context),
          ),
          ProfileMenuItem(
            icon: Icons.savings_outlined,
            color: const Color(0xFF059669),
            bg: const Color(0xFFD1FAE5),
            title: 'Modal Toko & Tarik Prive',
            subtitle: 'Pantau modal awal dan penarikan kas',
            onTap: () => StoreCapitalManagementSheet.show(context),
          ),
        ],
      ),
      ProfileMenuGroup(
        title: 'Katalog Produk & Kemasan',
        count: '2 Menu',
        icon: Icons.category_outlined,
        iconColor: AppColors.primary,
        iconBg: AppColors.primaryContainer,
        items: [
          ProfileMenuItem(
            icon: Icons.category_outlined,
            color: AppColors.primary,
            bg: AppColors.primaryContainer,
            title: 'Kategori & Tipe Produk',
            subtitle: 'Kelola kategori barang untuk filter kasir',
            onTap: () => CategoryTypeSheet.show(context),
          ),
          ProfileMenuItem(
            icon: Icons.layers_outlined,
            color: const Color(0xFFD97706),
            bg: const Color(0xFFFEF3C7),
            title: 'Satuan Kemasan Bertingkat',
            subtitle: 'Panduan konversi Dus, Lusin, dan Pcs',
            onTap: () => PackagingInfoDialog.show(context),
          ),
        ],
      ),
      ProfileMenuGroup(
        title: 'Keamanan & Cadangan Data',
        count: '1 Menu',
        icon: Icons.shield_outlined,
        iconColor: const Color(0xFF0D9488),
        iconBg: const Color(0xFFCCFBF1),
        items: [
          ProfileMenuItem(
            icon: Icons.cloud_sync_rounded,
            color: const Color(0xFF0D9488),
            bg: const Color(0xFFCCFBF1),
            title: 'Cadangkan & Pulihkan Data',
            subtitle: 'Backup database toko offline & restore kapan saja',
            onTap: () => BackupRestoreBottomSheet.show(context),
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(alertNotificationProvider);
    final groups = _getGroups(context, alerts);
    return Column(children: groups.map((g) => _buildAccordion(context, g)).toList());
  }

  Widget _buildAccordion(BuildContext context, ProfileMenuGroup group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.65)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: group.initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
          childrenPadding: const EdgeInsets.only(bottom: 6),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: group.iconBg, borderRadius: BorderRadius.circular(11)),
            child: Icon(group.icon, color: group.iconColor, size: 19),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  group.title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: group.iconBg.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(8)),
                child: Text(group.count, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: group.iconColor)),
              ),
            ],
          ),
          children: [
            const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.border),
            ...group.items.asMap().entries.map((entry) {
              return _buildTile(context, entry.value, entry.key == group.items.length - 1);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, ProfileMenuItem item, bool isLast) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: item.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(color: item.bg, borderRadius: BorderRadius.circular(9)),
                    child: Icon(item.icon, color: item.color, size: 17),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
                        Text(item.subtitle, style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  if (item.badgeText != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (item.badgeColor ?? AppColors.primary).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: (item.badgeColor ?? AppColors.primary).withValues(alpha: 0.4)),
                      ),
                      child: Text(item.badgeText!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: item.badgeColor ?? AppColors.primary)),
                    ),
                    const SizedBox(width: 6),
                  ],
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 17),
                ],
              ),
            ),
          ),
        ),
        if (!isLast) const Divider(height: 1, indent: 60, endIndent: 16, color: Color(0xFFF1F5F9)),
      ],
    );
  }
}
