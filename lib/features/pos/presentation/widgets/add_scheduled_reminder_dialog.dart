import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/customer/domain/models/customer_model.dart';
import 'package:tokona/features/customer/presentation/controllers/customer_controller.dart';
import 'package:tokona/features/pos/presentation/controllers/held_cart_controller.dart';
import 'package:tokona/features/pos/presentation/widgets/add_scheduled_reminder_fields.dart';

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

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.vibrate();
      return;
    }

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final notes = _notesController.text.trim();
    final amountText = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final totalAmount = double.tryParse(amountText) ?? 0.0;

    HapticFeedback.mediumImpact();
    ref.read(heldCartProvider.notifier).addManualReminder(
          customerName: name,
          customerPhone: phone,
          note: notes.isNotEmpty ? notes : null,
          totalAmount: totalAmount,
          deliveryMethod: _deliveryMethod,
          plannedDate: _selectedDate,
        );

    Navigator.of(context).pop(true);
    AppToast.showSuccess(context, 'Jadwal pengingat WA $name berhasil disimpan');
  }

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customerListProvider).customers;
    final dateStr = DateFormat('EEEE, d MMM yyyy • HH:mm', 'id_ID').format(_selectedDate);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.alarm_add_rounded, color: Color(0xFF059669), size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tambah Jadwal & Pengingat WA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                          Text('Set jam pengambilan & otomatis notifikasi WA', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AddScheduledReminderFields(
                  nameController: _nameController,
                  phoneController: _phoneController,
                  notesController: _notesController,
                  amountController: _amountController,
                  dateStr: dateStr,
                  deliveryMethod: _deliveryMethod,
                  customers: customers,
                  onPickDateTime: _pickDateTime,
                  onDeliveryMethodChanged: (val) => setState(() => _deliveryMethod = val),
                  onCustomerSelected: _onCustomerSelected,
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: _handleSubmit,
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 18, color: Colors.white),
                  label: const Text('Simpan Jadwal Pengingat', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
