import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/services/native_contact_service.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/customer/domain/dtos/create_customer_dto.dart';
import 'package:tokona/features/customer/domain/models/customer_model.dart';
import 'package:tokona/features/customer/presentation/controllers/customer_controller.dart';
import 'package:tokona/features/customer/presentation/widgets/customer_picker_sheet.dart';
import 'package:tokona/features/pos/data/services/whatsapp_reminder_service.dart';
import 'package:tokona/features/pos/domain/models/cart_item_model.dart';
import 'package:tokona/features/pos/presentation/controllers/held_cart_controller.dart';
import 'package:tokona/features/pos/presentation/widgets/add_scheduled_reminder_fields.dart';
import 'package:tokona/features/product/presentation/controllers/product_controller.dart';

class AddScheduledReminderDialog extends ConsumerStatefulWidget {
  const AddScheduledReminderDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => const AddScheduledReminderDialog(),
    );
  }

  @override
  ConsumerState<AddScheduledReminderDialog> createState() => _AddScheduledReminderDialogState();
}

class _AddScheduledReminderDialogState extends ConsumerState<AddScheduledReminderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 3));
  String _deliveryMethod = 'pickup';
  List<CartItemModel> _selectedItems = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storeId = ref.read(authProvider).currentStore?.id;
      if (storeId != null) {
        if (ref.read(customerListProvider).customers.isEmpty) {
          ref.read(customerListProvider.notifier).loadCustomers(storeId);
        }
        if (ref.read(productListProvider).products.isEmpty) {
          ref.read(productListProvider.notifier).loadProducts(storeId);
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 90)),
      helpText: 'Pilih Tanggal Pengambilan',
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
      helpText: 'Pilih Jam Pengambilan',
    );

    setState(() {
      _selectedDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime?.hour ?? _selectedDate.hour,
        pickedTime?.minute ?? _selectedDate.minute,
      );
    });
  }

  void _onCustomerSelected(CustomerModel customer) {
    setState(() {
      _nameController.text = customer.name;
      if (customer.phone != null && customer.phone!.isNotEmpty) {
        _phoneController.text = customer.phone!;
      }
    });
  }

  Future<void> _pickFromCustomers() async {
    await CustomerPickerSheet.show(
      context,
      onCustomerSelected: (c) {
        if (c != null) _onCustomerSelected(c);
      },
    );
  }

  Future<void> _importFromPhoneContacts() async {
    final picked = await NativeContactService.pickContact();
    if (picked == null || !mounted) return;
    setState(() {
      if (picked.name.isNotEmpty) _nameController.text = picked.name;
      if (picked.phone.isNotEmpty) _phoneController.text = picked.phone;
    });
    // Otomatis simpan ke Data Pelanggan jika belum terdaftar
    final storeId = ref.read(authProvider).currentStore?.id;
    if (storeId != null) {
      final existing = ref.read(customerListProvider).customers;
      final isDup = existing.any((c) =>
          (picked.phone.isNotEmpty && c.phone?.trim() == picked.phone) ||
          c.name.trim().toLowerCase() == picked.name.trim().toLowerCase());
      if (!isDup) {
        await ref.read(customerListProvider.notifier).createCustomer(
              storeId,
              CreateCustomerDto(name: picked.name, phone: picked.phone.isEmpty ? null : picked.phone),
            );
      }
    }
    if (mounted) AppToast.showSuccess(context, 'Kontak "${picked.name}" dipilih');
  }

  void _onItemsChanged(List<CartItemModel> items) {
    final total = items.fold<double>(0.0, (acc, it) => acc + it.subtotal);
    final summary = items.map((it) {
      final q = it.quantity == it.quantity.roundToDouble() ? it.quantity.toInt().toString() : it.quantity.toString();
      return '${it.product.name} ($q ${it.unitName})';
    }).join(', ');
    setState(() {
      _selectedItems = items;
      _notesController.text = summary;
      _amountController.text = total > 0 ? CurrencyFormatter.formatNumber(total) : '';
    });
  }

  Future<void> _handleSubmit({bool sendNow = false}) async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.vibrate();
      return;
    }

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final notes = _notesController.text.trim();
    final totalAmount = CurrencyFormatter.parse(_amountController.text);

    HapticFeedback.mediumImpact();
    final created = ref.read(heldCartProvider.notifier).addManualReminder(
          customerName: name,
          customerPhone: phone,
          note: notes.isNotEmpty ? notes : null,
          totalAmount: totalAmount,
          deliveryMethod: _deliveryMethod,
          plannedDate: _selectedDate,
          items: _selectedItems,
        );

    if (sendNow) {
      final storeName = ref.read(authProvider).currentStore?.name ?? 'Tokona Store';
      final ok = await WhatsAppReminderService.sendReminder(ref: ref, order: created, storeName: storeName);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      if (ok) {
        AppToast.showSuccess(context, 'Jadwal disimpan & membuka WhatsApp ke $name');
      } else {
        AppToast.showWarning(context, 'Jadwal tersimpan, namun gagal membuka WhatsApp');
      }
      return;
    }

    Navigator.of(context).pop(true);
    AppToast.showSuccess(context, 'Jadwal pengingat $name berhasil disimpan');
  }

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customerListProvider).customers;
    final products = ref.watch(productListProvider).products;
    final dateStr = DateFormat('EEEE, d MMM yyyy • HH:mm', 'id_ID').format(_selectedDate);

    return Container(
      decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.of(context).viewInsets.bottom + 16),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              children: [
                Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.alarm_add_rounded, color: Color(0xFF059669), size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tambah Jadwal & Pengingat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                          Text('Pilih pelanggan, produk & langsung kirim WA', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                AddScheduledReminderFields(
                  nameController: _nameController,
                  phoneController: _phoneController,
                  notesController: _notesController,
                  amountController: _amountController,
                  dateStr: dateStr,
                  deliveryMethod: _deliveryMethod,
                  customers: customers,
                  products: products,
                  selectedItems: _selectedItems,
                  onPickDateTime: _pickDateTime,
                  onPickCustomerSheet: _pickFromCustomers,
                  onImportContact: _importFromPhoneContacts,
                  onDeliveryMethodChanged: (val) => setState(() => _deliveryMethod = val),
                  onCustomerSelected: _onCustomerSelected,
                  onItemsChanged: _onItemsChanged,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _handleSubmit(sendNow: false),
                        icon: const Icon(Icons.alarm_on_rounded, size: 17, color: AppColors.primary),
                        label: const Text('Simpan Jadwal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _handleSubmit(sendNow: true),
                        icon: const Icon(Icons.send_rounded, size: 16, color: Colors.white),
                        label: const Text('Simpan & Kirim WA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
