import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/services/native_contact_service.dart';
import 'package:tokona/core/services/whatsapp_service.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/domain/models/store_model.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';

class StoreEditBottomSheet extends ConsumerStatefulWidget {
  final StoreModel? store;

  const StoreEditBottomSheet({super.key, required this.store});

  static Future<void> show(BuildContext context, {StoreModel? store}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StoreEditBottomSheet(store: store),
    );
  }

  @override
  ConsumerState<StoreEditBottomSheet> createState() => _StoreEditBottomSheetState();
}

class _StoreEditBottomSheetState extends ConsumerState<StoreEditBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.store?.name ?? '');
    _addressController = TextEditingController(text: widget.store?.address ?? '');
    _phoneController = TextEditingController(text: widget.store?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickFromPhone() async {
    HapticFeedback.lightImpact();
    final contact = await NativeContactService.pickContact();
    if (contact == null) return;

    if (contact.phone.isNotEmpty) {
      _phoneController.text = contact.phone;
    }
    if (contact.address != null && contact.address!.isNotEmpty) {
      _addressController.text = contact.address!;
      if (mounted) AppToast.showSuccess(context, 'Alamat & No. HP terisi dari kontak');
    } else {
      if (mounted) AppToast.showSuccess(context, 'No. HP terisi: ${contact.phone}');
    }
  }

  Future<void> _pickAddressOnly() async {
    HapticFeedback.lightImpact();
    final address = await NativeContactService.pickAddress();
    if (address != null && address.isNotEmpty) {
      setState(() => _addressController.text = address);
      if (mounted) AppToast.showSuccess(context, 'Alamat terisi dari kontak HP');
    } else {
      final contact = await NativeContactService.pickContact();
      if (contact != null && contact.address != null && contact.address!.isNotEmpty) {
        setState(() => _addressController.text = contact.address!);
        if (mounted) AppToast.showSuccess(context, 'Alamat berhasil diambil');
      } else {
        if (mounted) AppToast.showInfo(context, 'Pilih kontak yang menyimpan alamat pos atau tulis manual');
      }
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.store == null) return;

    setState(() => _isSaving = true);
    final rawPhone = _phoneController.text.trim();
    final cleanPhone = rawPhone.isNotEmpty ? WhatsAppService.sanitizePhoneNumber(rawPhone) : '';
    final updatedStore = widget.store!.copyWith(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      phone: cleanPhone,
    );

    final success = await ref.read(authProvider.notifier).updateStore(updatedStore);
    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        AppToast.showSuccess(context, 'Data outlet dan toko berhasil disimpan');
        Navigator.of(context).pop();
      } else {
        AppToast.showError(context, 'Gagal menyimpan perubahan toko');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottomInset),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.storefront_rounded, color: AppColors.primaryDark, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pengaturan Outlet & Toko', style: AppTypography.headingSmall.copyWith(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text('Kelola nama, alamat, dan kontak outlet', style: AppTypography.bodySmall.copyWith(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
              const Divider(height: 20),
              _buildFieldLabel('Nama Toko*'),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: _buildInputDecoration(
                  hint: 'Toko Bangun Kerja Jaya',
                  prefixIcon: Icons.store_rounded,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Nama toko wajib diisi';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFieldLabel('Nomor Handphone (WhatsApp)'),
                  InkWell(
                    onTap: _pickFromPhone,
                    borderRadius: BorderRadius.circular(6),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        children: [
                          Icon(Icons.contacts_rounded, size: 12.5, color: AppColors.primary),
                          SizedBox(width: 3.5),
                          Text('Ambil Kontak HP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _buildInputDecoration(
                  hint: '081234567890',
                  prefixIcon: Icons.phone_android_rounded,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFieldLabel('Alamat Lengkap Toko'),
                  InkWell(
                    onTap: _pickAddressOnly,
                    borderRadius: BorderRadius.circular(6),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        children: [
                          Icon(Icons.location_searching_rounded, size: 12.5, color: AppColors.primary),
                          SizedBox(width: 3.5),
                          Text('Ambil Alamat di HP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: _buildInputDecoration(
                  hint: 'Alamat toko, jalan, kelurahan, kota untuk dicetak pada nota',
                  prefixIcon: Icons.location_on_outlined,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _handleSave,
                  icon: _isSaving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save_rounded, size: 18),
                  label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Perubahan', style: const TextStyle(fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: AppColors.textPrimary)),
    );
  }

  InputDecoration _buildInputDecoration({required String hint, required IconData prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
      prefixIcon: Icon(prefixIcon, size: 18, color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.surfaceElevated,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
    );
  }
}
