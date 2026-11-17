import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:volunteer/controllers/notification_controller.dart';
import 'package:volunteer/shared/constants/app_colors.dart';
import 'package:volunteer/shared/widgets/common_widgets.dart';
import 'package:volunteer/shared/widgets/sub_page_scaffold.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  static String _label(NotificationFilter f) => switch (f) {
        NotificationFilter.all => 'Semua',
        NotificationFilter.reminder => 'Pengingat',
        NotificationFilter.registration => 'Pendaftaran',
      };

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<NotificationController>();

    return SubPageScaffold(
      title: 'Notifikasi',
      subtitle: 'Pengingat dan pembaruan kegiatan donor.',
      children: [
        Obx(() => Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final f in NotificationFilter.values)
                  AppChoicePill(
                    label: _label(f),
                    selected: ctrl.filter.value == f,
                    onTap: () => ctrl.filter.value = f,
                  ),
              ],
            )),
        const SizedBox(height: 18),
        Obx(() {
          final list = ctrl.visible;
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_off_outlined,
              title: 'Belum ada notifikasi',
              message: 'Pengingat dan pembaruan akan muncul di sini.',
            );
          }
          return Column(
            children: [
              for (final n in list)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    onTap: () => ctrl.markRead(n.id),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n.title,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary)),
                              const SizedBox(height: 6),
                              Text(n.body,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        if (n.isNew) ...[
                          const SizedBox(width: 8),
                          const StatusPill('Baru'),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          );
        }),
        const SizedBox(height: 16),
        const Text('Pengaturan reminder',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        AppCard(
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ingatkan saya sebelum kegiatan',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary)),
                    SizedBox(height: 6),
                    Text('1 hari dan 3 hari sebelumnya',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Obx(() => InkWell(
                    onTap: () => ctrl.reminderOn.toggle(),
                    borderRadius: BorderRadius.circular(20),
                    child: StatusPill(
                      ctrl.reminderOn.value ? 'ON' : 'OFF',
                      tone: ctrl.reminderOn.value
                          ? PillTone.success
                          : PillTone.neutral,
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}
