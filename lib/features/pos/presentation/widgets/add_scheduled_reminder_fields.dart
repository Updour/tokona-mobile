import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/customer/domain/models/customer_model.dart';
import 'package:tokona/features/pos/domain/models/cart_item_model.dart';
import 'package:tokona/features/pos/presentation/widgets/reminder_product_picker_section.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';

class AddScheduledReminderFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController notesController;
  final TextEditingController amountController;
  final String dateStr;
  final String deliveryMethod;
  final List<CustomerModel> customers;
  final List<ProductModel> products;
  final List<CartItemModel> selectedItems;
  final VoidCallback onPickDateTime;
  final VoidCallback onPickCustomerSheet;
  final VoidCallback onImportContact;
  final ValueChanged<String> onDeliveryMethodChanged;
  final ValueChanged<CustomerModel> onCustomerSelected;
  final ValueChanged<List<CartItemModel>> onItemsChanged;

  const AddScheduledReminderFields({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.notesController,
    required this.amountController,
    required this.dateStr,
    required this.deliveryMethod,
    required this.customers,
    required this.products,
    required this.selectedItems,
    required this.onPickDateTime,
    required this.onPickCustomerSheet,
    required this.onImportContact,
    required this.onDeliveryMethodChanged,
    required this.onCustomerSelected,
    required this.onItemsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildQuickSourceRow(),
        const SizedBox(height: 10),
        _buildCustomerField(),
        const SizedBox(height: 12),
        _buildPhoneField(),
        const SizedBox(height: 12),
        _buildDateTimeField(),
        const SizedBox(height: 12),
        _buildDeliveryMethodSelector(),
        const SizedBox(height: 12),
        ReminderProductPickerSection(
          products: products,
          selectedItems: selectedItems,
          onItemsChanged: onItemsChanged,
        ),
        const SizedBox(height: 12),
        _buildAmountAndNoteFields(),
      ],
    );
  }

  Widget _buildQuickSourceRow() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPickCustomerSheet,
            icon: const Icon(Icons.people_alt_rounded, size: 15, color: AppColors.primary),
            label: const Text('Data Pelanggan', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 9),
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
              backgroundColor: AppColors.primary.withValues(alpha: 0.04),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onImportContact,
            icon: const Icon(Icons.contact_phone_rounded, size: 15, color: Color(0xFF059669)),
            label: const Text('Kontak', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF047857))),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 9),
              side: const BorderSide(color: Color(0xFF6EE7B7)),
              backgroundColor: const Color(0xFFECFDF5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
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
        labelText: 'Nomor Handphone *',
        hintText: '08xxxxxxxxxx',
        prefixIcon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF059669), size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        helperText: 'Wajib diisi untuk pengiriman pesan pengingat',
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Nomor Handphone wajib diisi';
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
          maxLines: 2,
          decoration: InputDecoration(
            labelText: 'Catatan Pesanan (Otomatis dari Produk)',
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
          inputFormatters: [CurrencyTextInputFormatter()],
          decoration: InputDecoration(
            labelText: 'Perkiraan Total Bayar (Rp)',
            prefixText: 'Rp ',
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

