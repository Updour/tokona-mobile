import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/customer/domain/models/customer_model.dart';
import 'package:tokona/features/customer/domain/models/customer_receivable_payment_model.dart';
import 'package:tokona/features/customer/presentation/controllers/customer_controller.dart';
import 'package:tokona/features/customer/presentation/widgets/customer_ledger_payment_tile.dart';
import 'package:tokona/features/customer/presentation/widgets/pay_kasbon_bottom_sheet.dart';
import 'package:tokona/features/pos/domain/models/sale_model.dart';

class CustomerReceivableLedgerSheet extends ConsumerStatefulWidget {
  final CustomerModel customer;

  const CustomerReceivableLedgerSheet({super.key, required this.customer});

  static Future<void> show(BuildContext context, {required CustomerModel customer}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomerReceivableLedgerSheet(customer: customer),
    );
  }

  @override
  ConsumerState<CustomerReceivableLedgerSheet> createState() => _CustomerReceivableLedgerSheetState();
}

class _CustomerReceivableLedgerSheetState extends ConsumerState<CustomerReceivableLedgerSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<CustomerReceivablePaymentModel> _payments = [];
  List<SaleModel> _sales = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final notifier = ref.read(customerListProvider.notifier);
    final payments = await notifier.getReceivablePayments(widget.customer.id);
    final sales = await notifier.getCustomerReceivableSales(widget.customer.id);
    if (mounted) {
      setState(() {
        _payments = payments;
        _sales = sales;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customerListProvider).customers;
    final currentCustomer = customers.where((c) => c.id == widget.customer.id).firstOrNull ?? widget.customer;

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Buku Kasbon & Piutang', style: AppTypography.headingSmall.copyWith(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(currentCustomer.name, style: AppTypography.bodySmall.copyWith(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.close_rounded, color: AppColors.textMuted), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            const SizedBox(height: 12),
            _buildKpiCard(currentCustomer),
            const SizedBox(height: 14),
            Container(
              height: 38,
              decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(10)),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                tabs: [
                  Tab(text: 'Pelunasan (${_payments.length})'),
                  Tab(text: 'Belanja Kasbon (${_sales.length})'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildPaymentList(),
                        _buildSalesList(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(CustomerModel customer) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Sisa Hutang Kasbon', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF991B1B))),
              const SizedBox(height: 2),
              Text(
                CurrencyFormatter.format(customer.receivableBalance),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.error),
              ),
            ],
          ),
          if (customer.hasReceivable)
            ElevatedButton.icon(
              onPressed: () async {
                final paid = await PayKasbonBottomSheet.show(context, customer: customer);
                if (paid == true) _loadData();
              },
              icon: const Icon(Icons.payment_rounded, size: 15),
              label: const Text('Bayar Kasbon', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentList() {
    if (_payments.isEmpty) {
      return _buildEmptyState('Belum ada riwayat pembayaran kasbon');
    }

    return ListView.separated(
      itemCount: _payments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) => CustomerLedgerPaymentTile(item: _payments[index]),
    );
  }

  Widget _buildSalesList() {
    if (_sales.isEmpty) {
      return _buildEmptyState('Belum ada transaksi penjualan dengan metode kasbon');
    }
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return ListView.separated(
      itemCount: _sales.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = _sales[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.arrow_upward_rounded, color: AppColors.error, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(CurrencyFormatter.format(item.finalAmount), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.error)),
                    const SizedBox(height: 2),
                    Text('${item.invoiceNumber} - ${dateFormat.format(item.createdAt)}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 36, color: AppColors.textMuted),
            const SizedBox(height: 8),
            Text(msg, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
