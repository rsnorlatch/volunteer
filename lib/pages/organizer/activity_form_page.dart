import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:volunteer/controllers/activity_controller.dart';
import 'package:volunteer/controllers/profile_controller.dart';
import 'package:volunteer/core/constants/app_constants.dart';
import 'package:volunteer/core/utils/formatters.dart';
import 'package:volunteer/core/utils/validators.dart';
import 'package:volunteer/data/models/activity.dart';
import 'package:volunteer/pages/organizer/organizer_bottom_navigation_bar.dart';
import 'package:volunteer/shared/constants/app_colors.dart';
import 'package:volunteer/shared/widgets/app_snackbar.dart';
import 'package:volunteer/shared/widgets/common_widgets.dart';
import 'package:volunteer/shared/widgets/custom_text_field.dart';
import 'package:volunteer/shared/widgets/form_widgets.dart';
import 'package:volunteer/shared/widgets/primary_button.dart';
import 'package:volunteer/shared/widgets/sub_page_scaffold.dart';

class ActivityFormPage extends StatefulWidget {
  const ActivityFormPage({super.key, this.isEdit = false});

  final bool isEdit;

  @override
  State<ActivityFormPage> createState() => _ActivityFormPageState();
}

class _ActivityFormPageState extends State<ActivityFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _ctrl = Get.find<ActivityController>();
  final _profile = Get.find<ProfileController>();

  final _title = TextEditingController();
  final _location = TextEditingController();
  final _quota = TextEditingController();

  BloodActivity? _existing;
  DateTime? _date;
  TimeOfDay? _start;
  TimeOfDay? _end;
  final Set<String> _groups = {};

  String? _dateErr;
  String? _timeErr;
  String? _groupErr;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      final a = _ctrl.byId(Get.arguments as String);
      _existing = a != null && _ctrl.canManageActivity(a.id) ? a : null;
      if (a != null) {
        _title.text = a.title;
        _location.text = a.location;
        _date = DateTime.tryParse(a.date);
        final parts = a.time.split('-');
        if (parts.length == 2) {
          _start = Fmt.parseTime(parts[0]);
          _end = Fmt.parseTime(parts[1]);
        }
        _groups.addAll(Fmt.acceptsAll(a.bloodGroups)
            ? AppConstants.bloodTypes
            : Fmt.groups(a.bloodGroups));
      }
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _quota.dispose();
    super.dispose();
  }

  int _minutes(TimeOfDay t) => t.hour * 60 + t.minute;

  Future<void> _pickDate() async {
    final n = DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    final first = (_date != null && _date!.isBefore(today)) ? _date! : today;
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? today,
      firstDate: first,
      lastDate: DateTime(n.year + 2),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _dateErr = null;
      });
    }
  }

  Future<void> _pickRange() async {
    final s = await showTimePicker(
      context: context,
      initialTime: _start ?? const TimeOfDay(hour: 9, minute: 0),
      helpText: 'JAM MULAI',
    );
    if (s == null || !mounted) return;
    final e = await showTimePicker(
      context: context,
      initialTime: _end ?? TimeOfDay(hour: (s.hour + 4) % 24, minute: s.minute),
      helpText: 'JAM SELESAI',
    );
    if (e == null) return;
    setState(() {
      _start = s;
      _end = e;
      _timeErr = null;
    });
  }

  /// Mode edit: "Waktu mulai" = tanggal + jam mulai.
  Future<void> _pickStart() async {
    await _pickDate();
    if (!mounted || _date == null) return;
    final s = await showTimePicker(
      context: context,
      initialTime: _start ?? const TimeOfDay(hour: 9, minute: 0),
      helpText: 'JAM MULAI',
    );
    if (s != null) {
      setState(() {
        _start = s;
        _timeErr = null;
      });
    }
  }

  Future<void> _pickEnd() async {
    final e = await showTimePicker(
      context: context,
      initialTime: _end ?? const TimeOfDay(hour: 13, minute: 0),
      helpText: 'JAM SELESAI',
    );
    if (e != null) {
      setState(() {
        _end = e;
        _timeErr = null;
      });
    }
  }

  void _toggleGroup(String t) {
    setState(() {
      _groups.contains(t) ? _groups.remove(t) : _groups.add(t);
      _groupErr = null;
    });
  }

  void _submit() {
    final formOk = _formKey.currentState!.validate();

    String? dateErr;
    String? timeErr;
    String? groupErr;
    if (_date == null) {
      dateErr =
          widget.isEdit ? 'Waktu mulai wajib diisi' : 'Tanggal wajib diisi';
    }
    if (_start == null || _end == null) {
      timeErr = widget.isEdit
          ? 'Waktu wajib diisi'
          : 'Jam mulai dan selesai wajib diisi';
    } else if (_minutes(_end!) <= _minutes(_start!)) {
      timeErr = 'Jam selesai harus setelah jam mulai';
    }
    if (_groups.isEmpty) groupErr = 'Pilih minimal satu golongan darah';

    setState(() {
      _dateErr = dateErr;
      _timeErr = timeErr;
      _groupErr = groupErr;
    });
    if (!formOk || dateErr != null || timeErr != null || groupErr != null) {
      return;
    }

    final groups = AppConstants.bloodTypes.where(_groups.contains).join(', ');
    final date = Fmt.isoDate(_date!);
    final time = '${Fmt.hhmm(_start!)} - ${Fmt.hhmm(_end!)}';

    if (widget.isEdit && _existing != null) {
      final updated = _ctrl.updateActivity(_existing!.copyWith(
        title: _title.text.trim(),
        location: _location.text.trim(),
        date: date,
        time: time,
        bloodGroups: groups,
      ));
      if (!updated) {
        showAppSnack('Kegiatan tidak dapat diperbarui.', error: true);
        return;
      }
      Get.back();
      showAppSnack('Kegiatan berhasil diperbarui.');
    } else {
      final quota = int.parse(_quota.text.replaceAll(RegExp(r'[^0-9]'), ''));
      final created = _ctrl.addActivity(BloodActivity.create(
        title: _title.text.trim(),
        location: _location.text.trim(),
        date: date,
        time: time,
        organizer: _profile.name.value,
        bloodGroups: groups,
        description: '',
        quota: quota,
      ));
      if (!created) {
        showAppSnack('Hanya penyelenggara yang dapat membuat kegiatan.',
            error: true);
        return;
      }
      Get.back();
      showAppSnack('Kegiatan berhasil dipublikasikan.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final edit = widget.isEdit;
    if (edit && _existing == null) {
      return Scaffold(
        body: const EmptyState(
          icon: Icons.event_busy_outlined,
          title: 'Kegiatan tidak ditemukan',
          message: 'Kegiatan ini mungkin sudah dihapus.',
        ),
      );
    }

    final dateText = _date == null ? null : Fmt.fullOf(_date!);

    return SubPageScaffold(
      title: edit ? 'Edit kegiatan donor' : 'Buat kegiatan',
      subtitle: edit
          ? 'Ubah detail kegiatan yang sudah dibuat.'
          : 'Lengkapi informasi kegiatan donor darah.',
      bottomNavigationBar: const OrganizerBottomNavigationBar(currentIndex: 1),
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'Nama kegiatan',
                hint: 'Contoh: Donor Darah Peduli Sesama',
                controller: _title,
                validator: (v) => Validators.required(v, 'Nama kegiatan'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: edit ? 'Alamat' : 'Lokasi',
                hint: 'Nama tempat dan alamat lengkap',
                controller: _location,
                validator: (v) =>
                    Validators.required(v, edit ? 'Alamat' : 'Lokasi'),
              ),
              const SizedBox(height: 16),
              if (edit) ...[
                PickerField(
                  label: 'Waktu mulai',
                  hint: 'Pilih tanggal dan jam mulai',
                  value: (dateText != null && _start != null)
                      ? '$dateText • ${Fmt.clock(_start!)}'
                      : null,
                  errorText: _dateErr,
                  onTap: _pickStart,
                ),
                const SizedBox(height: 16),
                PickerField(
                  label: 'Waktu selesai',
                  hint: 'Pilih jam selesai',
                  value: (dateText != null && _end != null)
                      ? '$dateText • ${Fmt.clock(_end!)}'
                      : null,
                  errorText: _timeErr,
                  onTap: _pickEnd,
                ),
              ] else ...[
                PickerField(
                  label: 'Tanggal kegiatan',
                  hint: 'Pilih tanggal',
                  value: dateText,
                  errorText: _dateErr,
                  onTap: _pickDate,
                ),
                const SizedBox(height: 16),
                PickerField(
                  label: 'Waktu',
                  hint: 'Jam mulai – jam selesai',
                  value: (_start != null && _end != null)
                      ? '${Fmt.clock(_start!)}–${Fmt.clock(_end!)}'
                      : null,
                  errorText: _timeErr,
                  onTap: _pickRange,
                ),
              ],
              const SizedBox(height: 16),
              Text(
                edit ? 'Golongan darah' : 'Golongan darah yang diterima',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),
              BloodTypeSelector(selected: _groups, onTap: _toggleGroup),
              if (_groupErr != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(_groupErr!,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.danger)),
                ),
              if (!edit) ...[
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Kuota pendonor',
                  hint: 'Contoh: 50 orang',
                  controller: _quota,
                  keyboardType: TextInputType.number,
                  validator: Validators.quota,
                ),
              ],
              const SizedBox(height: 28),
              PrimaryButton(
                text: edit ? 'Simpan perubahan' : 'Publikasikan kegiatan',
                onPressed: _submit,
              ),
              if (edit) ...[
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Penghapusan kegiatan tersedia di halaman kelola kegiatan.',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
