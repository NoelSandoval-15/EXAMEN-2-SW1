import 'package:flutter/material.dart';

import '../../../config/routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../../../shared/widgets/request_card.dart';
import '../data/request_service.dart';
import '../domain/request_model.dart';
import 'chat_assistant_view.dart';

class RequestListView extends StatefulWidget {
  const RequestListView({super.key});

  @override
  State<RequestListView> createState() => _RequestListViewState();
}

class _RequestListViewState extends State<RequestListView> {
  bool _showFinished = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Mis Solicitudes'),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
              child: _SegmentedTabs(
                showFinished: _showFinished,
                onChanged: (value) => setState(() => _showFinished = value),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<RequestModel>>(
                future: RequestService().getClientRequests(),
                builder: (context, snapshot) {
                  final requests = (snapshot.data ?? [])
                      .where((request) => request.isFinished == _showFinished)
                      .toList();
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      return RequestCard(
                        request: request,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.requestDetail,
                          arguments: request.id,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const BottomNav(currentTab: BottomNavTab.requests),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ChatAssistantView.show(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.smart_toy, color: Colors.white),
      ),
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({required this.showFinished, required this.onChanged});

  final bool showFinished;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TabButton(
            label: 'Activos (2)',
            selected: !showFinished,
            onTap: () => onChanged(false),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TabButton(
            label: 'Finalizados (1)',
            selected: showFinished,
            onTap: () => onChanged(true),
          ),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: selected
              ? AppColors.primary
              : const Color(0xFFF1F3F6),
          foregroundColor: selected ? Colors.white : AppColors.textPrimary,
          side: BorderSide(
            color: selected ? const Color(0xFF0F172A) : Colors.transparent,
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        ),
      ),
    );
  }
}
