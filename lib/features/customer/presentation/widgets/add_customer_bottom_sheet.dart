import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/customer/domain/dtos/create_customer_dto.dart';
import 'package:tokona/features/customer/domain/dtos/update_customer_dto.dart';
import 'package:tokona/features/customer/domain/models/customer_model.dart';
import 'package:tokona/features/customer/presentation/widgets/customer_type_selector.dart';

class AddCustomerBottomSheet extends StatefulWidget {
  final CustomerModel? customerToEdit;
  final Future<CustomerModel?> Function(CreateCustomerDto dto)? onCreate;
  final Future<bool> Function(UpdateCustomerDto dto)? onUpdate;

  const AddCustomerBottomSheet({
    super.key,
    this.customerToEdit,
    this.onCreate,
    this.onUpdate,
  });

  static Future<CustomerModel?> show(
    BuildContext context, {
    CustomerModel? customerToEdit,
    Future<CustomerModel?> Function(CreateCustomerDto dto)? onCreate,
    Future<bool> Function(UpdateCustomerDto dto)? onUpdate,
  }) {
    return showModalBottomSheet<CustomerModel?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddCustomerBottomSheet(
        customerToEdit: customerToEdit,
        onCreate: onCreate,
        onUpdate: onUpdate,
      ),
    );
  }

  @override
  State<AddCustomerBottomSheet> createState() => _AddCustomerBottomSheetState();
}

class _AddCustomerBottomSheetState extends State<AddCustomerBottomSheet> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _receivableController = TextEditingController();

  String _customerType = 'umum';
  bool _isSubmitting = false;

  bool get _isEdit => widget.customerToEdit != null;
  bool get _isFormValid => _nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onFieldChanged);
    if (_isEdit) {
      final c = widget.customerToEdit!;
      _nameController.text = c.name;
      _phoneController.text = c.phone ?? '';
      _addressController.text = c.address ?? '';
      _notesController.text = c.notes ?? '';
      _customerType = c.customerType;
      if (c.receivableBalance > 0) {
        _receivableController.text = CurrencyFormatter.formatNumber(c.receivableBalance);
      }
    }
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFieldChanged);
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _receivableController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      AppToast.showWarning(context, 'Nama pelanggan wajib diisi');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (_isEdit) {
        final dto = UpdateCustomerDto(
          name: name,
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
          customerType: _customerType,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          receivableBalance: CurrencyFormatter.parse(_receivableController.text),
        );
        final ok = await widget.onUpdate?.call(dto) ?? false;
        if (mounted && ok) {
          AppToast.showSuccess(context, 'Data pelanggan berhasil diperbarui');
          Navigator.of(context).pop();
        }
      } else {
        final dto = CreateCustomerDto(
          name: name,
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
          customerType: _customerType,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          initialReceivableBalance: CurrencyFormatter.parse(_receivableController.text),
        );
        final created = await widget.onCreate?.call(dto);
        if (mounted && created != null) {
          AppToast.showSuccess(context, 'Pelanggan berhasil ditambahkan');
          Navigator.of(context).pop(created);
        }
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.90),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEdit ? 'Ubah Data Pelanggan' : 'Tambah Pelanggan Baru',
                          style: AppTypography.headingSmall.copyWith(fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Data langganan warung, member, dan grosir',
                          style: AppTypography.bodySmall.copyWith(fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 22, color: AppColors.textMuted),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Kategori Pelanggan', style: AppTypography.labelMedium),
              const SizedBox(height: 8),
              CustomerTypeSelector(
                selectedType: _customerType,
                onTypeSelected: (type) => setState(() => _customerType = type),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Nama Pelanggan *',
                  hintText: 'Contoh: Bu Siti, Toko Sejahtera',
                  prefixIcon: const Icon(Icons.person_rounded, size: 20),
                  helperText: _nameController.text.trim().isEmpty ? 'Nama wajib diisi' : null,
                  helperStyle: TextStyle(
                    fontSize: 11,
                    color: _nameController.text.trim().isEmpty ? AppColors.error : AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Nomor WhatsApp / HP (Opsional)',
                  hintText: '0812xxxxxxx',
                  prefixIcon: Icon(Icons.phone_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _addressController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Alamat / RT / Lokasi (Opsional)',
                  hintText: 'Contoh: RT 03/04 No. 12',
                  prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _receivableController,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyTextInputFormatter()],
                decoration: InputDecoration(
                  labelText: _isEdit ? 'Saldo Kasbon (Piutang)' : 'Saldo Kasbon Awal (Jika Ada)',
                  prefixText: 'Rp ',
                  hintText: '0',
                  prefixIcon: const Icon(Icons.account_balance_wallet_outlined, size: 20),
                  helperText: 'Catatan hutang belanja pelanggan yang belum lunas',
                  helperStyle: AppTypography.bodySmall.copyWith(fontSize: 10.5),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Catatan Khusus (Opsional)',
                  hintText: 'Contoh: Langganan beras, bayar tiap akhir bulan',
                  prefixIcon: Icon(Icons.edit_note_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isFormValid && !_isSubmitting ? _handleSubmit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFormValid ? AppColors.primary : AppColors.surfaceElevated,
                  foregroundColor: _isFormValid ? Colors.white : AppColors.textMuted,
                  disabledBackgroundColor: const Color(0xFFE2E8F0),
                  disabledForegroundColor: const Color(0xFF94A3B8),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                      )
                    : Text(
                        _isEdit ? 'Simpan Perubahan' : 'Daftarkan Pelanggan',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
