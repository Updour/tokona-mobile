import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';

enum AppNotificationType {
  kasbonOverdue,
  kasbonDueSoon,
  stockEmpty,
  stockLow,
  bookingReady,
  purchaseRefund,
  generalInfo,
}

class AppNotificationItem {
  final String id;
  final String title;
  final String body;
  final AppNotificationType type;
  final DateTime createdAt;
  final String targetPayload;
  final VoidCallback? onTapAction;

  const AppNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    required this.targetPayload,
    this.onTapAction,
  });

  String get categoryLabel {
    switch (type) {
      case AppNotificationType.kasbonOverdue:
        return 'Jatuh Tempo Telat';
      case AppNotificationType.kasbonDueSoon:
        return 'Kasbon Mendekati Tempo';
      case AppNotificationType.stockEmpty:
        return 'Stok Habis (0 Pcs)';
      case AppNotificationType.stockLow:
        return 'Stok Menipis';
      case AppNotificationType.bookingReady:
        return 'Pesanan Booking';
      case AppNotificationType.purchaseRefund:
        return 'Refund Belanja';
      case AppNotificationType.generalInfo:
        return 'Informasi Toko';
    }
  }

  Color get accentColor {
    switch (type) {
      case AppNotificationType.kasbonOverdue:
      case AppNotificationType.stockEmpty:
        return const Color(0xFFDC2626);
      case AppNotificationType.kasbonDueSoon:
      case AppNotificationType.stockLow:
        return const Color(0xFFD97706);
      case AppNotificationType.bookingReady:
        return const Color(0xFF0D9488);
      case AppNotificationType.purchaseRefund:
        return const Color(0xFF4F46E5);
      case AppNotificationType.generalInfo:
        return AppColors.primary;
    }
  }

  Color get containerColor {
    switch (type) {
      case AppNotificationType.kasbonOverdue:
      case AppNotificationType.stockEmpty:
        return const Color(0xFFFEF2F2);
      case AppNotificationType.kasbonDueSoon:
      case AppNotificationType.stockLow:
        return const Color(0xFFFEF3C7);
      case AppNotificationType.bookingReady:
        return const Color(0xFFCCFBF1);
      case AppNotificationType.purchaseRefund:
        return const Color(0xFFEEF2FF);
      case AppNotificationType.generalInfo:
        return AppColors.primaryContainer;
    }
  }

  IconData get icon {
    switch (type) {
      case AppNotificationType.kasbonOverdue:
        return Icons.event_busy_rounded;
      case AppNotificationType.kasbonDueSoon:
        return Icons.notification_important_rounded;
      case AppNotificationType.stockEmpty:
        return Icons.remove_shopping_cart_rounded;
      case AppNotificationType.stockLow:
        return Icons.production_quantity_limits_rounded;
      case AppNotificationType.bookingReady:
        return Icons.delivery_dining_rounded;
      case AppNotificationType.purchaseRefund:
        return Icons.assignment_return_rounded;
      case AppNotificationType.generalInfo:
        return Icons.notifications_active_rounded;
    }
  }
}

