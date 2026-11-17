import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:volunteer/controllers/activity_controller.dart';
import 'package:volunteer/core/routes/app_routes.dart';
import 'package:volunteer/shared/widgets/activity_card.dart';
import 'package:volunteer/shared/widgets/common_widgets.dart';
import 'package:volunteer/shared/widgets/sub_page_scaffold.dart';

class ActivityListPage extends StatelessWidget {
  const ActivityListPage({super.key});

  static String _label(ActivityFilter f) => switch (f) {
        ActivityFilter.all => 'Semua',
        ActivityFilter.nearest => 'Terdekat',
        ActivityFilter.weekend => 'Akhir pekan',
      };

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ActivityController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            title: 'Kegiatan donor',
            subtitle: 'Temukan kegiatan donor darah di sekitarmu.',
          ),
          const SizedBox(height: 20),
          AppSearchField(
            hint: 'Cari nama kegiatan atau lokasi',
            onChanged: (v) => ctrl.query.value = v,
          ),
          const SizedBox(height: 14),
          Obx(() => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final f in ActivityFilter.values)
                    AppChoicePill(
                      label: _label(f),
                      selected: ctrl.filter.value == f,
                      onTap: () => ctrl.filter.value = f,
                    ),
                ],
              )),
          const SizedBox(height: 18),
          Obx(() {
            final list = ctrl.visibleActivities;
            if (list.isEmpty) {
              return const EmptyState(
                icon: Icons.search_off_rounded,
                title: 'Kegiatan tidak ditemukan',
                message: 'Coba ubah kata kunci atau filter.',
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
        ],
      ),
    );
  }
}
