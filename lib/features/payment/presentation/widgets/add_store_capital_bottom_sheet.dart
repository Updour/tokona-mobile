import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/utils/id_generator.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/payment/domain/models/store_capital_model.dart';
import 'package:tokona/features/payment/presentation/controllers/payment_account_controller.dart';
import 'package:tokona/features/payment/presentation/controllers/store_capital_controller.dart';
import 'package:tokona/features/payment/presentation/widgets/store_capital_date_tile.dart';
import 'package:tokona/features/payment/presentation/widgets/store_capital_type_selector.dart';

class AddStoreCapitalBottomSheet extends ConsumerStatefulWidget {
  final String initialType;

  const AddStoreCapitalBottomSheet({
    super.key,
    this.initialType = 'TAMBAH_MODAL',
  });

  static Future<void> show(BuildContext context, {String initialType = 'TAMBAH_MODAL'}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddStoreCapitalBottomSheet(initialType: initialType),
    );
  }

  @override
  ConsumerState<AddStoreCapitalBottomSheet> createState() => _AddStoreCapitalBottomSheetState();
}

class _AddStoreCapitalBottomSheetState extends ConsumerState<AddStoreCapitalBottomSheet> {
  final _amountController = TextEditingController();
  final _sourceController = TextEditingController();
  final _notesController = TextEditingController();
  late String _selectedType;
  DateTime _selectedDate = DateTime.now();
  String? _selectedAccountId;
  String? _selectedAccountName;
  bool _isSubmitting = false;

  bool get _isFormValid => CurrencyFormatter.parse(_amountController.text) > 0;
  bool get _isWithdrawal => _selectedType == 'TARIK_MODAL';

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _sourceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _handleSubmit() async {
    final rawAmount = CurrencyFormatter.parse(_amountController.text);
    if (rawAmount <= 0) return;

    final storeId = ref.read(authProvider).currentStore?.id;
    if (storeId == null) return;

    setState(() => _isSubmitting = true);
    try {
      final now = DateTime.now();
      final capital = StoreCapitalModel(
        id: IdGenerator.generateId(prefix: 'CAP'),
        storeId: storeId,
        amount: rawAmount,
        type: _selectedType,
        capitalDate: _selectedDate,
        accountId: _selectedAccountId,
        accountName: _selectedAccountName,
        source: _sourceController.text.trim().isEmpty ? null : _sourceController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdAt: now,
        updatedAt: now,
      );

      final ok = await ref.read(storeCapitalControllerProvider.notifier).addCapital(capital);
      if (ok && mounted) {
        final actionText = _isWithdrawal ? 'Penarikan modal' : 'Catatan modal';
        AppToast.showSuccess(context, '$actionText berhasil disimpan');
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(paymentAccountListProvider);
    final title = _isWithdrawal
        ? 'Tarik Modal Toko (Prive)'
        : _selectedType == 'MODAL_AWAL'
            ? 'Catat Modal Awal'
            : 'Tambah Modal Toko';

    final btnLabel = _isWithdrawal
        ? 'Simpan Penarikan Modal'
        : _selectedType == 'MODAL_AWAL'
            ? 'Simpan Modal Awal'
            : 'Simpan Tambahan Modal';

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTypography.headingSmall.copyWith(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(
                          _isWithdrawal
                              ? 'Tarik dana modal / prive untuk keperluan pribadi'
                              : 'Kelola suntikan dana operasional dan modal toko',
                          style: AppTypography.bodySmall.copyWith(fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              StoreCapitalTypeSelector(
                selectedType: _selectedType,
                onTypeSelected: (type) => setState(() => _selectedType = type),
              ),
              if (_isWithdrawal) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 16, color: AppColors.error),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Prive akan memotong nilai modal usaha dan mengurangi saldo kas toko.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF991B1B)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                autofocus: true,
                inputFormatters: [CurrencyTextInputFormatter()],
                decoration: InputDecoration(
                  labelText: _isWithdrawal ? 'Nominal Penarikan (Rp) *' : 'Nominal Modal (Rp) *',
                  hintText: '0',
                  prefixText: 'Rp ',
                  helperText: _isFormValid ? null : 'Nominal wajib diisi dan harus lebih dari Rp 0',
                  helperStyle: TextStyle(
                    fontSize: 11,
                    color: _isFormValid ? AppColors.textMuted : AppColors.error,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              StoreCapitalDateTile(
                selectedDate: _selectedDate,
                isWithdrawal: _isWithdrawal,
                onTap: _pickDate,
              ),
              const SizedBox(height: 12),
              if (accounts.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  value: _selectedAccountId,
                  decoration: InputDecoration(
                    labelText: _isWithdrawal ? 'Tarik dari Rekening / Kas' : 'Masuk ke Rekening / Kas',
                    prefixIcon: const Icon(Icons.account_balance_wallet_outlined, size: 20),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tanpa Hubungkan Rekening')),
                    ...accounts.map(
                      (acc) => DropdownMenuItem(
                        value: acc.id,
                        child: Text(
                          acc.accountNumber != null && acc.accountNumber!.isNotEmpty
                              ? '${acc.name} (${acc.accountNumber})'
                              : acc.name,
                        ),
                      ),
                    ),
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
                controller: _sourceController,
                decoration: InputDecoration(
                  labelText: _isWithdrawal ? 'Penerima / Pemilik (Opsional)' : 'Sumber Dana (Opsional)',
                  hintText: _isWithdrawal ? 'Nama Pemilik' : 'Tabungan Pribadi / Pinjaman Bank',
                  prefixIcon: const Icon(Icons.source_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Keterangan / Catatan (Opsional)',
                  hintText: _isWithdrawal ? 'Keperluan pribadi' : 'Untuk tambahan stok barang',
                  prefixIcon: const Icon(Icons.notes_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isFormValid && !_isSubmitting ? _handleSubmit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isWithdrawal ? AppColors.error : AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFE2E8F0),
                    disabledForegroundColor: const Color(0xFF94A3B8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(btnLabel, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
