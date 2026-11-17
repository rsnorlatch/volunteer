import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:volunteer/controllers/activity_controller.dart';
import 'package:volunteer/core/routes/app_routes.dart';
import 'package:volunteer/core/utils/formatters.dart';
import 'package:volunteer/pages/donor/shell_controller.dart';
import 'package:volunteer/shared/constants/app_colors.dart';
import 'package:volunteer/shared/widgets/common_widgets.dart';
import 'package:volunteer/shared/widgets/primary_button.dart';
import 'package:volunteer/shared/widgets/sub_page_scaffold.dart';

class RegistrationStatusPage extends StatelessWidget {
  const RegistrationStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final regId = Get.arguments as String;
    final ctrl = Get.find<ActivityController>();

    return SubPageScaffold(
      title: 'Pendaftaran berhasil',
      subtitle: 'Kamu sudah terdaftar pada kegiatan donor.',
      children: [
        Obx(() {
          final reg = ctrl.registrations.firstWhereOrNull((r) => r.id == regId);
          if (reg == null) return const SizedBox.shrink();
          final a = ctrl.byId(reg.activityId);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.check_rounded,
                        size: 56, color: AppColors.success),
                    SizedBox(height: 10),
                    Text('Pendaftaran berhasil!',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.success)),
                    SizedBox(height: 8),
                    Text('Simpan jadwal dan datang tepat waktu.',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              AppCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a?.title ?? 'Kegiatan',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 6),
                          Text(
                            a == null
                                ? '-'
                                : '${Fmt.shortDate(a.date)} • ${a.location}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusPill.registration(reg.status),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              AppCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Status pendaftaran',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 6),
                          Text(reg.status.description,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    StatusPill.registration(reg.status),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Lihat kegiatan',
                onPressed: () {
                  Get.until((route) => route.settings.name == AppRoutes.home);
                  Get.find<ShellController>().goTo(1);
                },
              ),
              const SizedBox(height: 14),
              const Center(
                child: Text('Reminder akan dikirim sebelum kegiatan dimulai.',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ),
            ],
          );
        }),
      ],
    );
  }
}
