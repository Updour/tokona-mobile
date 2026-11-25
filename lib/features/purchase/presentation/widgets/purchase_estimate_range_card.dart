import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';

class PurchaseEstimateRangeCard extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<DateTimeRange?> onRangeChanged;

  const PurchaseEstimateRangeCard({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onRangeChanged,
  });

  Future<void> _pickRange(BuildContext context) async {
    final now = DateTime.now();
    final initialRange = (startDate != null && endDate != null)
        ? DateTimeRange(start: startDate!, end: endDate!)
        : DateTimeRange(start: now.add(const Duration(days: 2)), end: now.add(const Duration(days: 5)));

    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 60)),
      initialDateRange: initialRange,
      helpText: 'PILIH RENTANG ESTIMASI TIBA',
      saveText: 'PILIH',
    );
    if (picked != null) {
      onRangeChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM');
    final hasRange = startDate != null && endDate != null;
    final rangeText = hasRange ? '${df.format(startDate!)} – ${df.format(endDate!)}' : 'Atur Rentang Tiba';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month_outlined, size: 15, color: Color(0xFF15803D)),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Estimasi Pengiriman (Rentang Tiba):',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF166534)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InkWell(
                onTap: () => _pickRange(context),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.edit_calendar_outlined, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        rangeText,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.schedule_rounded, size: 12, color: Color(0xFF15803D)),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Jika melewati batas tanggal maksimal belum diterima, pesanan akan otomatis diselesaikan sistem.',
                  style: TextStyle(fontSize: 10, color: Color(0xFF166534), height: 1.3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
