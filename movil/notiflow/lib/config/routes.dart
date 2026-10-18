import 'package:flutter/material.dart';

import '../features/auth/presentation/login_view.dart';
import '../features/home/presentation/home_view.dart';
import '../features/notifications/presentation/notifications_view.dart';
import '../features/profile/presentation/profile_view.dart';
import '../features/requests/presentation/chat_assistant_view.dart';
import '../features/requests/presentation/request_detail_view.dart';
import '../features/requests/presentation/request_list_view.dart';
import '../features/requests/presentation/request_tracking_view.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String requests = '/requests';
  static const String requestDetail = '/requests/detail';
  static const String requestTracking = '/requests/tracking';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String chatAssistant = '/chat-assistant';

  static Map<String, WidgetBuilder> get routes {
    return {
      login: (_) => const LoginView(),
      home: (_) => const HomeView(),
      requests: (_) => const RequestListView(),
      requestDetail: (_) => const RequestDetailView(),
      requestTracking: (_) => const RequestTrackingView(),
      notifications: (_) => const NotificationsView(),
      profile: (_) => const ProfileView(),
      chatAssistant: (_) => const Scaffold(body: ChatAssistantView()),
    };
  }
}
