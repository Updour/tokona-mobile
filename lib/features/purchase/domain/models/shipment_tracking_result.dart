class TrackingTimelinePoint {
  final String scanTime;
  final String statusName;
  final String description;
  final String? location;
  final String? officerName;
  final String? contactPhone;
  final String? nextStop;

  const TrackingTimelinePoint({
    required this.scanTime,
    required this.statusName,
    required this.description,
    this.location,
    this.officerName,
    this.contactPhone,
    this.nextStop,
  });

  factory TrackingTimelinePoint.fromJson(Map<String, dynamic> json) {
    return TrackingTimelinePoint(
      scanTime: json['scanTime']?.toString() ?? '',
      statusName: json['status']?.toString() ?? json['scanTypeName']?.toString() ?? 'Update',
      description: json['customerTracking']?.toString() ?? '',
      location: json['scanNetworkCity']?.toString() ?? json['scanNetworkName']?.toString(),
      officerName: json['staffName']?.toString() ?? json['scanByName']?.toString(),
      contactPhone: json['staffContact']?.toString() ?? json['scanNetworkContact']?.toString(),
      nextStop: json['nextStopName']?.toString(),
    );
  }
}

class ShipmentTrackingResult {
  final bool isSuccess;
  final String waybillNo;
  final String courierName;
  final String? serviceType;
  final double? weight;
  final int? packageCount;
  final String? originCity;
  final String? destinationCity;
  final String latestStatus;
  final bool isDelivered;
  final List<TrackingTimelinePoint> timeline;
  final String? errorMessage;
  final DateTime fetchedAt;

  const ShipmentTrackingResult({
    required this.isSuccess,
    required this.waybillNo,
    this.courierName = 'J&T Cargo',
    this.serviceType,
    this.weight,
    this.packageCount,
    this.originCity,
    this.destinationCity,
    required this.latestStatus,
    this.isDelivered = false,
    this.timeline = const [],
    this.errorMessage,
    required this.fetchedAt,
  });

  factory ShipmentTrackingResult.failure(String waybill, String error, {String courier = 'J&T Cargo'}) {
    return ShipmentTrackingResult(
      isSuccess: false,
      waybillNo: waybill,
      courierName: courier,
      latestStatus: 'Gagal Memuat',
      errorMessage: error,
      fetchedAt: DateTime.now(),
    );
  }
}

