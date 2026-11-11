import 'package:flutter/material.dart';
import 'package:tokona/core/services/whatsapp_service.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/widgets/app_toast.dart';

class WhatsAppPhoneInputDialog extends StatefulWidget {
  final String receiptText;

  const WhatsAppPhoneInputDialog({super.key, required this.receiptText});

  static Future<void> show(BuildContext context, {required String receiptText}) {
    return showDialog(
      context: context,
      builder: (_) => WhatsAppPhoneInputDialog(receiptText: receiptText),
    );
  }

  @override
  State<WhatsAppPhoneInputDialog> createState() => _WhatsAppPhoneInputDialogState();
}

class _WhatsAppPhoneInputDialogState extends State<WhatsAppPhoneInputDialog> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      AppToast.showWarning(context, 'Nomor HP tidak boleh kosong');
      return;
    }

    Navigator.of(context).pop();
    AppToast.showInfo(context, 'Membuka WhatsApp ke $phone...');

    final launched = await WhatsAppService.sendReceipt(
      phone: phone,
      message: widget.receiptText,
    );

    if (!launched && mounted) {
      AppToast.showWarning(context, 'Tidak dapat membuka WhatsApp. Teks disalin ke clipboard.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.send_to_mobile_rounded, color: Color(0xFF15803D), size: 20),
          ),
          const SizedBox(width: 10),
          const Text('Kirim ke WhatsApp', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Masukkan nomor WhatsApp pelanggan tujuan:',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Contoh: 081234567890',
              prefixIcon: Icon(Icons.phone_rounded, size: 20),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton.icon(
          onPressed: _handleSend,
          icon: const Icon(Icons.send_rounded, size: 16),
          label: const Text('Buka WA & Kirim', style: TextStyle(fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF15803D),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}

