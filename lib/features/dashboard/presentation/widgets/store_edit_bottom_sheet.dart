import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/services/native_contact_service.dart';
import 'package:tokona/core/services/native_location_service.dart';
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
  bool _isLocating = false;

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

  Future<void> _pickAddressFromGps() async {
    HapticFeedback.lightImpact();
    setState(() => _isLocating = true);
    try {
      final loc = await NativeLocationService.getCurrentLocationAddress();
      if (!mounted) return;
      if (loc != null) {
        final fullText = loc.formattedSummary.isNotEmpty ? loc.formattedSummary : loc.formattedAddress;
        setState(() => _addressController.text = fullText);
        final infoParts = <String>[];
        if (loc.village.isNotEmpty) infoParts.add(loc.village);
        if (loc.district.isNotEmpty) infoParts.add('Kec. ${loc.district}');
        if (loc.city.isNotEmpty) infoParts.add(loc.city);
        final locDesc = infoParts.isNotEmpty ? ' (${infoParts.join(', ')})' : '';
        AppToast.showSuccess(context, 'Alamat terisi dari GPS HP$locDesc');
      } else {
        AppToast.showInfo(context, 'Tidak dapat membaca alamat lokasi saat ini');
      }
    } catch (e) {
      if (mounted) AppToast.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLocating = false);
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(10)),
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
                decoration: _buildInputDecoration(hint: 'Toko Bangun Kerja Jaya', prefixIcon: Icons.store_rounded),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Nama toko wajib diisi' : null,
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
                decoration: _buildInputDecoration(hint: '081234567890', prefixIcon: Icons.phone_android_rounded),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFieldLabel('Alamat Lengkap Toko'),
                  InkWell(
                    onTap: _isLocating ? null : _pickAddressFromGps,
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        children: [
                          if (_isLocating)
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 1.8, color: AppColors.primary),
                            )
                          else
                            const Icon(Icons.my_location_rounded, size: 12.5, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            _isLocating ? 'Mencari GPS...' : 'Ambil Lokasi GPS HP',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
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
                  helper: 'Tips: Bisa tambahkan No. Toko/Ruko/Patokan di depan jalan',
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

  InputDecoration _buildInputDecoration({required String hint, required IconData prefixIcon, String? helper}) {
    return InputDecoration(
      hintText: hint,
      helperText: helper,
      helperStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
      prefixIcon: Icon(prefixIcon, size: 18, color: const Color(0xFF64748B)),
    );
  }
}
