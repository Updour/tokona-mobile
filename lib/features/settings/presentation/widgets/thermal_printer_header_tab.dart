import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';

class ThermalPrinterHeaderTab extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController subtitleController;
  final bool showAddress;
  final TextEditingController addressController;
  final bool showPhone;
  final TextEditingController phoneController;
  final TextEditingController customHeaderController;
  final bool showInvoiceNumber;
  final bool showDateTime;
  final bool showCashier;
  final bool showCustomer;
  final ValueChanged<bool> onShowAddressChanged;
  final ValueChanged<bool> onShowPhoneChanged;
  final ValueChanged<bool> onShowInvoiceNumberChanged;
  final ValueChanged<bool> onShowDateTimeChanged;
  final ValueChanged<bool> onShowCashierChanged;
  final ValueChanged<bool> onShowCustomerChanged;
  final VoidCallback onChanged;

  const ThermalPrinterHeaderTab({
    super.key,
    required this.titleController,
    required this.subtitleController,
    required this.showAddress,
    required this.addressController,
    required this.showPhone,
    required this.phoneController,
    required this.customHeaderController,
    required this.showInvoiceNumber,
    required this.showDateTime,
    required this.showCashier,
    required this.showCustomer,
    required this.onShowAddressChanged,
    required this.onShowPhoneChanged,
    required this.onShowInvoiceNumberChanged,
    required this.onShowDateTimeChanged,
    required this.onShowCashierChanged,
    required this.onShowCustomerChanged,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Judul / Nama Toko di Struk *',
            hintText: 'Nama toko Anda (Huruf Besar)',
            prefixIcon: Icon(Icons.storefront_outlined, size: 20),
          ),
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: subtitleController,
          decoration: const InputDecoration(
            labelText: 'Slogan / Sub-header Toko (Opsional)',
            hintText: 'Contoh: Pusat Grosir & Retail Sembako',
            prefixIcon: Icon(Icons.subtitles_outlined, size: 20),
          ),
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Checkbox(
              value: showAddress,
              activeColor: AppColors.primary,
              onChanged: (val) => onShowAddressChanged(val ?? true),
            ),
            const Text('Tampilkan Alamat Toko', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        if (showAddress) ...[
          TextField(
            controller: addressController,
            decoration: const InputDecoration(
              labelText: 'Alamat Toko di Struk',
              hintText: 'Jl. Pemuda No. 12, Kota',
              prefixIcon: Icon(Icons.location_on_outlined, size: 20),
            ),
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 10),
        ],
        Row(
          children: [
            Checkbox(
              value: showPhone,
              activeColor: AppColors.primary,
              onChanged: (val) => onShowPhoneChanged(val ?? true),
            ),
            const Text('Tampilkan Telepon / WhatsApp Toko', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        if (showPhone) ...[
          TextField(
            controller: phoneController,
            decoration: const InputDecoration(
              labelText: 'Nomor Telepon / WhatsApp Struk',
              hintText: '0812-3456-7890',
              prefixIcon: Icon(Icons.phone_outlined, size: 20),
            ),
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 10),
        ],
        TextField(
          controller: customHeaderController,
          decoration: const InputDecoration(
            labelText: 'Catatan Pembuka / Banner (Opsional)',
            hintText: 'Contoh: Selamat Datang & Selamat Berbelanja!',
            prefixIcon: Icon(Icons.info_outline_rounded, size: 20),
          ),
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 12),
        const Text('Elemen Metadata Struk', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            FilterChip(
              label: const Text('No. Nota'),
              selected: showInvoiceNumber,
              onSelected: onShowInvoiceNumberChanged,
            ),
            FilterChip(
              label: const Text('Tanggal & Jam'),
              selected: showDateTime,
              onSelected: onShowDateTimeChanged,
            ),
            FilterChip(
              label: const Text('Nama Kasir'),
              selected: showCashier,
              onSelected: onShowCashierChanged,
            ),
            FilterChip(
              label: const Text('Nama & No. HP Pelanggan'),
              selected: showCustomer,
              onSelected: onShowCustomerChanged,
            ),
          ],
        ),
      ],
    );
  }
}
