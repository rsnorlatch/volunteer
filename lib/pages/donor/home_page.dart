import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:volunteer/controllers/activity_controller.dart';
import 'package:volunteer/controllers/notification_controller.dart';
import 'package:volunteer/controllers/profile_controller.dart';
import 'package:volunteer/core/routes/app_routes.dart';
import 'package:volunteer/core/utils/formatters.dart';
import 'package:volunteer/pages/donor/shell_controller.dart';
import 'package:volunteer/shared/constants/app_colors.dart';
import 'package:volunteer/shared/widgets/activity_card.dart';
import 'package:volunteer/shared/widgets/common_widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = Get.find<ProfileController>();
    final activity = Get.find<ActivityController>();
    final notif = Get.find<NotificationController>();
    final shell = Get.find<ShellController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${Fmt.greeting()},',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 14)),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                          '${profile.name.value} 👋',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        )),
                  ],
                ),
              ),
              Obx(() => Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () => Get.toNamed(AppRoutes.notifications),
                        icon: const Icon(Icons.notifications_none_rounded,
                            color: AppColors.textPrimary),
                      ),
                      if (notif.unreadCount > 0)
                        Positioned(
                          right: 10,
                          top: 10,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(
                                color: AppColors.primaryColor,
                                shape: BoxShape.circle),
                          ),
                        ),
                    ],
                  )),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Setetes darah, sejuta harapan',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                const Text('Jadilah alasan seseorang punya kesempatan hidup.',
                    style: TextStyle(color: Colors.white, fontSize: 13)),
                const SizedBox(height: 18),
                SizedBox(
                  width: 170,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () => shell.goTo(1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryColor,
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Cari kegiatan',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Kegiatan terdekat',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              TextButton(
                onPressed: () => shell.goTo(1),
                child: const Text('Lihat semua',
                    style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() {
            final list = activity.upcomingActivities.take(2).toList();
            if (list.isEmpty) {
              return const EmptyState(
                icon: Icons.event_busy_outlined,
                title: 'Belum ada kegiatan',
                message: 'Kegiatan donor darah akan muncul di sini.',
              );
            }
            return Column(
              children: [
                for (final a in list)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ActivityCard(
                      activity: a,
                      onTap: () => Get.toNamed(AppRoutes.activityDetail,
                          arguments: a.id),
                    ),
                  ),
              ],
            );
          }),
          const SizedBox(height: 16),
          const Text('Aksi cepat',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.my_location,
                  label: 'Cari lokasi',
                  onTap: () => shell.goTo(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickAction(
                  icon: Icons.event_note_outlined,
                  label: 'Kegiatan',
                  onTap: () => shell.goTo(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickAction(
                  icon: Icons.history,
                  label: 'Riwayat',
                  onTap: () => Get.toNamed(AppRoutes.history),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction(
      {required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 22),
          const SizedBox(height: 12),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
