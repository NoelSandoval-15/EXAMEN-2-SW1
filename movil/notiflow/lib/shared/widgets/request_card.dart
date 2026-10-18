import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../features/requests/domain/request_model.dart';
import '../utils/date_formatters.dart';
import 'status_badge.dart';

class RequestCard extends StatelessWidget {
  const RequestCard({super.key, required this.request, required this.onTap});

  final RequestModel request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      request.title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                request.code,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 12),
              StatusBadge(status: request.status),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    'Inicio: ${DateFormatters.shortDate(request.startDate)}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      request.currentOffice,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
