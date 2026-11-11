import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  WhatsAppService._();

  static String sanitizePhoneNumber(String phone) {
    String clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.startsWith('0')) {
      clean = '62${clean.substring(1)}';
    } else if (clean.startsWith('8')) {
      clean = '62$clean';
    }
    return clean;
  }

  static Future<bool> sendReceipt({
    required String phone,
    required String message,
  }) async {
    final cleanPhone = sanitizePhoneNumber(phone);
    final encodedMessage = Uri.encodeComponent(message);

    final whatsappSchemeUri = Uri.parse('whatsapp://send?phone=$cleanPhone&text=$encodedMessage');
    final apiWebUri = Uri.parse('https://api.whatsapp.com/send?phone=$cleanPhone&text=$encodedMessage');
    final waMeUri = Uri.parse('https://wa.me/$cleanPhone?text=$encodedMessage');

    try {
      if (await canLaunchUrl(whatsappSchemeUri)) {
        return await launchUrl(whatsappSchemeUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('WhatsAppService: scheme failed: $e');
    }

    try {
      if (await canLaunchUrl(apiWebUri)) {
        return await launchUrl(apiWebUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('WhatsAppService: api url failed: $e');
    }

    try {
      return await launchUrl(waMeUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('WhatsAppService: wa.me url failed: $e');
      return false;
    }
  }
}

