import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/utils/id_generator.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/customer/domain/models/customer_model.dart';
import 'package:tokona/features/customer/domain/models/customer_receivable_payment_model.dart';
import 'package:tokona/features/customer/presentation/controllers/customer_controller.dart';
import 'package:tokona/features/payment/presentation/controllers/payment_account_controller.dart';

class PayKasbonBottomSheet extends ConsumerStatefulWidget {
  final CustomerModel customer;

  const PayKasbonBottomSheet({super.key, required this.customer});

  static Future<bool?> show(BuildContext context, {required CustomerModel customer}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PayKasbonBottomSheet(customer: customer),
    );
  }

  @override
  ConsumerState<PayKasbonBottomSheet> createState() => _PayKasbonBottomSheetState();
}

class _PayKasbonBottomSheetState extends ConsumerState<PayKasbonBottomSheet> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedAccountId;
  String? _selectedAccountName;
  bool _isSubmitting = false;

  double get _enteredAmount => CurrencyFormatter.parse(_amountController.text);
  bool get _isAmountValid => _enteredAmount > 0 && _enteredAmount <= widget.customer.receivableBalance;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentAccountListProvider.notifier).loadAccounts(widget.customer.storeId);
    });
  }

  void _onAmountChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _handleSubmit() async {
    if (!_isAmountValid) return;

    setState(() => _isSubmitting = true);
    try {
      final now = DateTime.now();
      final payment = CustomerReceivablePaymentModel(
        id: IdGenerator.generateId(prefix: 'CRP'),
        storeId: widget.customer.storeId,
        customerId: widget.customer.id,
        customerName: widget.customer.name,
        amount: _enteredAmount,
        paymentDate: _selectedDate,
        accountId: _selectedAccountId,
        accountName: _selectedAccountName,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdAt: now,
        updatedAt: now,
      );

      final ok = await ref.read(customerListProvider.notifier).payKasbon(payment);
      if (ok && mounted) {
        AppToast.showSuccess(context, 'Pembayaran kasbon berhasil dicatat');
        Navigator.of(context).pop(true);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(paymentAccountListProvider);
    final dateFormat = DateFormat('dd MMMM yyyy');

    String? errorText;
    if (_amountController.text.isNotEmpty) {
      if (_enteredAmount <= 0) {
        errorText = 'Nominal harus lebih dari Rp 0';
      } else if (_enteredAmount > widget.customer.receivableBalance) {
        errorText = 'Melebihi sisa hutang (${CurrencyFormatter.format(widget.customer.receivableBalance)})';
      }
    }

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
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
                        Text('Bayar Kasbon Pelanggan', style: AppTypography.headingSmall.copyWith(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('Catat pelunasan atau cicilan ${widget.customer.name}', style: AppTypography.bodySmall.copyWith(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close_rounded, color: AppColors.textMuted), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFCA5A5))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sisa Hutang Kasbon', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF991B1B))),
                        Text(CurrencyFormatter.format(widget.customer.receivableBalance), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.error)),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => _amountController.text = CurrencyFormatter.formatNumber(widget.customer.receivableBalance),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: const Text('Lunaskan Semua', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                autofocus: true,
                inputFormatters: [CurrencyTextInputFormatter()],
                decoration: InputDecoration(labelText: 'Nominal Bayar (Rp) *', hintText: '0', prefixText: 'Rp ', errorText: errorText, prefixIcon: const Icon(Icons.payments_outlined, size: 20)),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary), const SizedBox(width: 8), Text(dateFormat.format(_selectedDate), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))]),
                      const Text('Ubah', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (accounts.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  value: _selectedAccountId,
                  decoration: const InputDecoration(labelText: 'Masuk ke Rekening / Kas Toko', prefixIcon: Icon(Icons.account_balance_wallet_outlined, size: 20)),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tanpa Hubungkan Rekening')),
                    ...accounts.map((acc) => DropdownMenuItem(value: acc.id, child: Text(acc.accountNumber != null && acc.accountNumber!.isNotEmpty ? '${acc.name} (${acc.accountNumber})' : acc.name))),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedAccountId = val;
                      _selectedAccountName = accounts.where((a) => a.id == val).firstOrNull?.name;
                    });
                  },
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Catatan / Keterangan (Opsional)', hintText: 'Titip tetangga / transfer bank', prefixIcon: Icon(Icons.edit_note_rounded, size: 20)),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isAmountValid && !_isSubmitting ? _handleSubmit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFE2E8F0),
                    disabledForegroundColor: const Color(0xFF94A3B8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Simpan Pembayaran Kasbon', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
