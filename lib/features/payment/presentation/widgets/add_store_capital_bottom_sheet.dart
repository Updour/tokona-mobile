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
import 'package:tokona/features/payment/presentation/widgets/store_capital_account_picker.dart';
import 'package:tokona/features/payment/presentation/widgets/store_capital_extra_fields.dart';
import 'package:tokona/features/payment/presentation/widgets/store_capital_header.dart';
import 'package:tokona/features/payment/presentation/widgets/store_capital_live_projection_card.dart';
import 'package:tokona/features/payment/presentation/widgets/store_capital_menu_balance_card.dart';
import 'package:tokona/features/payment/presentation/widgets/store_capital_preset_chips.dart';
import 'package:tokona/features/payment/presentation/widgets/store_capital_submit_button.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storeId = ref.read(authProvider).currentStore?.id;
      if (storeId != null) {
        ref.read(paymentAccountListProvider.notifier).loadAccounts(storeId);
        ref.read(storeCapitalControllerProvider.notifier).loadCapitals(storeId);
      }
    });
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

    if (_isWithdrawal && _selectedAccountId != null) {
      final accounts = ref.read(paymentAccountListProvider);
      final acc = accounts.where((a) => a.id == _selectedAccountId).firstOrNull;
      if (acc != null && acc.currentBalance < rawAmount) {
        AppToast.showError(context, 'Saldo kas di ${acc.name} tidak mencukupi untuk penarikan ini');
        return;
      }
    }

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
        final actionText = _isWithdrawal ? 'Penarikan kas' : 'Catatan modal';
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
    final totalStoreBalance = ref.watch(totalStoreBalanceProvider);
    final capitalState = ref.watch(storeCapitalControllerProvider);
    final store = ref.watch(authProvider).currentStore;

    if (accounts.isEmpty && store != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(paymentAccountListProvider.notifier).loadAccounts(store.id);
      });
    }

    if (_selectedAccountId == null && accounts.isNotEmpty) {
      final primary = accounts.where((a) => a.currentBalance > 0).firstOrNull ?? accounts.first;
      _selectedAccountId = primary.id;
      _selectedAccountName = primary.name;
    }

    final title = _isWithdrawal
        ? 'Tarik Kas Toko (Prive)'
        : _selectedType == 'PEMASUKAN_LAIN'
            ? 'Catat Pemasukan Toko'
            : _selectedType == 'MODAL_AWAL'
                ? 'Catat Modal Awal'
                : 'Tambah Modal Toko';

    final btnLabel = _isWithdrawal
        ? 'Simpan Penarikan Kas'
        : _selectedType == 'PEMASUKAN_LAIN'
            ? 'Simpan Pemasukan Toko'
            : _selectedType == 'MODAL_AWAL'
                ? 'Simpan Modal Awal'
                : 'Simpan Tambahan Modal';

    final selectedAcc = accounts.where((a) => a.id == _selectedAccountId).firstOrNull;
    final currentAccBalance = selectedAcc?.currentBalance ?? totalStoreBalance;
    final targetName = selectedAcc != null ? selectedAcc.name : 'Kas Toko (Global)';
    final rawAmount = CurrencyFormatter.parse(_amountController.text);
    final isOverdrawn = _isWithdrawal && selectedAcc != null && (currentAccBalance - rawAmount < 0);

    return SafeArea(
      top: false,
      child: AnimatedPadding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutQuad,
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.90),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StoreCapitalHeader(
                title: title,
                isWithdrawal: _isWithdrawal,
                onClose: () => Navigator.of(context).pop(),
              ),
              const Divider(height: 14, color: Color(0xFFF1F5F9)),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      StoreCapitalTypeSelector(
                        selectedType: _selectedType,
                        onTypeSelected: (type) => setState(() => _selectedType = type),
                      ),
                      const SizedBox(height: 10),
                      StoreCapitalMenuBalanceCard(
                        type: _selectedType,
                        totalStoreBalance: totalStoreBalance,
                        capitalState: capitalState,
                        selectedAcc: selectedAcc,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _isWithdrawal ? 'Pilih Rekening / Sumber Kas yang Ditarik:' : 'Pilih Rekening Kas Tujuan:',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      StoreCapitalAccountPicker(
                        accounts: accounts,
                        selectedAccountId: _selectedAccountId,
                        isWithdrawal: _isWithdrawal,
                        onAccountSelected: (acc) {
                          setState(() {
                            _selectedAccountId = acc?.id;
                            _selectedAccountName = acc?.name;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        inputFormatters: [CurrencyTextInputFormatter()],
                        decoration: InputDecoration(
                          labelText: _isWithdrawal ? 'Nominal Penarikan (Rp) *' : 'Nominal Modal (Rp) *',
                          hintText: '0',
                          prefixText: 'Rp',
                          helperText: _isFormValid ? null : 'Nominal wajib diisi dan harus lebih dari Rp 0',
                          helperStyle: TextStyle(
                            fontSize: 11,
                            color: _isFormValid ? AppColors.textMuted : AppColors.error,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      StoreCapitalPresetChips(
                        isWithdrawal: _isWithdrawal,
                        currentAccBalance: currentAccBalance,
                        onAmountSelected: (amt) {
                          _amountController.text = CurrencyFormatter.formatNumber(amt);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: StoreCapitalLiveProjectionCard(
                          type: _selectedType,
                          targetName: targetName,
                          currentAccBalance: currentAccBalance,
                          rawAmount: rawAmount,
                          capitalState: capitalState,
                          isOverdrawn: isOverdrawn,
                        ),
                      ),
                      const SizedBox(height: 12),
                      StoreCapitalExtraFields(
                        isWithdrawal: _isWithdrawal,
                        selectedDate: _selectedDate,
                        onPickDate: _pickDate,
                        sourceController: _sourceController,
                        notesController: _notesController,
                      ),
                      const SizedBox(height: 20),
                      StoreCapitalSubmitButton(
                        isFormValid: _isFormValid,
                        isOverdrawn: isOverdrawn,
                        isSubmitting: _isSubmitting,
                        isWithdrawal: _isWithdrawal,
                        btnLabel: btnLabel,
                        onSubmit: _handleSubmit,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
