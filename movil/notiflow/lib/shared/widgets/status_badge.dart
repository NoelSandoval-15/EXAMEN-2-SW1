import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: style.foreground,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  _BadgeStyle _styleFor(String value) {
    final normalized = value.toLowerCase();
    if (normalized.contains('finalizado')) {
      return const _BadgeStyle(Color(0xFFDDF7EE), Color(0xFF00A878));
    }
    if (normalized.contains('pendiente')) {
      return const _BadgeStyle(Color(0xFFFFE4E6), Color(0xFFFF2D2D));
    }
    if (normalized.contains('revision')) {
      return const _BadgeStyle(Color(0xFFFFF3D8), Color(0xFFF59E0B));
    }
    return _BadgeStyle(
      AppColors.primary.withValues(alpha: 0.18),
      AppColors.primary,
    );
  }
}

class _BadgeStyle {
  const _BadgeStyle(this.background, this.foreground);

  final Color background;
  final Color foreground;
}
