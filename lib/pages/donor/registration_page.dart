import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:volunteer/controllers/activity_controller.dart';
import 'package:volunteer/controllers/profile_controller.dart';
import 'package:volunteer/core/routes/app_routes.dart';
import 'package:volunteer/core/utils/formatters.dart';
import 'package:volunteer/core/utils/validators.dart';
import 'package:volunteer/data/models/activity.dart';
import 'package:volunteer/shared/constants/app_colors.dart';
import 'package:volunteer/shared/widgets/app_snackbar.dart';
import 'package:volunteer/shared/widgets/common_widgets.dart';
import 'package:volunteer/shared/widgets/custom_text_field.dart';
import 'package:volunteer/shared/widgets/form_widgets.dart';
import 'package:volunteer/shared/widgets/primary_button.dart';
import 'package:volunteer/shared/widgets/sub_page_scaffold.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _ctrl = Get.find<ActivityController>();
  final _profile = Get.find<ProfileController>();

  late final BloodActivity? _activity = _ctrl.byId(Get.arguments as String);
  late final TextEditingController _name = TextEditingController(
      text: _profile.isGuest.value ? '' : _profile.name.value);
  late final TextEditingController _phone =
      TextEditingController(text: _profile.phone.value);

  late String _blood = _profile.bloodType.value;
  late final bool _bloodLocked = _profile.bloodType.value.isNotEmpty;
  bool _agree = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _submit() {
    final a = _activity;
    if (a == null) return;
    if (!_formKey.currentState!.validate()) return;
    if (_blood.isEmpty) {
      showAppSnack('Pilih golongan darah kamu.', error: true);
      return;
    }
    if (!_agree) {
      showAppSnack('Centang pernyataan kesehatan terlebih dahulu.',
          error: true);
      return;
    }
    final reg = _ctrl.register(
      a,
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      bloodType: _blood,
    );
    Get.offNamed(AppRoutes.registrationStatus, arguments: reg.id);
  }

  @override
  Widget build(BuildContext context) {
    final a = _activity;
    if (a == null) {
      return const Scaffold(
        body: EmptyState(
          icon: Icons.event_busy_outlined,
          title: 'Kegiatan tidak ditemukan',
          message: 'Kegiatan ini mungkin sudah dihapus.',
        ),
      );
    }

    return SubPageScaffold(
      title: 'Konfirmasi pendaftaran',
      subtitle: 'Periksa detail sebelum mendaftar kegiatan.',
      children: [
        AppCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(a.title,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text(a.location,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Text('${Fmt.shortDate(a.date)} • ${Fmt.timeRange(a.time)}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'Nama pendonor',
                hint: 'Nama sesuai identitas',
                controller: _name,
                validator: (v) => Validators.required(v, 'Nama pendonor'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Nomor telepon',
                hint: '08xxxxxxxxxx',
                controller: _phone,
                keyboardType: TextInputType.phone,
                validator: Validators.phone,
              ),
              const SizedBox(height: 16),
              const Text('Golongan darah kamu',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              if (_bloodLocked)
                Align(
                    alignment: Alignment.centerLeft, child: StatusPill(_blood))
              else
                BloodTypeSelector(
                  selected: [_blood],
                  onTap: (t) => setState(() => _blood = t),
                ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: Checkbox(
                        value: _agree,
                        activeColor: AppColors.success,
                        onChanged: (v) => setState(() => _agree = v ?? false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pernyataan kesehatan',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.success)),
                          SizedBox(height: 6),
                          Text('Saya menyatakan informasi kesehatan benar.',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(text: 'Konfirmasi pendaftaran', onPressed: _submit),
            ],
          ),
        ),
      ],
    );
  }
}
