import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:volunteer/controllers/activity_controller.dart';
import 'package:volunteer/controllers/profile_controller.dart';
import 'package:volunteer/core/routes/app_routes.dart';
import 'package:volunteer/data/models/registration.dart';
import 'package:volunteer/entities/role.dart';
import 'package:volunteer/pages/auth/auth_controller.dart';
import 'package:volunteer/pages/organizer/organizer_bottom_navigation_bar.dart';
import 'package:volunteer/shared/constants/app_colors.dart';
import 'package:volunteer/shared/widgets/app_snackbar.dart';
import 'package:volunteer/shared/widgets/common_widgets.dart';
import 'package:volunteer/shared/widgets/sub_page_scaffold.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _confirmLogout() async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text('Kamu perlu masuk lagi untuk mengakses akunmu.'),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Batal')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child:
                const Text('Keluar', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok == true) await Get.find<AuthController>().logout();
  }

  void _showHelp() {
    Get.dialog(
      AlertDialog(
        title: const Text('Bantuan & informasi'),
        content: const Text(
          'Volunteer - BloodDonor menghubungkan pendonor dengan kegiatan donor darah di sekitarmu.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Tutup'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = Get.find<ProfileController>();
    final act = Get.find<ActivityController>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Profil',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Profil saya',
              subtitle: 'Kelola informasi akun dan aktivitas kamu.',
            ),
            const SizedBox(height: 20),
            Obx(() => AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: Text(profile.initial,
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryColor)),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(profile.name.value,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary)),
                            const SizedBox(height: 6),
                            Text(
                              profile.isGuest.value
                                  ? 'Pendonor • Mode tamu'
                                  : profile.role.value == Role.organizer
                                      ? 'Penyelenggara • Bergabung ${profile.joinedYear}'
                                      : 'Pendonor • Bergabung ${profile.joinedYear}',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 10),
                            StatusPill(
                              profile.isGuest.value
                                  ? 'Tamu'
                                  : profile.role.value == Role.organizer
                                      ? 'Penyelenggara aktif'
                                      : 'Pendonor aktif',
                              tone: profile.isGuest.value
                                  ? PillTone.neutral
                                  : PillTone.success,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
            Obx(() {
              if (profile.role.value == Role.organizer) {
                final mine = act.activitiesOf(profile.email.value);
                final active = mine.where(act.isActive).length;
                final registrants = mine.fold<int>(
                  0,
                  (sum, activity) =>
                      sum + act.registrantsOf(activity.id).length,
                );
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _profileStat('Kegiatan aktif', '$active'),
                      ),
                      Expanded(
                        child: _profileStat('Total pendaftar', '$registrants'),
                      ),
                    ],
                  ),
                );
              }
              final done = act.myRegistrations
                  .where((r) => r.status == RegistrationStatus.accepted)
                  .length;
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total donor',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          Text('$done kali',
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryColor)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Donor berikutnya',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          Text(act.nextDonorLabel,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),
            _MenuItem('Data pribadi', () => Get.toNamed(AppRoutes.editProfile)),
            if (profile.role.value == Role.organizer)
              _MenuItem(
                'Kelola kegiatan',
                () => Get.toNamed(AppRoutes.manageActivities),
              )
            else
              _MenuItem('Riwayat donor', () => Get.toNamed(AppRoutes.history)),
            _MenuItem('Pengaturan akun',
                () => showAppSnack('Pengaturan akun segera hadir.')),
            _MenuItem('Bantuan & informasi', _showHelp),
            _MenuItem('Keluar', _confirmLogout),
          ],
        ),
      ),
      bottomNavigationBar: profile.role.value == Role.organizer
          ? const OrganizerBottomNavigationBar(currentIndex: 3)
          : null,
    );
  }
}

Widget _profileStat(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
      ),
      const SizedBox(height: 8),
      Text(
        value,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryColor,
        ),
      ),
    ],
  );
}

class _MenuItem extends StatelessWidget {
  const _MenuItem(this.label, this.onTap);

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
