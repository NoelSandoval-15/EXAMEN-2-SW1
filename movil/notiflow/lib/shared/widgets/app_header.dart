import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.showNotification = false,
  });

  final String title;
  final String? subtitle;
  final bool showBack;
  final bool showNotification;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (showBack) ...[
            IconButton.filledTonal(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.chevron_left),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                foregroundColor: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          if (showNotification)
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton.filledTonal(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/notifications'),
                  icon: const Icon(Icons.notifications_none),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    foregroundColor: AppColors.textPrimary,
                  ),
                ),
                Positioned(
                  right: 2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '2',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
