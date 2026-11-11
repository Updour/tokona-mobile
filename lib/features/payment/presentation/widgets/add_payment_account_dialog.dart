import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/payment/domain/models/payment_account_model.dart';
import 'package:tokona/features/payment/presentation/controllers/payment_account_controller.dart';

class AddPaymentAccountDialog extends ConsumerStatefulWidget {
  final PaymentAccountModel? initialAccount;

  const AddPaymentAccountDialog({super.key, this.initialAccount});

  static Future<PaymentAccountModel?> show(
    BuildContext context, {
    PaymentAccountModel? initialAccount,
  }) {
    return showDialog<PaymentAccountModel>(
      context: context,
      builder: (_) => AddPaymentAccountDialog(initialAccount: initialAccount),
    );
  }

  @override
  ConsumerState<AddPaymentAccountDialog> createState() => _AddPaymentAccountDialogState();
}

class _AddPaymentAccountDialogState extends ConsumerState<AddPaymentAccountDialog> {
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _holderController = TextEditingController();
  final _initialBalanceController = TextEditingController();
  String _selectedType = 'bank';

  static const List<Map<String, String>> _presets = [
    {'name': 'Bank BCA', 'type': 'bank'},
    {'name': 'Bank BRI', 'type': 'bank'},
    {'name': 'Bank Mandiri', 'type': 'bank'},
    {'name': 'Bank BNI', 'type': 'bank'},
    {'name': 'QRIS Toko', 'type': 'qris'},
    {'name': 'DANA', 'type': 'ewallet'},
    {'name': 'GoPay', 'type': 'ewallet'},
    {'name': 'Kas Laci', 'type': 'cash'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialAccount != null) {
      final acc = widget.initialAccount!;
      _nameController.text = acc.name;
      _numberController.text = acc.accountNumber ?? '';
      _holderController.text = acc.holderName ?? '';
      _initialBalanceController.text = acc.initialBalance > 0 ? CurrencyFormatter.formatNumber(acc.initialBalance) : '';
      _selectedType = acc.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _holderController.dispose();
    _initialBalanceController.dispose();
    super.dispose();
  }

  void _applyPreset(Map<String, String> p) {
    setState(() {
      _nameController.text = p['name']!;
      _selectedType = p['type']!;
      if (p['type'] == 'cash') {
        _numberController.clear();
        _holderController.text = 'Kasir Toko';
      }
    });
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      AppToast.showWarning(context, 'Nama bank atau e-wallet wajib diisi');
      return;
    }

    final store = ref.read(authProvider).currentStore;
    if (store == null) return;

    final number = _numberController.text.trim();
    final holder = _holderController.text.trim();
    final initialBal = double.tryParse(_initialBalanceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;

    if (widget.initialAccount != null) {
      final updated = widget.initialAccount!.copyWith(
        name: name,
        type: _selectedType,
        accountNumber: number.isEmpty ? null : number,
        holderName: holder.isEmpty ? null : holder,
        initialBalance: initialBal,
      );
      await ref.read(paymentAccountListProvider.notifier).updateAccount(updated);
      if (mounted) Navigator.of(context).pop(updated);
    } else {
      final created = await ref.read(paymentAccountListProvider.notifier).addAccount(
            store.id,
            name: name,
            type: _selectedType,
            accountNumber: number.isEmpty ? null : number,
            holderName: holder.isEmpty ? null : holder,
            initialBalance: initialBal,
          );
      if (mounted) Navigator.of(context).pop(created);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialAccount != null;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.account_balance_outlined, color: Color(0xFF2563EB), size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isEditing ? 'Ubah Akun Pembayaran' : 'Tambah Rekening / E-Wallet',
              style: AppTypography.headingSmall.copyWith(fontSize: 16),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildTypeChip('bank', 'Bank Transfer', Icons.account_balance_outlined),
                const SizedBox(width: 6),
                _buildTypeChip('ewallet', 'E-Wallet', Icons.wallet_outlined),
                const SizedBox(width: 6),
                _buildTypeChip('cash', 'Kas Tunai', Icons.payments_outlined),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 28,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _presets.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (context, i) {
                  final p = _presets[i];
                  return ActionChip(
                    label: Text(p['name']!, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600)),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _applyPreset(p),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Nama Akun / Bank *',
                hintText: 'Misal: Bank BCA, QRIS Toko, Kas Laci',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _numberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Nomor Rekening / No. HP',
                hintText: 'Misal: 8801234567 / 0812xxxx',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _holderController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Atas Nama (A.N.)',
                hintText: 'Misal: Toko Makmur / Kasir',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _initialBalanceController,
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyTextInputFormatter()],
              decoration: InputDecoration(
                labelText: 'Saldo Awal / Modal (Rp)',
                hintText: '0',
                prefixText: 'Rp ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
            isEditing ? 'Perbarui' : 'Simpan Akun',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeChip(String type, String label, IconData icon) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedType = type),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEFF6FF) : AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF2563EB) : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: isSelected ? const Color(0xFF2563EB) : AppColors.textSecondary),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF2563EB) : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
