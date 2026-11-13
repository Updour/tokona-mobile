import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NativePushNotificationService {
  NativePushNotificationService._();

  static const MethodChannel _channel = MethodChannel('com.tokona.app/native_notifications');
  static final Set<String> _recentlyPushedIds = {};

  static Future<void> requestPermission() async {
    try {
      await _channel.invokeMethod('requestPermission');
    } catch (e) {
      debugPrint('NativePushNotificationService.requestPermission error: $e');
    }
  }

  static Future<bool> showPushNotification({
    required int id,
    required String title,
    required String body,
    String? trackingKey,
  }) async {
    if (trackingKey != null) {
      if (_recentlyPushedIds.contains(trackingKey)) {
        return false;
      }
      _recentlyPushedIds.add(trackingKey);
    }

    try {
      final result = await _channel.invokeMethod<bool>('showNotification', {
        'id': id,
        'title': title,
        'body': body,
      });
      return result ?? false;
    } catch (e) {
      debugPrint('NativePushNotificationService.showPushNotification error: $e');
      return false;
    }
  }

  static void clearPushedCache() {
    _recentlyPushedIds.clear();
  }
}

