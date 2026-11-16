import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:tokona/features/purchase/domain/models/shipment_tracking_result.dart';

class ShipmentTrackingService {
  static final HttpClient _client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 12);

  static final Map<String, ShipmentTrackingResult> _cache = {};

  static Future<ShipmentTrackingResult> trackWaybill({
    required String waybillNo,
    String courier = 'J&T Cargo',
    String? phoneSuffix,
    bool forceRefresh = false,
  }) async {
    final cleanWaybill = waybillNo.trim();
    if (cleanWaybill.isEmpty) {
      return ShipmentTrackingResult.failure(waybillNo, 'Nomor resi kosong', courier: courier);
    }

    final cacheKey = '$courier-$cleanWaybill';
    if (!forceRefresh && _cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey]!;
      if (DateTime.now().difference(cached.fetchedAt).inMinutes < 60) {
        return cached;
      }
    }

    try {
      if (courier.toLowerCase().contains('cargo')) {
        final result = await _trackJtCargo(cleanWaybill);
        _cache[cacheKey] = result;
        return result;
      }

      return await _trackJtCargo(cleanWaybill);
    } catch (e) {
      debugPrint('[Tracking] Error: $e');
      return ShipmentTrackingResult.failure(cleanWaybill, 'Gagal terhubung ke kurir: ${e.toString()}', courier: courier);
    }
  }

  static Future<ShipmentTrackingResult> _trackJtCargo(String waybillNo) async {
    final uri = Uri.parse('https://office.jtcargo.co.id/official/waybill/trackingCustomerByWaybillNo');
    final request = await _client.postUrl(uri);
    request.headers.set('Content-Type', 'application/json;charset=UTF-8');
    request.headers.set('language', 'ID');
    request.headers.set('Origin', 'https://www.jtcargo.id');
    request.headers.set('Referer', 'https://www.jtcargo.id/');

    final payload = jsonEncode({'waybillNo': waybillNo});
    request.write(payload);

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();

    if (response.statusCode != 200) {
      return ShipmentTrackingResult.failure(waybillNo, 'Server kurir merespon kode ${response.statusCode}');
    }

    final Map<String, dynamic> data = jsonDecode(body) as Map<String, dynamic>;
    if (data['succ'] != true || data['data'] == null || (data['data'] as List).isEmpty) {
      return ShipmentTrackingResult.failure(waybillNo, data['msg']?.toString() ?? 'Data resi tidak ditemukan');
    }

    final packageData = (data['data'] as List).first as Map<String, dynamic>;
    final rawDetails = packageData['details'] as List<dynamic>? ?? [];

    final timeline = rawDetails.map((item) => TrackingTimelinePoint.fromJson(item as Map<String, dynamic>)).toList();

    final latestStatus = timeline.isNotEmpty ? timeline.first.statusName : 'Dalam Pengiriman';
    final isDelivered = latestStatus.toLowerCase().contains('terima') ||
        latestStatus.toLowerCase().contains('delivered') ||
        latestStatus.toLowerCase().contains('selesai');

    return ShipmentTrackingResult(
      isSuccess: true,
      waybillNo: waybillNo,
      courierName: 'J&T Cargo',
      serviceType: packageData['expressTypeName']?.toString(),
      weight: (packageData['packageTotalWeight'] as num?)?.toDouble(),
      packageCount: packageData['packageNumber'] as int?,
      originCity: packageData['senderCityName']?.toString(),
      destinationCity: packageData['receiverCityName']?.toString(),
      latestStatus: latestStatus,
      isDelivered: isDelivered,
      timeline: timeline,
      fetchedAt: DateTime.now(),
    );
  }
}

