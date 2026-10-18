import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/utils/date_formatters.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../data/request_service.dart';
import '../domain/request_model.dart';
import '../domain/request_step_model.dart';

class RequestTrackingView extends StatelessWidget {
  const RequestTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)?.settings.arguments as String? ?? '1';
    final service = RequestService();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Seguimiento', showBack: true),
            Expanded(
              child: FutureBuilder(
                future: Future.wait([
                  service.getRequestById(id),
                  service.getRequestSteps(id),
                ]),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final request = snapshot.data![0] as RequestModel;
                  final steps = snapshot.data![1] as List<RequestStepModel>;
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                    children: [
                      Text(
                        request.title,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        request.code,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      for (var i = 0; i < steps.length; i++)
                        _TimelineItem(
                          step: steps[i],
                          isLast: i == steps.length - 1,
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

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.step, required this.isLast});

  final RequestStepModel step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final markerColor = step.isCompleted
        ? AppColors.primary
        : step.isCurrent
        ? AppColors.accent
        : const Color(0xFFE2E8F0);
    final markerIcon = step.isCompleted ? Icons.check : Icons.circle;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 42,
            child: Column(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: markerColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    markerIcon,
                    color: step.isCurrent ? Colors.white : Colors.white,
                    size: step.isCompleted ? 20 : 10,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.primary.withValues(alpha: 0.35),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 26),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: step.isCurrent
                      ? AppColors.primary
                      : Colors.transparent,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          step.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (step.isCurrent)
                        const Text(
                          'EN CURSO',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                    ],
                  ),
                  if (step.date != null) ...[
                    const SizedBox(height: 8),
                    _MetaLine(
                      icon: Icons.calendar_today_outlined,
                      text: DateFormatters.dateTime(step.date!),
                    ),
                  ],
                  if (step.responsible != null) ...[
                    const SizedBox(height: 6),
                    _MetaLine(
                      icon: Icons.person_outline,
                      text: step.responsible!,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 15),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
