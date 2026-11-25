import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:volunteer/controllers/profile_controller.dart';
import 'package:volunteer/entities/role.dart';
import 'package:volunteer/pages/organizer/organizer_bottom_navigation_bar.dart';
import 'package:volunteer/core/utils/validators.dart';
import 'package:volunteer/shared/constants/app_colors.dart';
import 'package:volunteer/shared/widgets/app_snackbar.dart';
import 'package:volunteer/shared/widgets/custom_text_field.dart';
import 'package:volunteer/shared/widgets/form_widgets.dart';
import 'package:volunteer/shared/widgets/primary_button.dart';
import 'package:volunteer/shared/widgets/sub_page_scaffold.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _profile = Get.find<ProfileController>();

  late final _name = TextEditingController(text: _profile.name.value);
  late final _email = TextEditingController(text: _profile.email.value);
  late final _phone = TextEditingController(text: _profile.phone.value);
  late final _notes = TextEditingController(text: _profile.medicalNotes.value);
  late String _blood = _profile.bloodType.value;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_blood.isEmpty) {
      showAppSnack('Pilih golongan darah kamu.', error: true);
      return;
    }
    _profile.updateProfile(
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      bloodType: _blood,
      notes: _notes.text.trim(),
    );
    try {
      await _profile.saveProfile();
      if (!mounted) return;
      Get.back();
      showAppSnack('Profil berhasil diperbarui.');
    } catch (e) {
      if (!mounted) return;
      showAppSnack('Gagal memperbarui profil: $e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: 'Edit profil',
      subtitle: _profile.role.value == Role.organizer
          ? 'Pastikan informasi akun selalu akurat.'
          : 'Pastikan informasi pendonor selalu akurat.',
      bottomNavigationBar: _profile.role.value == Role.organizer
          ? const OrganizerBottomNavigationBar(currentIndex: 3)
          : null,
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'Nama lengkap',
                hint: 'Nama sesuai identitas',
                controller: _name,
                validator: (v) => Validators.required(v, 'Nama lengkap'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Email',
                hint: 'nama@email.com',
                controller: _email,
                readOnly: true,
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
              const Text('Golongan darah',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              BloodTypeSelector(
                selected: [_blood],
                onTap: (t) => setState(() => _blood = t),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Penyakit bawaan (opsional)',
                hint: 'Tuliskan jika ada',
                controller: _notes,
              ),
              const SizedBox(height: 24),
              PrimaryButton(text: 'Simpan perubahan', onPressed: _save),
              const SizedBox(height: 12),
              const Center(
                child: Text('Perubahan profil akan disimpan ke akun kamu.',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
