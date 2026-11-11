enum ReportFilterType {
  today,
  yesterday,
  last7Days,
  thisMonth,
  lastMonth,
  thisYear,
  custom;

  String get label {
    switch (this) {
      case ReportFilterType.today:
        return 'Hari Ini';
      case ReportFilterType.yesterday:
        return 'Kemarin';
      case ReportFilterType.last7Days:
        return '7 Hari';
      case ReportFilterType.thisMonth:
        return 'Bulan Ini';
      case ReportFilterType.lastMonth:
        return 'Bulan Lalu';
      case ReportFilterType.thisYear:
        return 'Tahun Ini';
      case ReportFilterType.custom:
        return 'Kustom';
    }
  }
}
