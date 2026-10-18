import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/utils/date_formatters.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../data/notification_service.dart';
import '../domain/notification_model.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  late Future<List<NotificationModel>> _notificationsFuture;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _refreshNotifications();
  }

  void _refreshNotifications() {
    setState(() {
      _notificationsFuture = _notificationService.getClientNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Notificaciones'),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _refreshNotifications();
                },
                child: FutureBuilder<List<NotificationModel>>(
                  future: _notificationsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final notifications = snapshot.data ?? [];
                    if (notifications.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 100),
                          Center(
                            child: Text(
                              'No tienes notificaciones',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      );
                    }
                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return _NotificationCard(
                          notification: notification,
                          onTap: () async {
                            if (!notification.isRead) {
                              final success = await _notificationService.markAsRead(notification.id);
                              if (success) {
                                _refreshNotifications();
                              }
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            const BottomNav(currentTab: BottomNavTab.notifications),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification, required this.onTap});

  final NotificationModel notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = !notification.isRead;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: unread ? AppColors.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.message,
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          DateFormatters.dateTime(notification.createdAt),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (unread)
                const Icon(Icons.circle, color: AppColors.primary, size: 8),
            ],
          ),
        ),
      ),
    );
  }
}
