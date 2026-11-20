import 'package:flutter/services.dart';

class PickedContact {
  final String name;
  final String phone;
  final String? address;

  const PickedContact({
    required this.name,
    required this.phone,
    this.address,
  });
}

class NativeContactService {
  NativeContactService._();

  static const _channel = MethodChannel('com.tokona.app/native_contacts');

  /// Membuka pemilih kontak bawaan Android (tanpa perlu izin READ_CONTACTS penuh)
  static Future<PickedContact?> pickContact() async {
    try {
      final res = await _channel.invokeMapMethod<String, dynamic>('pickContact');
      if (res == null) return null;

      final name = (res['name']?.toString() ?? '').trim();
      final rawPhone = (res['phone']?.toString() ?? '').trim();
      final address = (res['address']?.toString() ?? '').trim();
      final cleanPhone = _normalizePhone(rawPhone);

      if (name.isEmpty && cleanPhone.isEmpty && address.isEmpty) return null;
      return PickedContact(
        name: name.isNotEmpty ? name : cleanPhone,
        phone: cleanPhone,
        address: address.isNotEmpty ? address : null,
      );
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  /// Membuka pemilih alamat kontak langsung bawaan HP
  static Future<String?> pickAddress() async {
    try {
      final res = await _channel.invokeMapMethod<String, dynamic>('pickAddress');
      if (res == null) return null;
      final addr = (res['address']?.toString() ?? '').trim();
      return addr.isNotEmpty ? addr : null;
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  static String _normalizePhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.startsWith('+62')) return '0${digits.substring(3)}';
    if (digits.startsWith('62') && digits.length >= 10) return '0${digits.substring(2)}';
    return digits.replaceAll('+', '');
  }
}
