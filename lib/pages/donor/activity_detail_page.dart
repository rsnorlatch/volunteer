import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:volunteer/controllers/activity_controller.dart';
import 'package:volunteer/core/routes/app_routes.dart';
import 'package:volunteer/core/utils/formatters.dart';
import 'package:volunteer/shared/constants/app_colors.dart';
import 'package:volunteer/shared/widgets/common_widgets.dart';
import 'package:volunteer/shared/widgets/primary_button.dart';

class ActivityDetailPage extends StatelessWidget {
  const ActivityDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final id = Get.arguments as String;
    final ctrl = Get.find<ActivityController>();

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          final a = ctrl.byId(id);
          if (a == null) {
            return const EmptyState(
              icon: Icons.event_busy_outlined,
              title: 'Kegiatan tidak ditemukan',
              message: 'Kegiatan ini mungkin sudah dihapus.',
            );
          }
          final registered = ctrl.isRegistered(id);
          final full = a.registered >= a.quota;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => Get.back(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('‹ Kembali ke kegiatan',
                        style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Icon(Icons.favorite,
                        size: 64, color: AppColors.primaryColor),
                  ),
                ),
                const SizedBox(height: 16),
                StatusPill(Fmt.badge(a.bloodGroups)),
                const SizedBox(height: 14),
                Text(a.title,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                Text(a.organizer,
                    style: const TextStyle(
                        fontSize: 15, color: AppColors.textSecondary)),
                const SizedBox(height: 20),
                _InfoTile(
                  icon: Icons.access_time,
                  title: Fmt.longDate(a.date),
                  subtitle: '${Fmt.timeRange(a.time)} WIB',
                ),
                const SizedBox(height: 10),
                _InfoTile(
                  icon: Icons.my_location,
                  title: a.location,
                  subtitle: 'Diselenggarakan oleh ${a.organizer}',
                ),
                const SizedBox(height: 10),
                _InfoTile(
                  icon: Icons.favorite,
                  title: 'Golongan darah',
                  subtitle: Fmt.acceptsAll(a.bloodGroups)
                      ? 'Semua golongan diterima'
                      : a.bloodGroups,
                ),
                const SizedBox(height: 10),
                _InfoTile(
                  icon: Icons.groups_outlined,
                  title: 'Kuota pendonor',
                  subtitle: '${a.registered} dari ${a.quota} terisi',
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: registered
                      ? 'Sudah terdaftar'
                      : (full ? 'Kuota penuh' : 'Daftar sebagai pendonor'),
                  onPressed: (registered || full)
                      ? null
                      : () =>
                          Get.toNamed(AppRoutes.registration, arguments: id),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text('Pendaftaran dapat dibatalkan sebelum acara.',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile(
      {required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
