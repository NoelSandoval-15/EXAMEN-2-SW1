import 'package:flutter/material.dart';

import '../../../config/routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/storage/token_storage.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../../../shared/widgets/primary_button.dart';
import '../data/profile_service.dart';
import '../domain/profile_model.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Mi Perfil'),
            Expanded(
              child: FutureBuilder<ProfileModel?>(
                future: ProfileService().getProfile(),
                builder: (context, snapshot) {
                  final profile = snapshot.data;
                  if (profile == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 42,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            profile.fullName.characters.first,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          profile.fullName,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Center(
                        child: Text(
                          'Cliente',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      _ProfileInfoCard(profile: profile),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: 'Editar Informacion',
                        backgroundColor: const Color(0xFFF1F3F6),
                        foregroundColor: AppColors.textPrimary,
                        onPressed: () {},
                      ),
                      const SizedBox(height: 10),
                      PrimaryButton(
                        label: 'Cerrar Sesion',
                        backgroundColor: AppColors.danger,
                        onPressed: () async {
                          await TokenStorage().clear();
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.login,
                            );
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            const BottomNav(currentTab: BottomNavTab.profile),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard({required this.profile});

  final ProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'INFORMACION PERSONAL',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 18),
            _InfoLine(
              label: 'Documento de Identidad',
              value: profile.documentNumber ?? '-',
            ),
            _InfoLine(label: 'Correo Electronico', value: profile.email),
            _InfoLine(label: 'Telefono', value: profile.phone ?? '-'),
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
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
