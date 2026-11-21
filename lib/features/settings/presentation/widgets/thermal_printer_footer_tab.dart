import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';

class ThermalPrinterFooterTab extends StatelessWidget {
  final TextEditingController footerController;
  final TextEditingController policyController;
  final TextEditingController socialController;
  final bool monospaceWhatsApp;
  final ValueChanged<bool> onMonospaceWhatsAppChanged;
  final VoidCallback onChanged;

  const ThermalPrinterFooterTab({
    super.key,
    required this.footerController,
    required this.policyController,
    required this.socialController,
    required this.monospaceWhatsApp,
    required this.onMonospaceWhatsAppChanged,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        TextField(
          controller: footerController,
          decoration: const InputDecoration(
            labelText: 'Pesan Terima Kasih Utama *',
            hintText: 'Contoh: Terima kasih atas kunjungan Anda!',
            prefixIcon: Icon(Icons.favorite_outline_rounded, size: 20),
          ),
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: policyController,
          decoration: const InputDecoration(
            labelText: 'Kebijakan Toko / Garansi (Opsional)',
            hintText: 'Contoh: Barang yang dibeli tidak dapat ditukar',
            prefixIcon: Icon(Icons.verified_user_outlined, size: 20),
          ),
          maxLines: 2,
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: socialController,
          decoration: const InputDecoration(
            labelText: 'Media Sosial / Website Toko (Opsional)',
            hintText: 'Contoh: IG: @tokona.id • WA: 0812-xxx',
            prefixIcon: Icon(Icons.language_rounded, size: 20),
          ),
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: monospaceWhatsApp,
          title: const Text('Struk Monospace di WhatsApp', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
          subtitle: const Text('Membungkus struk WhatsApp dalam font monospace terstruktur agar tampak seperti cetak struk asli', style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
          activeColor: AppColors.primary,
          onChanged: onMonospaceWhatsAppChanged,
        ),
      ],
    );
  }
}
