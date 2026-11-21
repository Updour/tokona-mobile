import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/services/native_contact_service.dart';
import 'package:tokona/core/services/whatsapp_service.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/pos/domain/models/wa_message_log.dart';
import 'package:tokona/features/pos/presentation/controllers/wa_history_controller.dart';
import 'package:tokona/features/pos/presentation/widgets/wa_dynamic_order_calc_card.dart';
import 'package:tokona/features/settings/presentation/controllers/app_preferences_controller.dart';

class ReminderMessageDialog extends ConsumerStatefulWidget {
  final String title;
  final String recipientName;
  final String? initialPhone;
  final String initialMessage;
  final bool showOrderCalculatorByDefault;
  final String? category;
  final String? referenceId;

  const ReminderMessageDialog({
    super.key,
    required this.title,
    required this.recipientName,
    this.initialPhone,
    required this.initialMessage,
    this.showOrderCalculatorByDefault = false,
    this.category,
    this.referenceId,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String recipientName,
    String? initialPhone,
    required String initialMessage,
    bool showOrderCalculatorByDefault = false,
    String? category,
    String? referenceId,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ReminderMessageDialog(
        title: title,
        recipientName: recipientName,
        initialPhone: initialPhone,
        initialMessage: initialMessage,
        showOrderCalculatorByDefault: showOrderCalculatorByDefault,
        category: category,
        referenceId: referenceId,
      ),
    );
  }

  @override
  ConsumerState<ReminderMessageDialog> createState() => _ReminderMessageDialogState();
}

class _ReminderMessageDialogState extends ConsumerState<ReminderMessageDialog> {
  late final TextEditingController _phoneController;
  late final TextEditingController _messageController;
  late bool _showOrderCalc;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialPhone ?? '');
    _messageController = TextEditingController(text: widget.initialMessage);
    _showOrderCalc = widget.showOrderCalculatorByDefault;
  }

  Future<void> _pickContactPhone() async {
    final picked = await NativeContactService.pickContact();
    if (picked != null && mounted && picked.phone.isNotEmpty) {
      setState(() => _phoneController.text = picked.phone);
      AppToast.showSuccess(context, 'Nomor ${picked.name} dipilih');
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final phone = _phoneController.text.trim();
    final message = _messageController.text.trim();

    if (phone.isEmpty) {
      AppToast.showError(context, 'Nomor Handphone wajib diisi');
      return;
    }
    if (message.isEmpty) {
      AppToast.showError(context, 'Pesan tidak boleh kosong');
      return;
    }

    setState(() => _isSending = true);
    HapticFeedback.lightImpact();

    try {
      final success = await WhatsAppService.sendReceipt(phone: phone, message: message);
      final now = DateTime.now();
      final cat = widget.category ?? (widget.title.toLowerCase().contains('kasbon') || widget.title.toLowerCase().contains('tagihan') ? 'kasbon' : (_showOrderCalc ? 'order' : 'manual'));
      ref.read(waHistoryProvider.notifier).recordLog(WaMessageLog(
            id: 'wa_${now.millisecondsSinceEpoch}',
            recipientName: widget.recipientName,
            phone: phone,
            category: cat,
            message: message,
            status: success ? 'sent' : 'failed',
            errorReason: success ? null : 'Gagal membuka aplikasi WhatsApp',
            referenceId: widget.referenceId,
            createdAt: now,
            sentAt: success ? now : null,
          ));
      if (!mounted) return;
      if (success) {
        Navigator.of(context).pop(true);
        AppToast.showSuccess(context, 'Membuka WhatsApp ke $phone');
      } else {
        AppToast.showError(context, 'Gagal membuka WhatsApp. Pastikan aplikasi terinstal.');
      }
    } catch (e) {
      if (mounted) AppToast.showError(context, 'Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFF25D366).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.chat_rounded, color: Color(0xFF059669), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title, style: AppTypography.headingSmall.copyWith(fontSize: 15, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('Kirim ke ${widget.recipientName}', style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Nomor Handphone',
                  hintText: 'Contoh: 08123456789 atau 628123456789',
                  prefixIcon: const Icon(Icons.phone_rounded, size: 18, color: Color(0xFF059669)),
                  suffixIcon: IconButton(
                    onPressed: _pickContactPhone,
                    tooltip: 'Ambil dari Kontak',
                    icon: const Icon(Icons.contact_phone_rounded, size: 19, color: AppColors.primary),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () => setState(() => _showOrderCalc = !_showOrderCalc),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _showOrderCalc ? const Color(0xFFDCFCE7) : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _showOrderCalc ? const Color(0xFF22C55E) : AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _showOrderCalc ? Icons.keyboard_arrow_up_rounded : Icons.calculate_rounded,
                          size: 15,
                          color: const Color(0xFF047857),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _showOrderCalc ? 'Tutup Kalkulator Beli' : '+ Total Beli (Qty × Harga)',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF047857)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_showOrderCalc) ...[
                const SizedBox(height: 10),
                WaDynamicOrderCalcCard(
                  recipientName: widget.recipientName,
                  storeName: ref.watch(authProvider).currentStore?.name ?? 'Toko',
                  template: ref.watch(appPreferencesProvider).waOrderTemplate,
                  onApplyMessage: (msg) {
                    setState(() => _messageController.text = msg);
                    AppToast.showSuccess(context, 'Pesan WA diperbarui sesuai jumlah & total beli');
                  },
                ),
              ],
              const SizedBox(height: 10),
              TextField(
                controller: _messageController,
                maxLines: 7,
                style: const TextStyle(fontSize: 13, height: 1.4),
                decoration: InputDecoration(
                  labelText: 'Isi Pesan WhatsApp',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isSending ? null : _handleSend,
                      icon: _isSending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send_rounded, size: 17, color: Colors.white),
                      label: Text(
                        _isSending ? 'Membuka WhatsApp...' : 'Kirim via WhatsApp',
                        style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

