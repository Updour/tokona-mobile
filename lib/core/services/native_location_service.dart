import 'package:flutter/services.dart';

class StoreLocationAddress {
  final double latitude;
  final double longitude;
  final String formattedAddress;
  final String street;
  final String village;
  final String district;
  final String city;
  final String province;
  final String postalCode;

  const StoreLocationAddress({
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
    this.street = '',
    this.village = '',
    this.district = '',
    this.city = '',
    this.province = '',
    this.postalCode = '',
  });

  /// Mengembalikan alamat yang diformat rapi standar Indonesia
  String get formattedSummary {
    final parts = <String>[];
    if (street.isNotEmpty) parts.add(street);
    if (village.isNotEmpty) parts.add('Ds./Kel. $village');
    if (district.isNotEmpty) parts.add('Kec. $district');
    if (city.isNotEmpty) parts.add(city);
    if (province.isNotEmpty) parts.add(province);
    if (postalCode.isNotEmpty) parts.add(postalCode);

    if (parts.isNotEmpty) {
      return parts.join(', ');
    }
    return formattedAddress;
  }
}

class NativeLocationService {
  NativeLocationService._();

  static const _channel = MethodChannel('com.tokona.app/native_contacts');

  /// Mengambil lokasi GPS HP dan menerjemahkannya ke alamat lengkap (desa, kecamatan, kota, provinsi, kode pos)
  static Future<StoreLocationAddress?> getCurrentLocationAddress() async {
    try {
      final res = await _channel.invokeMapMethod<String, dynamic>('getCurrentLocationAddress');
      if (res == null) return null;

      return StoreLocationAddress(
        latitude: (res['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (res['longitude'] as num?)?.toDouble() ?? 0.0,
        formattedAddress: (res['formattedAddress']?.toString() ?? '').trim(),
        street: (res['street']?.toString() ?? '').trim(),
        village: (res['village']?.toString() ?? '').trim(),
        district: (res['district']?.toString() ?? '').trim(),
        city: (res['city']?.toString() ?? '').trim(),
        province: (res['province']?.toString() ?? '').trim(),
        postalCode: (res['postalCode']?.toString() ?? '').trim(),
      );
    } on PlatformException catch (e) {
      throw e.message ?? 'Gagal mengambil lokasi GPS';
    } catch (e) {
      throw 'Terjadi kesalahan saat membaca sensor lokasi: $e';
    }
  }
}
