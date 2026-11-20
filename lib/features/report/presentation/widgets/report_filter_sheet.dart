import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/report/domain/models/report_filter_type.dart';

class ReportFilterSheet extends StatefulWidget {
  final ReportFilterType currentFilter;
  final DateTime? currentStart;
  final DateTime? currentEnd;
  final void Function(ReportFilterType filter, DateTime? start, DateTime? end) onApply;

  const ReportFilterSheet({
    super.key,
    required this.currentFilter,
    this.currentStart,
    this.currentEnd,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    required ReportFilterType currentFilter,
    DateTime? currentStart,
    DateTime? currentEnd,
    required void Function(ReportFilterType filter, DateTime? start, DateTime? end) onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReportFilterSheet(
        currentFilter: currentFilter,
        currentStart: currentStart,
        currentEnd: currentEnd,
        onApply: onApply,
      ),
    );
  }

  @override
  State<ReportFilterSheet> createState() => _ReportFilterSheetState();
}

class _ReportFilterSheetState extends State<ReportFilterSheet> {
  late ReportFilterType _selectedFilter;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.currentFilter;
    final now = DateTime.now();
    _startDate = widget.currentStart ?? now;
    _endDate = widget.currentEnd ?? now;
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _selectedFilter = ReportFilterType.custom;
        if (_endDate.isBefore(_startDate)) _endDate = _startDate;
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _selectedFilter = ReportFilterType.custom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    const presets = [
      (ReportFilterType.today, 'Hari Ini'), (ReportFilterType.yesterday, 'Kemarin'),
      (ReportFilterType.last7Days, '7 Hari Terakhir'), (ReportFilterType.thisMonth, 'Bulan Ini'),
      (ReportFilterType.lastMonth, 'Bulan Lalu'), (ReportFilterType.thisYear, 'Tahun Ini'),
    ];

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: [
            BoxShadow(color: Color(0x140F172A), blurRadius: 20, offset: Offset(0, -4)),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.tune_rounded, color: Color(0xFF334155), size: 16),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Filter Periode Laporan',
                          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    widget.onApply(ReportFilterType.today, null, null);
                    Navigator.of(context).pop();
                  },
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
                        Icon(Icons.restart_alt_rounded, size: 12.5, color: Color(0xFFDC2626)),
                        SizedBox(width: 3),
                        Text('Reset', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w800, fontSize: 10.5)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 18, color: Color(0xFFF1F5F9)),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: presets.map((p) {
                final isSelected = _selectedFilter == p.$1;
                return ChoiceChip(
                  label: Text(p.$2),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _selectedFilter = p.$1);
                  },
                  selectedColor: AppColors.primary,
                  backgroundColor: const Color(0xFFF8FAFC),
                  side: BorderSide(color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0)),
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF475569),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                  visualDensity: const VisualDensity(horizontal: -1, vertical: -2),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            const Text(
              'RENTANG TANGGAL KUSTOM',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.4),
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                Expanded(child: _buildDateBox('Dari Tanggal', _startDate, _pickStartDate, dateFormat)),
                const SizedBox(width: 8),
                Expanded(child: _buildDateBox('Sampai Tanggal', _endDate, _pickEndDate, dateFormat)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedFilter == ReportFilterType.custom) {
                    widget.onApply(ReportFilterType.custom, _startDate, _endDate);
                  } else {
                    widget.onApply(_selectedFilter, null, null);
                  }
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Terapkan Filter', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateBox(String title, DateTime date, VoidCallback onTap, DateFormat format) {
    final isCustom = _selectedFilter == ReportFilterType.custom;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8.5),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isCustom ? AppColors.primary : const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8))),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.primary),
                const SizedBox(width: 5),
                Text(format.format(date), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
