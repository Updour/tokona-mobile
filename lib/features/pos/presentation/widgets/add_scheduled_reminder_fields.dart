import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/customer/domain/models/customer_model.dart';

class AddScheduledReminderFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController notesController;
  final TextEditingController amountController;
  final String dateStr;
  final String deliveryMethod;
  final List<CustomerModel> customers;
  final VoidCallback onPickDateTime;
  final ValueChanged<String> onDeliveryMethodChanged;
  final ValueChanged<CustomerModel> onCustomerSelected;

  const AddScheduledReminderFields({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.notesController,
    required this.amountController,
    required this.dateStr,
    required this.deliveryMethod,
    required this.customers,
    required this.onPickDateTime,
    required this.onDeliveryMethodChanged,
    required this.onCustomerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCustomerField(),
        const SizedBox(height: 12),
        _buildPhoneField(),
        const SizedBox(height: 12),
        _buildDateTimeField(),
        const SizedBox(height: 12),
        _buildDeliveryMethodSelector(),
        const SizedBox(height: 12),
        _buildAmountAndNoteFields(),
      ],
    );
  }

  Widget _buildCustomerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Nama Pelanggan *',
            hintText: 'Contoh: Bu Sri / Pak Anton',
            prefixIcon: const Icon(Icons.person_rounded, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama pelanggan wajib diisi' : null,
        ),
        if (customers.isNotEmpty) ...[
          const SizedBox(height: 6),
          SizedBox(
            height: 28,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: customers.take(6).length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, i) {
                final c = customers[i];
                return ActionChip(
                  label: Text(c.name, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600)),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  onPressed: () => onCustomerSelected(c),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: phoneController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: 'Nomor WhatsApp *',
        hintText: '08xxxxxxxxxx',
        prefixIcon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF059669), size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        helperText: 'Wajib diisi untuk pengiriman pesan pengingat WA',
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Nomor WhatsApp wajib diisi';
        final clean = v.replaceAll(RegExp(r'[^0-9]'), '');
        if (clean.length < 9) return 'Nomor minimal 9 digit (08...)';
        return null;
      },
    );
  }

  Widget _buildDateTimeField() {
    return InkWell(
      onTap: onPickDateTime,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          color: const Color(0xFFF8FAFC),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time_rounded, color: Color(0xFF0284C7), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Waktu Pengambilan / Notifikasi *', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text(dateStr, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ],
              ),
            ),
            const Icon(Icons.edit_calendar_rounded, size: 18, color: Color(0xFF0284C7)),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryMethodSelector() {
    return Row(
      children: [
        Expanded(
          child: ChoiceChip(
            label: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.storefront_rounded, size: 14),
                SizedBox(width: 6),
                Text('Diambil Sendiri', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
              ],
            ),
            selected: deliveryMethod == 'pickup',
            onSelected: (val) {
              if (val) onDeliveryMethodChanged('pickup');
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ChoiceChip(
            label: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.two_wheeler_rounded, size: 14),
                SizedBox(width: 6),
                Text('Dianterin', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
              ],
            ),
            selected: deliveryMethod == 'delivery',
            onSelected: (val) {
              if (val) onDeliveryMethodChanged('delivery');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAmountAndNoteFields() {
    return Column(
      children: [
        TextFormField(
          controller: notesController,
          decoration: InputDecoration(
            labelText: 'Catatan Pesanan',
            hintText: 'Contoh: 2 dus mie instan + 1 bal rokok',
            prefixIcon: const Icon(Icons.notes_rounded, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Perkiraan Total Bayar (Rp)',
            hintText: '0',
            prefixIcon: const Icon(Icons.payments_outlined, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}

