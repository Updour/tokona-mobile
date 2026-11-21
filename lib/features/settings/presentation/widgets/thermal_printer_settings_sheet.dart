import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/pos/presentation/utils/receipt_thermal_formatter.dart';
import 'package:tokona/features/settings/domain/models/app_preferences.dart';
import 'package:tokona/features/settings/presentation/controllers/app_preferences_controller.dart';
import 'package:tokona/features/settings/presentation/widgets/thermal_printer_footer_tab.dart';
import 'package:tokona/features/settings/presentation/widgets/thermal_printer_header_tab.dart';
import 'package:tokona/features/settings/presentation/widgets/thermal_printer_paper_tab.dart';
import 'package:tokona/features/settings/presentation/widgets/thermal_printer_preview_tab.dart';
import 'package:tokona/features/settings/presentation/widgets/thermal_printer_segmented_nav.dart';
import 'package:tokona/features/settings/presentation/widgets/thermal_printer_test_dialog.dart';

class ThermalPrinterSettingsSheet extends ConsumerStatefulWidget {
  const ThermalPrinterSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context, isScrollControlled: true, useRootNavigator: true,
      backgroundColor: Colors.transparent, builder: (_) => const ThermalPrinterSettingsSheet(),
    );
  }

  @override
  ConsumerState<ThermalPrinterSettingsSheet> createState() => _ThermalPrinterSettingsSheetState();
}

