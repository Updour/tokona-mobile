import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tokona/core/services/native_push_notification_service.dart';
import 'package:tokona/features/dashboard/domain/models/app_notification_item.dart';
import 'package:tokona/features/dashboard/presentation/widgets/notification_banner_widget.dart';

class InAppNotificationService {
  InAppNotificationService._();
  static final InAppNotificationService instance = InAppNotificationService._();

  OverlayEntry? _currentEntry;
  Timer? _dismissTimer;

  static void show(
    BuildContext context,
    AppNotificationItem item, {
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 6),
  }) {
    instance._showBanner(context, item, onTap: onTap, duration: duration);
  }

  void _showBanner(
    BuildContext context,
    AppNotificationItem item, {
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 6),
  }) {
    if (_currentEntry != null) {
      _removeEntry();
    }

    HapticFeedback.mediumImpact();
    NativePushNotificationService.showPushNotification(
      id: item.id.hashCode,
      title: item.title,
      body: item.body,
      trackingKey: item.id,
    );

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    _currentEntry = OverlayEntry(
      builder: (_) => NotificationBannerWidget(
        notification: item,
        onTap: () {
          _removeEntry();
          if (onTap != null) {
            onTap();
          } else if (item.onTapAction != null) {
            item.onTapAction!();
          }
        },
        onDismiss: () => _removeEntry(),
      ),
    );

    overlay.insert(_currentEntry!);

    _dismissTimer?.cancel();
    _dismissTimer = Timer(duration, () {
      _removeEntry();
    });
  }

  void _removeEntry() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    if (_currentEntry != null) {
      try {
        _currentEntry?.remove();
      } catch (_) {}
      _currentEntry = null;
    }
  }
}

