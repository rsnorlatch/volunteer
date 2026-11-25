import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:volunteer/controllers/activity_controller.dart';
import 'package:volunteer/controllers/profile_controller.dart';
import 'package:volunteer/core/routes/app_routes.dart';
import 'package:volunteer/core/utils/formatters.dart';
import 'package:volunteer/entities/role.dart';
import 'package:volunteer/pages/auth/auth_controller.dart';
import 'package:volunteer/pages/organizer/organizer_bottom_navigation_bar.dart';
import 'package:volunteer/shared/constants/app_colors.dart';
import 'package:volunteer/shared/widgets/app_snackbar.dart';
import 'package:volunteer/shared/widgets/common_widgets.dart';
import 'package:volunteer/shared/widgets/profile_photo_image.dart';
import 'package:volunteer/shared/widgets/sub_page_scaffold.dart';
import 'package:volunteer/services/profile_photo_errors.dart';

enum _ProfilePhotoAction { gallery, file, camera, remove }

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _profile = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await _profile.loadProfilePhoto();
        await _profile.loadDonorHistory();
      } on PlatformException {
        if (mounted) {
          showAppSnack('Penyimpanan foto tidak dapat diakses.', error: true);
        }
      } on ProfilePhotoStorageException catch (error) {
        if (mounted) showAppSnack(error.message, error: true);
      }
    });
  }

  Future<void> _changePhoto(
    BuildContext context,
    ProfileController profile,
  ) async {
    if (profile.isPhotoLoading.value) return;
    final supportsCamera = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    final action = await showModalBottomSheet<_ProfilePhotoAction>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const ListTile(
              title: Text(
                'Foto profil',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari galeri'),
              onTap: () => Navigator.pop(context, _ProfilePhotoAction.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.folder_open_outlined),
              title: const Text('Pilih file gambar'),
              onTap: () => Navigator.pop(context, _ProfilePhotoAction.file),
            ),
            if (supportsCamera)
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Ambil foto'),
                onTap: () => Navigator.pop(context, _ProfilePhotoAction.camera),
              ),
            if (profile.avatarPath.value != null)
              ListTile(
                leading:
                    const Icon(Icons.delete_outline, color: AppColors.danger),
                title: const Text('Hapus foto'),
                onTap: () => Navigator.pop(context, _ProfilePhotoAction.remove),
              ),
          ],
        ),
      ),
    );

    if (!context.mounted) return;
    if (action == null) return;
    if (action == _ProfilePhotoAction.remove) {
      try {
        await profile.removeProfilePhoto();
        showAppSnack('Foto profil dihapus.');
      } on PlatformException {
        showAppSnack('Penyimpanan foto tidak dapat diakses.', error: true);
      } on ProfilePhotoStorageException catch (error) {
        showAppSnack(error.message, error: true);
      }
      return;
    }

    try {
      final updated = action == _ProfilePhotoAction.file
          ? await profile.updateProfilePhotoFromFile()
          : await profile.updateProfilePhoto(
              action == _ProfilePhotoAction.camera
                  ? ImageSource.camera
                  : ImageSource.gallery,
            );
      if (updated && context.mounted) {
        showAppSnack('Foto profil berhasil diperbarui.', success: true);
      }
    } on PlatformException {
      showAppSnack(
        action == _ProfilePhotoAction.camera
            ? 'Kamera tidak tersedia atau izinnya ditolak.'
            : 'Pemilih gambar tidak dapat dibuka.',
        error: true,
      );
    } on ProfilePhotoStorageException catch (error) {
      showAppSnack(error.message, error: true);
    }
  }

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
    final profile = _profile;
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
                      Obx(() {
                        final photoPath = profile.avatarPath.value;
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            GestureDetector(
                              onTap: () => _changePhoto(context, profile),
                              child: Container(
                                width: 76,
                                height: 76,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryLight,
                                  shape: BoxShape.circle,
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: photoPath == null
                                    ? Text(profile.initial,
                                        style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primaryColor))
                                    : profilePhotoImage(
                                        photoPath,
                                        fallback: Text(
                                          profile.initial,
                                          style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primaryColor,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Obx(
                                () => CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.white,
                                  child: profile.isPhotoLoading.value
                                      ? const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.camera_alt,
                                          size: 16,
                                          color: AppColors.primaryColor,
                                        ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
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
                              profile.role.value == Role.organizer
                                  ? 'Penyelenggara • Bergabung ${profile.joinedYear}'
                                  : 'Pendonor • Bergabung ${profile.joinedYear}',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 10),
                            StatusPill(
                              profile.role.value == Role.organizer
                                  ? 'Penyelenggara aktif'
                                  : 'Pendonor aktif',
                              tone: PillTone.success,
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
              final done = profile.applicationCount.value;
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
            if (profile.role.value == Role.donor) ...[
              Obx(() {
                if (profile.isHistoryLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (profile.donorHistory.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.history,
                            size: 48, color: AppColors.textSecondary),
                        SizedBox(height: 12),
                        Text('Belum ada riwayat donor',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary)),
                        SizedBox(height: 6),
                        Text('Kegiatan donor yang kamu daftarkan akan muncul di sini.',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Riwayat donor',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 12),
                    ...profile.donorHistory.map((entry) {
                      final a = entry.activity;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          onTap: a == null
                              ? null
                              : () => Get.toNamed(AppRoutes.activityDetail,
                                  arguments: a.id),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Icon(Icons.event,
                                      color: AppColors.primaryColor),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(entry.activityTitle,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textPrimary)),
                                    const SizedBox(height: 4),
                                    Text(
                                      entry.activityLocation,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      entry.activityDate == null
                                          ? '-'
                                          : '${Fmt.shortOf(entry.activityDate!)}',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              StatusPill.registration(entry.registration.status),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                );
              }),
              const SizedBox(height: 20),
            ],
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
