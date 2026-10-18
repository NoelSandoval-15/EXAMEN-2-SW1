import 'package:flutter/material.dart';

import '../../../config/routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/utils/date_formatters.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/status_badge.dart';
import '../data/request_service.dart';
import '../domain/request_model.dart';

class RequestDetailView extends StatelessWidget {
  const RequestDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)?.settings.arguments as String? ?? '1';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Detalle de Solicitud', showBack: true),
            Expanded(
              child: FutureBuilder<RequestModel>(
                future: RequestService().getRequestById(id),
                builder: (context, snapshot) {
                  final request = snapshot.data;
                  if (request == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                      _HeroDetailCard(request: request),
                      const SizedBox(height: 16),
                      _InfoCard(request: request),
                      const SizedBox(height: 18),
                      PrimaryButton(
                        label: 'Ver Seguimiento Completo',
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.requestTracking,
                          arguments: request.id,
                        ),
                      ),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        label: 'Contactar Soporte',
                        backgroundColor: const Color(0xFFF1F3F6),
                        foregroundColor: AppColors.textPrimary,
                        onPressed: () {},
                      ),
                    ],
                  );
                },
              ),
            ),
            const BottomNav(currentTab: BottomNavTab.requests),
          ],
        ),
      ),
    );
  }
}

class _HeroDetailCard extends StatelessWidget {
  const _HeroDetailCard({required this.request});

  final RequestModel request;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            request.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
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
                  color: Colors.white.withValues(alpha: 0.2),
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
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.request});

  final RequestModel request;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'INFORMACION',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 18),
            _InfoLine(
              label: 'Fecha de inicio',
              value: DateFormatters.shortDate(request.startDate),
            ),
            _InfoLine(label: 'Oficina actual', value: request.currentOffice),
            _InfoLine(label: 'Responsable', value: request.responsible),
            _InfoLine(label: 'Descripcion', value: request.description),
            if (request.isFinished) ...[
              const SizedBox(height: 8),
              StatusBadge(status: request.status),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