class _ThermalPrinterSettingsSheetState extends ConsumerState<ThermalPrinterSettingsSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _navScrollController;

  late int _paperWidth;
  late int _columnWidth;
  late bool _autoPrint;
  late bool _autoCut;
  late int _feedLines;
  late bool _monospaceWhatsApp;

  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late bool _showAddress;
  late TextEditingController _addressController;
  late bool _showPhone;
  late TextEditingController _phoneController;
  late TextEditingController _customHeaderController;
  late bool _showCashier;
  late bool _showCustomer;
  late bool _showDateTime;
  late bool _showInvoiceNumber;

  late TextEditingController _footerController;
  late TextEditingController _policyController;
  late TextEditingController _socialController;

  @override
  void initState() {
    super.initState();
    _navScrollController = ScrollController();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
        _scrollToActiveTab();
      }
    });

    final prefs = ref.read(appPreferencesProvider);
    final store = ref.read(authProvider).currentStore;

    _paperWidth = prefs.printerPaperWidth;
    _columnWidth = prefs.printerColumnWidth;
    _autoPrint = prefs.autoPrintReceipt;
    _autoCut = prefs.printerAutoCut;
    _feedLines = prefs.printerFeedLines;
    _monospaceWhatsApp = prefs.printerMonospaceWhatsApp;

    _titleController = TextEditingController(text: prefs.printerHeaderTitle ?? (store?.name ?? ''));
    _subtitleController = TextEditingController(text: prefs.printerHeaderSubtitle ?? '');
    _showAddress = prefs.printerShowAddress;
    _addressController = TextEditingController(text: prefs.printerAddress ?? (store?.address ?? ''));
    _showPhone = prefs.printerShowPhone;
    _phoneController = TextEditingController(text: prefs.printerPhone ?? (store?.phone ?? ''));
    _customHeaderController = TextEditingController(text: prefs.printerCustomHeader ?? '');

    _showCashier = prefs.printerShowCashier;
    _showCustomer = prefs.printerShowCustomer;
    _showDateTime = prefs.printerShowDateTime;
    _showInvoiceNumber = prefs.printerShowInvoiceNumber;

    _footerController = TextEditingController(text: prefs.printerFooterMessage);
    _policyController = TextEditingController(text: prefs.printerFooterPolicy ?? '');
    _socialController = TextEditingController(text: prefs.printerFooterSocial ?? '');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _navScrollController.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _customHeaderController.dispose();
    _footerController.dispose();
    _policyController.dispose();
    _socialController.dispose();
    super.dispose();
  }

  AppPreferences _getCurrentDraftPreferences() {
    return ref.read(appPreferencesProvider).copyWith(
      printerPaperWidth: _paperWidth, printerColumnWidth: _columnWidth,
      autoPrintReceipt: _autoPrint, printerAutoCut: _autoCut,
      printerFeedLines: _feedLines, printerMonospaceWhatsApp: _monospaceWhatsApp,
      printerHeaderTitle: _titleController.text.trim().isNotEmpty ? _titleController.text.trim() : null,
      printerHeaderSubtitle: _subtitleController.text.trim().isNotEmpty ? _subtitleController.text.trim() : null,
      printerShowAddress: _showAddress, printerAddress: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
      printerShowPhone: _showPhone, printerPhone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
      printerCustomHeader: _customHeaderController.text.trim().isNotEmpty ? _customHeaderController.text.trim() : null,
      printerShowCashier: _showCashier, printerShowCustomer: _showCustomer,
      printerShowDateTime: _showDateTime, printerShowInvoiceNumber: _showInvoiceNumber,
      printerFooterMessage: _footerController.text.trim(),
      printerFooterPolicy: _policyController.text.trim().isNotEmpty ? _policyController.text.trim() : null,
      printerFooterSocial: _socialController.text.trim().isNotEmpty ? _socialController.text.trim() : null,
    );
  }

  void _saveSettings() {
    HapticFeedback.lightImpact();
    final updated = _getCurrentDraftPreferences();
    ref.read(appPreferencesProvider.notifier).save(updated);
    AppToast.showSuccess(context, 'Pengaturan printer thermal & format struk berhasil disimpan');
    Navigator.of(context).pop();
  }

  void _executeTestPrint() {
    HapticFeedback.lightImpact();
    final store = ref.read(authProvider).currentStore;
    final storeName = _titleController.text.trim().isNotEmpty ? _titleController.text.trim() : (store?.name ?? 'TOKO BERKAH');
    final draft = _getCurrentDraftPreferences();
    final sampleText = ReceiptThermalFormatter.formatSampleReceipt(
      storeName: storeName,
      storeAddress: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : store?.address,
      storePhone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : store?.phone,
      prefs: draft,
    );

    ThermalPrinterTestDialog.show(
      context,
      paperWidth: _paperWidth,
      columnWidth: _columnWidth,
      feedLines: _feedLines,
      autoCut: _autoCut,
      sampleText: sampleText,
    );
  }

  void _scrollToActiveTab() {
    if (!_navScrollController.hasClients) return;
    final targetOffset = (_tabController.index * 96.0) - 24;
    _navScrollController.animateTo(
      targetOffset.clamp(0.0, _navScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(authProvider).currentStore;
    final storeName = _titleController.text.trim().isNotEmpty ? _titleController.text.trim() : (store?.name ?? 'TOKO BERKAH');
    final draft = _getCurrentDraftPreferences();
    final sampleReceipt = ReceiptThermalFormatter.formatSampleReceipt(
      storeName: storeName,
      storeAddress: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : store?.address,
      storePhone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : store?.phone,
      prefs: draft,
    );

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(width: 38, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.print_rounded, color: Color(0xFF4F46E5), size: 22),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pengaturan Printer', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    Text('Kertas 58mm/80mm • Header & Footer Dinamis • ESC/POS', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 10),
          ThermalPrinterSegmentedNav(tabController: _tabController, navScrollController: _navScrollController),
          const SizedBox(height: 12),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ThermalPrinterPaperTab(
                  paperWidth: _paperWidth, columnWidth: _columnWidth, feedLines: _feedLines,
                  autoPrint: _autoPrint, autoCut: _autoCut,
                  onPaperSizeSelected: (pw, cw) => setState(() { _paperWidth = pw; _columnWidth = cw; }),
                  onColumnWidthChanged: (val) => setState(() => _columnWidth = val),
                  onFeedLinesChanged: (val) => setState(() => _feedLines = val),
                  onAutoPrintChanged: (val) => setState(() => _autoPrint = val),
                  onAutoCutChanged: (val) => setState(() => _autoCut = val),
                ),
                ThermalPrinterHeaderTab(
                  titleController: _titleController, subtitleController: _subtitleController,
                  showAddress: _showAddress, addressController: _addressController,
                  showPhone: _showPhone, phoneController: _phoneController,
                  customHeaderController: _customHeaderController,
                  showInvoiceNumber: _showInvoiceNumber, showDateTime: _showDateTime,
                  showCashier: _showCashier, showCustomer: _showCustomer,
                  onShowAddressChanged: (val) => setState(() => _showAddress = val),
                  onShowPhoneChanged: (val) => setState(() => _showPhone = val),
                  onShowInvoiceNumberChanged: (val) => setState(() => _showInvoiceNumber = val),
                  onShowDateTimeChanged: (val) => setState(() => _showDateTime = val),
                  onShowCashierChanged: (val) => setState(() => _showCashier = val),
                  onShowCustomerChanged: (val) => setState(() => _showCustomer = val),
                  onChanged: () => setState(() {}),
                ),
                ThermalPrinterFooterTab(
                  footerController: _footerController, policyController: _policyController,
                  socialController: _socialController, monospaceWhatsApp: _monospaceWhatsApp,
                  onMonospaceWhatsAppChanged: (val) => setState(() => _monospaceWhatsApp = val),
                  onChanged: () => setState(() {}),
                ),
                ThermalPrinterPreviewTab(
                  paperWidth: _paperWidth, columnWidth: _columnWidth, sampleReceipt: sampleReceipt,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _executeTestPrint,
                  icon: const Icon(Icons.receipt_long_rounded, size: 16, color: Color(0xFF0F766E)),
                  label: const Text('Uji Cetak', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: Color(0xFF0F766E))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF99F6E4)),
                    backgroundColor: const Color(0xFFF0FDFA),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _saveSettings,
                  icon: const Icon(Icons.check_rounded, size: 17),
                  label: const Text('Simpan Pengaturan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
