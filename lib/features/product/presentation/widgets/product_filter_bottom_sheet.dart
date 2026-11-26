import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/widgets/modern_sheet_widgets.dart';
import 'package:tokona/features/product/domain/models/device_stock_summary.dart';
import 'package:tokona/features/product/domain/models/product_filter_state.dart';

class ProductFilterBottomSheet extends StatefulWidget {
  final ProductFilterState initialFilter;
  final List<DeviceStockSummary> deviceSummaries;
  final String? initialDeviceTag;
  final ValueChanged<ProductFilterState> onApply;
  final ValueChanged<String?>? onSelectDevice;
  final VoidCallback onReset;

  const ProductFilterBottomSheet({
    super.key,
    required this.initialFilter,
    this.deviceSummaries = const [],
    this.initialDeviceTag,
    required this.onApply,
    this.onSelectDevice,
    required this.onReset,
  });

  static Future<void> show(
    BuildContext context, {
    required ProductFilterState initialFilter,
    List<DeviceStockSummary> deviceSummaries = const [],
    String? selectedDeviceTag,
    required ValueChanged<ProductFilterState> onApply,
    ValueChanged<String?>? onSelectDevice,
    required VoidCallback onReset,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductFilterBottomSheet(
        initialFilter: initialFilter,
        deviceSummaries: deviceSummaries,
        initialDeviceTag: selectedDeviceTag,
        onApply: onApply,
        onSelectDevice: onSelectDevice,
        onReset: onReset,
      ),
    );
  }

  @override
  State<ProductFilterBottomSheet> createState() => _ProductFilterBottomSheetState();
}

class _ProductFilterBottomSheetState extends State<ProductFilterBottomSheet> {
  late ProductSortBy _selectedSortBy;
  late ProductDateFilter _selectedDateFilter;
  String? _selectedDeviceTag;
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;

  @override
  void initState() {
    super.initState();
    _selectedSortBy = widget.initialFilter.sortBy;
    _selectedDateFilter = widget.initialFilter.dateFilter;
    _selectedDeviceTag = widget.initialDeviceTag;
    _customStartDate = widget.initialFilter.customStartDate;
    _customEndDate = widget.initialFilter.customEndDate;
    _minPriceController = TextEditingController(text: widget.initialFilter.minPrice != null ? CurrencyFormatter.formatNumber(widget.initialFilter.minPrice!) : '');
    _maxPriceController = TextEditingController(text: widget.initialFilter.maxPrice != null ? CurrencyFormatter.formatNumber(widget.initialFilter.maxPrice!) : '');
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  Future<void> _pickCustomDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: _customStartDate != null && _customEndDate != null
          ? DateTimeRange(start: _customStartDate!, end: _customEndDate!)
          : DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
    );
    if (picked != null) {
      setState(() {
        _selectedDateFilter = ProductDateFilter.custom;
        _customStartDate = picked.start;
        _customEndDate = picked.end;
      });
    }
  }

  void _handleApply() {
    final min = _minPriceController.text.trim().isEmpty ? null : CurrencyFormatter.parse(_minPriceController.text);
    final max = _maxPriceController.text.trim().isEmpty ? null : CurrencyFormatter.parse(_maxPriceController.text);
    widget.onSelectDevice?.call(_selectedDeviceTag);
    widget.onApply(ProductFilterState(
      stockFilter: widget.initialFilter.stockFilter,
      sortBy: _selectedSortBy,
      dateFilter: _selectedDateFilter,
      customStartDate: _selectedDateFilter == ProductDateFilter.custom ? _customStartDate : null,
      customEndDate: _selectedDateFilter == ProductDateFilter.custom ? _customEndDate : null,
      minPrice: min, maxPrice: max,
    ));
    Navigator.of(context).pop();
  }

  void _handleReset() {
    widget.onSelectDevice?.call(null);
    widget.onReset();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ModernSheetHeader(
            title: 'Filter Produk',
            subtitle: 'Atur urutan & rentang katalog',
            icon: Icons.tune_rounded,
            onClose: () => Navigator.of(context).pop(),
            trailingAction: InkWell(
              onTap: _handleReset,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(12)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.restart_alt_rounded, size: 14, color: Color(0xFFDC2626)),
                  SizedBox(width: 4),
                  Text('Reset', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w800, fontSize: 11.5)),
                ]),
              ),
            ),
          ),
          const Divider(height: 22),
          Expanded(
            child: ListView(
              children: [
                if (widget.deviceSummaries.isNotEmpty) ...[
                  _title('Filter Perangkat (Device)'),
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: [
                      _chip('Semua Device', _selectedDeviceTag == null, (_) => setState(() => _selectedDeviceTag = null), color: const Color(0xFF6366F1)),
                      ...widget.deviceSummaries.map((d) => _chip(
                        d.isUntagged ? 'Tanpa Device' : d.deviceName,
                        _selectedDeviceTag == d.deviceName,
                        (_) => setState(() => _selectedDeviceTag = d.deviceName),
                        color: const Color(0xFF6366F1),
                      )),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],
                _title('Urutkan Berdasarkan'),
                Wrap(
                  spacing: 6, runSpacing: 6,
                  children: ProductSortBy.values.map((s) => _chip(s.label, _selectedSortBy == s, (v) { if (v) setState(() => _selectedSortBy = s); })).toList(),
                ),
                const SizedBox(height: 14),
                _title('Filter Tanggal Input / Masuk'),
                Wrap(
                  spacing: 6, runSpacing: 6,
                  children: [
                    ...ProductDateFilter.values.where((f) => f != ProductDateFilter.custom).map((f) => _chip(f.label, _selectedDateFilter == f, (v) { if (v) setState(() => _selectedDateFilter = f); }, color: const Color(0xFF0284C7))),
                    ActionChip(
                      avatar: const Icon(Icons.date_range_rounded, size: 14),
                      label: Text(
                        _selectedDateFilter == ProductDateFilter.custom && _customStartDate != null
                            ? '${DateFormat('dd/MM').format(_customStartDate!)} - ${DateFormat('dd/MM').format(_customEndDate!)}' : 'Pilih Rentang',
                        style: TextStyle(fontSize: 11, fontWeight: _selectedDateFilter == ProductDateFilter.custom ? FontWeight.w700 : FontWeight.w500, color: _selectedDateFilter == ProductDateFilter.custom ? Colors.white : AppColors.textPrimary),
                      ),
                      backgroundColor: _selectedDateFilter == ProductDateFilter.custom ? const Color(0xFF0284C7) : AppColors.surfaceElevated,
                      onPressed: _pickCustomDateRange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _title('Rentang Harga Jual (Rp)'),
                Row(
                  children: [
                    Expanded(child: TextField(controller: _minPriceController, keyboardType: TextInputType.number, inputFormatters: [CurrencyTextInputFormatter()], style: const TextStyle(fontSize: 12.5), decoration: _decor('Harga Min'))),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('-', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary))),
                    Expanded(child: TextField(controller: _maxPriceController, keyboardType: TextInputType.number, inputFormatters: [CurrencyTextInputFormatter()], style: const TextStyle(fontSize: 12.5), decoration: _decor('Harga Max'))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: _handleApply,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Terapkan Filter', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _decor(String hint) {
    return InputDecoration(
      hintText: hint,
      prefixText: 'Rp',
      prefixStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text.toUpperCase(), style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 0.5)),
    );
  }

  Widget _chip(String label, bool isSelected, ValueChanged<bool> onSelected, {Color color = AppColors.primary}) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onSelected(!isSelected);
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7.5),
        decoration: BoxDecoration(
          color: isSelected ? color : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}
