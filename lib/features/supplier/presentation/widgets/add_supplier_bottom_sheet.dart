import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:tokona/features/supplier/domain/dtos/create_supplier_dto.dart';
import 'package:tokona/features/supplier/domain/dtos/update_supplier_dto.dart';
import 'package:tokona/features/supplier/domain/models/supplier_model.dart';
import 'package:tokona/features/supplier/presentation/widgets/supplier_type_selector.dart';

class AddSupplierBottomSheet extends StatefulWidget {
  final SupplierModel? supplierToEdit;
  final Future<bool> Function(CreateSupplierDto dto)? onCreate;
  final Future<bool> Function(UpdateSupplierDto dto)? onUpdate;

  const AddSupplierBottomSheet({
    super.key,
    this.supplierToEdit,
    this.onCreate,
    this.onUpdate,
  });

  static Future<void> show(
    BuildContext context, {
    SupplierModel? supplierToEdit,
    Future<bool> Function(CreateSupplierDto dto)? onCreate,
    Future<bool> Function(UpdateSupplierDto dto)? onUpdate,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddSupplierBottomSheet(
        supplierToEdit: supplierToEdit,
        onCreate: onCreate,
        onUpdate: onUpdate,
      ),
    );
  }

  @override
  State<AddSupplierBottomSheet> createState() => _AddSupplierBottomSheetState();
}

class _AddSupplierBottomSheetState extends State<AddSupplierBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  String _type = 'offline';
  String? _platform = 'Shopee';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final s = widget.supplierToEdit;
    if (s != null) {
      _nameController.text = s.name;
      _type = s.type;
      _platform = s.platform ?? 'Shopee';
      _contactController.text = s.contactName ?? '';
      _phoneController.text = s.phone ?? '';
      _addressController.text = s.address ?? '';
      _notesController.text = s.notes ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    bool success = false;
    if (widget.supplierToEdit != null && widget.onUpdate != null) {
      final dto = UpdateSupplierDto(
        name: _nameController.text.trim(),
        type: _type,
        platform: _type == 'online' ? _platform : null,
        contactName: _contactController.text.trim().isEmpty ? null : _contactController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );
      success = await widget.onUpdate!(dto);
    } else if (widget.onCreate != null) {
      final dto = CreateSupplierDto(
        name: _nameController.text.trim(),
        type: _type,
        platform: _type == 'online' ? _platform : null,
        contactName: _contactController.text.trim().isEmpty ? null : _contactController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );
      success = await widget.onCreate!(dto);
    }

    final isEdit = widget.supplierToEdit != null;
    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        AppToast.showSuccess(context, isEdit ? 'Data supplier berhasil diperbarui' : 'Data supplier berhasil disimpan');
        await Future.delayed(const Duration(milliseconds: 650));
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        AppToast.showError(context, 'Gagal menyimpan supplier');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.supplierToEdit != null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isEdit ? 'Edit Data Supplier' : 'Tambah Supplier Baru', style: AppTypography.headingSmall.copyWith(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text('Pemasok offline (distributor resmi) atau online (Shopee/TikTok)', style: AppTypography.bodySmall.copyWith(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SupplierTypeSelector(
                selectedType: _type,
                selectedPlatform: _platform,
                onTypeChanged: (type) => setState(() => _type = type),
                onPlatformChanged: (p) => setState(() => _platform = p),
              ),
              const SizedBox(height: 14),
              AuthTextField(
                controller: _nameController,
                label: _type == 'online' ? 'Nama Toko Online' : 'Nama Distributor / Toko',
                hint: _type == 'online' ? 'Grosir Sembako Murah' : 'PT Indomarco / Toko Beras Jaya',
                isRequired: true,
                prefixIcon: Icons.storefront_outlined,
                validator: (val) => val == null || val.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _contactController,
                label: _type == 'online' ? 'Nama Admin / Akun' : 'Nama Sales / Kontak',
                hint: 'Budi (Sales Indofood)',
                prefixIcon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _phoneController,
                label: 'Nomor WhatsApp / HP',
                hint: '081234567890',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _addressController,
                label: _type == 'online' ? 'Link Toko / Profil' : 'Alamat Gudang / Kantor',
                hint: _type == 'online' ? 'https://shopee.co.id/...' : 'Jl. Pasar Besar No. 12',
                prefixIcon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _notesController,
                label: 'Catatan Khusus (Opsi)',
                hint: 'No. Rekening BCA / Ketentuan retur',
                prefixIcon: Icons.notes_outlined,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(isEdit ? 'SIMPAN PERUBAHAN' : 'TAMBAH SUPPLIER', style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
