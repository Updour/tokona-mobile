import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/product/domain/models/product_filter_state.dart';

class ProductFilterBottomSheet extends StatefulWidget {
  final ProductFilterState initialFilter;
  final ValueChanged<ProductFilterState> onApply;
  final VoidCallback onReset;

  const ProductFilterBottomSheet({
    super.key,
    required this.initialFilter,
    required this.onApply,
    required this.onReset,
  });

  static Future<void> show(
    BuildContext context, {
    required ProductFilterState initialFilter,
    required ValueChanged<ProductFilterState> onApply,
    required VoidCallback onReset,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductFilterBottomSheet(
        initialFilter: initialFilter, onApply: onApply, onReset: onReset,
      ),
    );
  }

  @override
  State<ProductFilterBottomSheet> createState() => _ProductFilterBottomSheetState();
}

class _ProductFilterBottomSheetState extends State<ProductFilterBottomSheet> {
  late ProductSortBy _selectedSortBy;
  late ProductDateFilter _selectedDateFilter;
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;

  @override
  void initState() {
    super.initState();
    _selectedSortBy = widget.initialFilter.sortBy;
    _selectedDateFilter = widget.initialFilter.dateFilter;
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
    final minPrice = _minPriceController.text.trim().isEmpty ? null : CurrencyFormatter.parse(_minPriceController.text);
    final maxPrice = _maxPriceController.text.trim().isEmpty ? null : CurrencyFormatter.parse(_maxPriceController.text);
    widget.onApply(ProductFilterState(
      stockFilter: widget.initialFilter.stockFilter,
      sortBy: _selectedSortBy,
      dateFilter: _selectedDateFilter,
      customStartDate: _selectedDateFilter == ProductDateFilter.custom ? _customStartDate : null,
      customEndDate: _selectedDateFilter == ProductDateFilter.custom ? _customEndDate : null,
      minPrice: minPrice,
      maxPrice: maxPrice,
    ));
    Navigator.of(context).pop();
  }

  void _handleReset() {
    widget.onReset();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 14, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.tune_rounded, color: AppColors.primaryDark, size: 17),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Filter & Urutkan Produk', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text('Sesuaikan kriteria tampilan katalog', style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _handleReset,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.restart_alt_rounded, size: 13, color: Color(0xFFDC2626)),
                      SizedBox(width: 3),
                      Text('Reset', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w800, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildSectionTitle('Urutkan Berdasarkan'),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: ProductSortBy.values.map((sort) => _buildChip(
                    sort.label, _selectedSortBy == sort, (v) { if (v) setState(() => _selectedSortBy = sort); },
                  )).toList(),
                ),
                const SizedBox(height: 14),
                _buildSectionTitle('Filter Tanggal Input / Masuk'),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ...ProductDateFilter.values.where((f) => f != ProductDateFilter.custom).map((f) => _buildChip(
                      f.label, _selectedDateFilter == f, (v) { if (v) setState(() => _selectedDateFilter = f); },
                      selectedColor: const Color(0xFF0284C7),
                    )),
                    ActionChip(
                      avatar: const Icon(Icons.date_range_rounded, size: 14),
                      label: Text(
                        _selectedDateFilter == ProductDateFilter.custom && _customStartDate != null
                            ? '${DateFormat('dd/MM').format(_customStartDate!)} - ${DateFormat('dd/MM').format(_customEndDate!)}'
                            : 'Pilih Rentang',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: _selectedDateFilter == ProductDateFilter.custom ? FontWeight.w700 : FontWeight.w500,
                          color: _selectedDateFilter == ProductDateFilter.custom ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      backgroundColor: _selectedDateFilter == ProductDateFilter.custom ? const Color(0xFF0284C7) : AppColors.surfaceElevated,
                      onPressed: _pickCustomDateRange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildSectionTitle('Rentang Harga Jual (Rp)'),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _minPriceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [CurrencyTextInputFormatter()],
                        style: const TextStyle(fontSize: 12.5),
                        decoration: _buildInputDecor('Harga Min'),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('-', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _maxPriceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [CurrencyTextInputFormatter()],
                        style: const TextStyle(fontSize: 12.5),
                        decoration: _buildInputDecor('Harga Max'),
                      ),
                    ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Terapkan Filter', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecor(String hint) {
    const border = OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: AppColors.border));
    return InputDecoration(
      hintText: hint,
      prefixText: 'Rp ',
      prefixStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
      hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
      isDense: true,
      filled: true,
      fillColor: AppColors.surfaceElevated,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      border: border, enabledBorder: border,
      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 0.4),
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, ValueChanged<bool> onSelected, {Color selectedColor = AppColors.primary}) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: selectedColor,
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? Colors.white : AppColors.textPrimary,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
