import 'package:flutter/material.dart';

import '../../config/routes.dart';
import '../../core/constants/app_colors.dart';

enum BottomNavTab { home, requests, notifications, profile }

class BottomNav extends StatelessWidget {
  const BottomNav({super.key, required this.currentTab});

  final BottomNavTab currentTab;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          _BottomNavItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            label: 'Inicio',
            selected: currentTab == BottomNavTab.home,
            onTap: () => _go(context, AppRoutes.home),
          ),
          _BottomNavItem(
            icon: Icons.description_outlined,
            selectedIcon: Icons.description,
            label: 'Solicitudes',
            selected: currentTab == BottomNavTab.requests,
            onTap: () => _go(context, AppRoutes.requests),
          ),
          _BottomNavItem(
            icon: Icons.notifications_none,
            selectedIcon: Icons.notifications,
            label: 'Alertas',
            selected: currentTab == BottomNavTab.notifications,
            onTap: () => _go(context, AppRoutes.notifications),
          ),
          _BottomNavItem(
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
            label: 'Perfil',
            selected: currentTab == BottomNavTab.profile,
            onTap: () => _go(context, AppRoutes.profile),
          ),
        ],
      ),
    );
  }

  void _go(BuildContext context, String route) {
    if (ModalRoute.of(context)?.settings.name == route) return;
    Navigator.pushReplacementNamed(context, route);
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : const Color(0xFF94A3B8);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? selectedIcon : icon, color: color, size: 23),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
