import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:volunteer/controllers/activity_controller.dart';
import 'package:volunteer/controllers/profile_controller.dart';
import 'package:volunteer/core/routes/app_routes.dart';
import 'package:volunteer/core/utils/formatters.dart';
import 'package:volunteer/data/models/activity_model.dart';
import 'package:volunteer/pages/organizer/organizer_bottom_navigation_bar.dart';
import 'package:volunteer/shared/constants/app_colors.dart';
import 'package:volunteer/shared/widgets/app_snackbar.dart';
import 'package:volunteer/shared/widgets/common_widgets.dart';
import 'package:volunteer/shared/widgets/primary_button.dart';
import 'package:volunteer/shared/widgets/sub_page_scaffold.dart';

class ManageActivitiesPage extends StatefulWidget {
  const ManageActivitiesPage({super.key});

  @override
  State<ManageActivitiesPage> createState() => _ManageActivitiesPageState();
}

class _ManageActivitiesPageState extends State<ManageActivitiesPage> {
  final _ctrl = Get.find<ActivityController>();
  final _profile = Get.find<ProfileController>();
  String? _selectedId;

  Future<void> _confirmDelete(BloodActivityModel a) async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Hapus kegiatan?'),
        content: Text('"${a.title}" akan dihapus beserta data pendaftarnya.'),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Batal')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child:
                const Text('Hapus', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok == true) {
      if (_ctrl.deleteActivity(a.id)) {
        showAppSnack('Kegiatan dihapus.');
      } else {
        showAppSnack('Kegiatan tidak dapat dihapus.', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: 'Kelola kegiatan',
      subtitle: 'Atur kegiatan donor yang kamu selenggarakan.',
      bottomNavigationBar: const OrganizerBottomNavigationBar(currentIndex: 1),
      children: [
        PrimaryButton(
          text: 'Buat kegiatan baru',
          icon: Icons.add,
          onPressed: () => Get.toNamed(AppRoutes.createActivity),
        ),
        const SizedBox(height: 20),
        Obx(() {
          final mine = _ctrl.activitiesOf(_profile.email.value);
          if (mine.isEmpty) {
            return const EmptyState(
              icon: Icons.event_note_outlined,
              title: 'Belum ada kegiatan',
              message: 'Buat kegiatan donor darah pertamamu.',
            );
          }
          final selected =
              mine.firstWhereOrNull((a) => a.id == _selectedId) ?? mine.first;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final a in mine)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    onTap: () => setState(() => _selectedId = a.id),
                    borderColor:
                        a.id == selected.id ? AppColors.primaryColor : null,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.title,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary)),
                              const SizedBox(height: 6),
                              Text(
                                  '${Fmt.shortOf(a.startDateTime)} • ${a.registered} pendaftar',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusPill(
                          _ctrl.isActive(a) ? 'Aktif' : 'Selesai',
                          tone: _ctrl.isActive(a)
                              ? PillTone.success
                              : PillTone.neutral,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              const Text('Aksi pada kegiatan',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              AppCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(selected.title,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        AppChoicePill(
                          label: 'Edit',
                          selected: false,
                          onTap: () => Get.toNamed(AppRoutes.editActivity,
                              arguments: selected.id),
                        ),
                        AppChoicePill(
                          label: 'Pendaftar',
                          selected: false,
                          onTap: () => Get.toNamed(AppRoutes.manageRegistrants,
                              arguments: selected.id),
                        ),
                        AppChoicePill(
                          label: 'Hapus',
                          selected: false,
                          onTap: () => _confirmDelete(selected),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text('Hapus kegiatan memerlukan konfirmasi.',
                  style:
                      TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          );
        }),
      ],
    );
  }
}
