import 'package:flutter/material.dart';

class ProfileMenuItem {
  final IconData icon;
  final Color color;
  final Color bg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badgeText;
  final Color? badgeColor;

  const ProfileMenuItem({
    required this.icon,
    required this.color,
    required this.bg,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badgeText,
    this.badgeColor,
  });
}

class ProfileMenuGroup {
  final String title;
  final String count;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final bool initiallyExpanded;
  final List<ProfileMenuItem> items;

  const ProfileMenuGroup({
    required this.title,
    required this.count,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.initiallyExpanded = false,
    required this.items,
  });
}
