import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:volunteer/controllers/activity_controller.dart';
import 'package:volunteer/core/routes/app_routes.dart';
import 'package:volunteer/core/utils/formatters.dart';
import 'package:volunteer/shared/constants/app_colors.dart';
import 'package:volunteer/shared/widgets/common_widgets.dart';
import 'package:volunteer/shared/widgets/sub_page_scaffold.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ActivityController>();

    return SubPageScaffold(
      title: 'Riwayat donor',
      subtitle: 'Kegiatan yang pernah kamu daftarkan.',
      children: [
        Obx(() {
          final list = ctrl.myRegistrations;
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.history,
              title: 'Belum ada riwayat',
              message: 'Daftar kegiatan donor untuk melihat riwayatmu di sini.',
            );
          }
          return Column(
            children: [
              for (final r in list)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Builder(builder: (context) {
                    final a = ctrl.byId(r.activityId);
                    return AppCard(
                      onTap: a == null
                          ? null
                          : () => Get.toNamed(AppRoutes.activityDetail,
                              arguments: a.id),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(a?.title ?? 'Kegiatan telah dihapus',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary)),
                                const SizedBox(height: 6),
                                Text(
                                  a == null
                                      ? 'Terdaftar ${Fmt.shortOf(r.createdAt)}'
                                      : '${Fmt.shortOf(a.startDateTime)} • ${a.location}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusPill.registration(r.status),
                        ],
                      ),
                    );
                  }),
                ),
            ],
          );
        }),
      ],
    );
  }
}
