import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:volunteer/controllers/activity_controller.dart';
import 'package:volunteer/core/utils/formatters.dart';
import 'package:volunteer/data/models/registration.dart';
import 'package:volunteer/shared/constants/app_colors.dart';
import 'package:volunteer/shared/widgets/common_widgets.dart';
import 'package:volunteer/shared/widgets/primary_button.dart';
import 'package:volunteer/shared/widgets/sub_page_scaffold.dart';

class RegistrantsPage extends StatefulWidget {
  const RegistrantsPage({super.key});

  @override
  State<RegistrantsPage> createState() => _RegistrantsPageState();
}

class _RegistrantsPageState extends State<RegistrantsPage> {
  final _ctrl = Get.find<ActivityController>();
  late final String _activityId = Get.arguments as String;

  String _query = '';
  RegistrationStatus? _filter; // null = semua

  void _showDetail(Registration r) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(r.donorName,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                ),
                StatusPill.registration(r.status),
              ],
            ),
            const SizedBox(height: 14),
            _detail('Golongan darah', r.bloodType),
            _detail('Nomor telepon', r.phone),
            _detail('Terdaftar', Fmt.fullOf(r.createdAt)),
            const SizedBox(height: 20),
            PrimaryButton(
              text: 'Terima',
              onPressed: () {
                _ctrl.setRegistrantStatus(r.id, RegistrationStatus.accepted);
                Get.back();
              },
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () {
                  _ctrl.setRegistrantStatus(r.id, RegistrationStatus.rejected);
                  Get.back();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Tolak',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detail(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final a = _ctrl.byId(_activityId);
      if (a == null) {
        return const Scaffold(
          body: EmptyState(
            icon: Icons.event_busy_outlined,
            title: 'Kegiatan tidak ditemukan',
            message: 'Kegiatan ini mungkin sudah dihapus.',
          ),
        );
      }

      final all = _ctrl.registrantsOf(_activityId);
      final waiting =
          all.where((r) => r.status == RegistrationStatus.pending).length;
      final q = _query.trim().toLowerCase();
      final list = all.where((r) {
        final okQ = q.isEmpty || r.donorName.toLowerCase().contains(q);
        final okF = _filter == null || r.status == _filter;
        return okQ && okF;
      }).toList();

      return SubPageScaffold(
        title: 'Kelola pendaftar',
        subtitle: '${a.title} • ${Fmt.shortOf(a.startDateTime)}',
        children: [
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                    child: _stat('Total pendaftar', '${all.length}', false)),
                Expanded(child: _stat('Menunggu', '$waiting', true)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppSearchField(
            hint: 'Cari nama pendonor',
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              AppChoicePill(
                label: 'Semua',
                selected: _filter == null,
                onTap: () => setState(() => _filter = null),
              ),
              AppChoicePill(
                label: 'Menunggu',
                selected: _filter == RegistrationStatus.pending,
                onTap: () =>
                    setState(() => _filter = RegistrationStatus.pending),
              ),
              AppChoicePill(
                label: 'Diterima',
                selected: _filter == RegistrationStatus.accepted,
                onTap: () =>
                    setState(() => _filter = RegistrationStatus.accepted),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (list.isEmpty)
            const EmptyState(
              icon: Icons.people_outline,
              title: 'Belum ada pendaftar',
              message: 'Pendaftar akan muncul di sini.',
            )
          else
            for (final r in list)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  onTap: () => _showDetail(r),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${r.donorName} • ${r.bloodType}',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary)),
                            const SizedBox(height: 6),
                            Text('Terdaftar ${Fmt.shortOf(r.createdAt)}',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusPill.registration(r.status),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 8),
          const Text(
              'Pilih pendaftar untuk melihat detail dan mengubah status.',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      );
    });
  }

  Widget _stat(String label, String value, bool primary) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: primary ? AppColors.primaryColor : AppColors.textPrimary,
              )),
        ],
      );
}
