import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/backup/presentation/widgets/backup_restore_bottom_sheet.dart';
import 'package:tokona/features/customer/presentation/widgets/customer_list_bottom_sheet.dart';
import 'package:tokona/features/customer/presentation/widgets/kasbon_due_monitor_sheet.dart';
import 'package:tokona/features/dashboard/presentation/widgets/store_closing_sheet.dart';
import 'package:tokona/features/payment/presentation/widgets/payment_account_management_sheet.dart';
import 'package:tokona/features/payment/presentation/widgets/store_capital_management_sheet.dart';
import 'package:tokona/features/pos/presentation/widgets/sales_history_sheet.dart';
import 'package:tokona/features/pos/presentation/widgets/scheduled_reminder_sheet.dart';
import 'package:tokona/features/product/presentation/controllers/classification_controller.dart';
import 'package:tokona/features/product/presentation/controllers/product_controller.dart';
import 'package:tokona/features/product/presentation/widgets/add_product_bottom_sheet.dart';
import 'package:tokona/features/product/presentation/widgets/category_type_sheet.dart';
import 'package:tokona/features/product/presentation/widgets/device_stock_monitoring_sheet.dart';
import 'package:tokona/features/purchase/presentation/widgets/add_purchase_bottom_sheet.dart';
import 'package:tokona/features/purchase/presentation/widgets/incoming_orders_sheet.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_history_sheet.dart';
import 'package:tokona/features/supplier/presentation/widgets/supplier_list_bottom_sheet.dart';

class ShortcutActionDispatcher {
  ShortcutActionDispatcher._();

  static void dispatch(
    BuildContext context,
    WidgetRef ref,
    String id, {
    ValueChanged<int>? onNavigateTab,
  }) {
    HapticFeedback.lightImpact();
    final store = ref.read(authProvider).currentStore;

    switch (id) {
      case 'kasir':
        onNavigateTab?.call(2);
        break;
      case 'jadwal_wa':
        ScheduledReminderSheet.show(context);
        break;
      case 'jatuh_tempo':
        KasbonDueMonitorSheet.show(context);
        break;
      case 'pesanan_masuk':
        IncomingOrdersSheet.show(context);
        break;
      case 'riwayat_transaksi':
        SalesHistorySheet.show(context);
        break;
      case 'tutup_toko':
        StoreClosingSheet.show(context);
        break;
      case 'katalog':
        onNavigateTab?.call(1);
        break;
      case 'tambah_produk':
        if (store != null) {
          final classification = ref.read(classificationProvider);
          AddProductBottomSheet.show(
            context,
            availableCategories: classification.categories,
            availableProductTypes: classification.productTypes,
            onSubmit: (dto) async {
              final ok = await ref.read(productListProvider.notifier).addProduct(store.id, dto);
              if (ok) ref.read(classificationProvider.notifier).load(store.id);
              return ok;
            },
          );
        }
        break;
      case 'restok':
        AddPurchaseBottomSheet.show(context);
        break;
      case 'kategori':
        CategoryTypeSheet.show(context);
        break;
      case 'riwayat_kulakan':
        PurchaseHistorySheet.show(context);
        break;
      case 'stok_perangkat':
        final summaries = ref.read(productListProvider).deviceSummaries;
        DeviceStockMonitoringSheet.show(
          context,
          summaries: summaries,
          selectedDeviceTag: null,
          onSelectDevice: (_) {},
        );
        break;
      case 'laba_rugi':
        onNavigateTab?.call(3);
        break;
      case 'modal_toko':
        StoreCapitalManagementSheet.show(context);
        break;
      case 'rekening_bayar':
        PaymentAccountManagementSheet.show(context);
        break;
      case 'cadangan':
        BackupRestoreBottomSheet.show(context);
        break;
      case 'daftar_pelanggan':
        CustomerListBottomSheet.show(context);
        break;
      case 'daftar_supplier':
        SupplierListBottomSheet.show(context);
        break;
    }
  }
}

