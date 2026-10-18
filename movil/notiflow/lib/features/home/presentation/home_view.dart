import 'package:flutter/material.dart';

import '../../../config/routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../features/notifications/data/notification_service.dart';
import '../../../features/notifications/domain/notification_model.dart';
import '../../../features/requests/data/request_service.dart';
import '../../../features/requests/domain/request_model.dart';
import '../../../features/requests/presentation/chat_assistant_view.dart';
import '../../../shared/utils/date_formatters.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../../../shared/widgets/primary_button.dart';

import '../../../core/storage/token_storage.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TokenStorage _tokenStorage = TokenStorage();
  late Future<List<RequestModel>> _requestsFuture;
  late Future<List<NotificationModel>> _notificationsFuture;
  String _userName = 'Usuario';

  @override
  void initState() {
    super.initState();
    _requestsFuture = RequestService().getClientRequests();
    _notificationsFuture = NotificationService().getClientNotifications();
    _loadUserInfo();
  }

  void _loadUserInfo() async {
    final name = await _tokenStorage.getNombre();
    if (mounted && name != null) {
      setState(() {
        _userName = name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: _userName,
              subtitle: 'Bienvenido',
              showNotification: true,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                children: [
                  FutureBuilder<List<RequestModel>>(
                    future: _requestsFuture,
                    builder: (context, snapshot) {
                      final request = snapshot.data?.first;
                      if (request == null) return const SizedBox(height: 220);
                      return _ActiveRequestCard(request: request);
                    },
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 1,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                    ),
                    child: InkWell(
                      onTap: () => ChatAssistantView.show(context),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.smart_toy_outlined,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Iniciar Trámite con Asistente',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Nuestro bot te guiará paso a paso',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const _SectionTitle('Accesos rapidos'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _ShortcutCard(
                          icon: Icons.description_outlined,
                          label: 'Mis Solicitudes',
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.requests),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ShortcutCard(
                          icon: Icons.person_outline,
                          label: 'Mi Perfil',
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.profile),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const _SectionTitle('Actividad reciente'),
                  const SizedBox(height: 10),
                  FutureBuilder<List<NotificationModel>>(
                    future: _notificationsFuture,
                    builder: (context, snapshot) {
                      final notifications = snapshot.data ?? [];
                      return Column(
                        children: notifications.take(2).map<Widget>((notification) {
                          return _ActivityCard(
                            title: notification.title,
                            message: notification.message,
                            date: DateFormatters.dateTime(
                              notification.createdAt,
                            ),
                            unread: !notification.isRead,
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
            const BottomNav(currentTab: BottomNavTab.home),
          ],
        ),
      ),
    );
  }
}

class _ActiveRequestCard extends StatelessWidget {
  const _ActiveRequestCard({required this.request});

  final RequestModel request;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        color: Color(0xFF3267D9),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TRAMITE ACTIVO',
            style: TextStyle(
              color: Color(0xFFC7D2FE),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            request.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  request.status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                request.code,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: request.progress,
              minHeight: 5,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${(request.progress * 100).round()}% completado',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Oficina actual: ${request.currentOffice}',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Ver detalles',
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.requestDetail,
              arguments: request.id,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 108,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF3FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.title,
    required this.message,
    required this.date,
    required this.unread,
  });

  final String title;
  final String message;
  final String date;
  final bool unread;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: unread ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 5),
                Text(message, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 7),
                Text(
                  date,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (unread)
            const Icon(Icons.circle, color: AppColors.primary, size: 8),
        ],
      ),
    );
  }
}
