import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/dashboard/domain/models/app_notification_item.dart';

class NotificationBannerWidget extends StatefulWidget {
  final AppNotificationItem notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const NotificationBannerWidget({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<NotificationBannerWidget> createState() => _NotificationBannerWidgetState();
}

class _NotificationBannerWidgetState extends State<NotificationBannerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _animController.forward();
  }

  Future<void> _dismissWithAnim() async {
    await _animController.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notif = widget.notification;
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 8,
      left: 14,
      right: 14,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.primaryDelta != null && details.primaryDelta! < -4) {
                _dismissWithAnim();
              }
            },
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  _dismissWithAnim();
                  widget.onTap();
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: notif.containerColor,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(notif.icon, color: notif.accentColor, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    notif.title,
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(width: 2.5, height: 2.5, decoration: const BoxDecoration(color: AppColors.textMuted, shape: BoxShape.circle)),
                                const SizedBox(width: 4),
                                Text(
                                  notif.categoryLabel,
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 9.5, color: notif.accentColor),
                                ),
                              ],
                            ),
                            const SizedBox(height: 1.5),
                            Text(
                              notif.body,
                              style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary, height: 1.2),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: _dismissWithAnim,
                        borderRadius: BorderRadius.circular(10),
                        child: const Padding(
                          padding: EdgeInsets.all(3),
                          child: Icon(Icons.close_rounded, size: 15, color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

