import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/dashboard/domain/models/app_notification_item.dart';

class NotificationItemTile extends StatelessWidget {
  final AppNotificationItem item;
  final bool isRead;
  final VoidCallback onTap;

  const NotificationItemTile({
    super.key,
    required this.item,
    required this.isRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8.5),
          decoration: BoxDecoration(
            color: isRead ? Colors.white : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isRead ? const Color(0xFFF1F5F9) : const Color(0xFFE2E8F0),
              width: 0.9,
            ),
            boxShadow: isRead
                ? null
                : [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6.5),
                decoration: BoxDecoration(
                  color: isRead ? const Color(0xFFF1F5F9) : item.containerColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.icon, color: isRead ? const Color(0xFF94A3B8) : item.accentColor, size: 16),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: isRead ? FontWeight.w600 : FontWeight.w700,
                              fontSize: 12,
                              color: isRead ? const Color(0xFF64748B) : AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: item.accentColor.withValues(alpha: isRead ? 0.08 : 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.categoryLabel,
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              color: isRead ? const Color(0xFF94A3B8) : item.accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1.5),
                    Text(
                      item.body,
                      style: TextStyle(fontSize: 10.5, color: isRead ? const Color(0xFF94A3B8) : AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              if (!isRead)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                )
              else
                const Icon(Icons.chevron_right_rounded, size: 15, color: Color(0xFFCBD5E1)),
            ],
          ),
        ),
      ),
    );
  }
}
