import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:volunteer/controllers/activity_controller.dart';
import 'package:volunteer/controllers/profile_controller.dart';
import 'package:volunteer/core/routes/app_routes.dart';
import 'package:volunteer/core/utils/formatters.dart';
import 'package:volunteer/pages/auth/auth_controller.dart';
import 'package:volunteer/shared/constants/app_colors.dart';
import 'package:volunteer/shared/widgets/activity_card.dart';
import 'package:volunteer/shared/widgets/common_widgets.dart';
import 'package:volunteer/shared/widgets/primary_button.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = Get.find<ProfileController>();
    final ctrl = Get.find<ActivityController>();

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          final mine = ctrl.activitiesOf(profile.name.value);
          final active = mine.where(ctrl.isActive).length;
          final registrants = mine.fold<int>(0, (sum, a) => sum + a.registered);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('PANEL PENYELENGGARA',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: AppColors.primaryColor)),
                          const SizedBox(height: 12),
                          Text('Halo, ${profile.name.value}',
                              style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 6),
                          const Text('Kelola kegiatan donor darah kamu.',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Keluar',
                      onPressed: () => Get.find<AuthController>().logout(),
                      icon: const Icon(Icons.logout,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _Stat(
                          label: 'Kegiatan aktif',
                          value: '$active',
                          primary: true),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                        child:
                            _Stat(label: 'Pendaftar', value: '$registrants')),
                  ],
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  text: 'Buat kegiatan baru',
                  icon: Icons.add,
                  onPressed: () => Get.toNamed(AppRoutes.createActivity),
                ),
                const SizedBox(height: 26),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Kegiatan saya',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary)),
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.manageActivities),
                      child: const Text('Kelola',
                          style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (mine.isEmpty)
                  const EmptyState(
                    icon: Icons.event_note_outlined,
                    title: 'Belum ada kegiatan',
                    message: 'Buat kegiatan donor darah pertamamu.',
                  )
                else
                  for (final a in mine)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ActivityCard(
                        activity: a,
                        meta:
                            '${Fmt.shortOf(a.startDateTime)} • ${a.registered} pendaftar',
                        onTap: () => Get.toNamed(AppRoutes.manageRegistrants,
                            arguments: a.id),
                      ),
                    ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.primary = false});

  final String label;
  final String value;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          Text(value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: primary ? AppColors.primaryColor : AppColors.textPrimary,
              )),
        ],
      ),
    );
  }
}
