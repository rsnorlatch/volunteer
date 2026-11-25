import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:volunteer/data/models/donor_history_entry.dart';
import 'package:volunteer/entities/profile.dart';
import 'package:volunteer/entities/role.dart';
import 'package:volunteer/services/profile_photo_service.dart';
import 'package:volunteer/services/profile_service.dart';

class ProfileController extends GetxController {
  ProfileController({ProfilePhotoService? photoService})
      : _photoService = photoService ?? ProfilePhotoService();

  final ProfilePhotoService _photoService;
  final ProfileService _profileService = Get.find<ProfileService>();
  final name = 'Sahabat Donor'.obs;
  final email = ''.obs;
  final avatarPath = RxnString();
  final isPhotoLoading = false.obs;
  final phone = ''.obs;
  final bloodType = ''.obs;
  final medicalNotes = ''.obs;
  final role = Role.donor.obs;
  final isAuthenticated = false.obs;
  final joinedYear = DateTime.now().year;
  final isSaving = false.obs;
  final applicationCount = 0.obs;
  final donorHistory = <DonorHistoryEntry>[].obs;
  final isHistoryLoading = false.obs;

  String? _profileId;

  String get userKey => _profileId ?? email.value.toLowerCase();

  String get profileId => _profileId ?? '';

  String get initial {
    final n = name.value.trim();
    return n.isEmpty ? '?' : n[0].toUpperCase();
  }

  void setFromProfile(Profile p) {
    _profileId = p.id;
    name.value = p.username;
    email.value = p.email;
    avatarPath.value = null;
    role.value = p.role;
    phone.value = p.phone;
    bloodType.value = p.bloodType;
    medicalNotes.value = p.medicalNotes;
    isAuthenticated.value = true;
  }

  void clearSession() {
    _profileId = null;
    name.value = '';
    email.value = '';
    avatarPath.value = null;
    phone.value = '';
    bloodType.value = '';
    medicalNotes.value = '';
    role.value = Role.donor;
    isAuthenticated.value = false;
    applicationCount.value = 0;
    donorHistory.clear();
  }

  Future<void> saveProfile() async {
    if (_profileId == null) return;
    isSaving.value = true;
    try {
      await _profileService.updateProfileAsync(
        profileId: _profileId!,
        name: name.value,
        phone: phone.value,
        bloodType: bloodType.value,
        medicalNotes: medicalNotes.value,
      );
    } catch (e) {
      rethrow;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> loadDonorHistory() async {
    if (_profileId == null) return;
    isHistoryLoading.value = true;
    try {
      donorHistory.assignAll(
        await _profileService.getDonorHistoryAsync(_profileId!),
      );
      applicationCount.value =
          await _profileService.getApplicationCountAsync(_profileId!);
    } finally {
      isHistoryLoading.value = false;
    }
  }

  void updateProfile({
    required String name,
    required String phone,
    required String bloodType,
    required String notes,
  }) {
    this.name.value = name;
    this.phone.value = phone;
    this.bloodType.value = bloodType;
    medicalNotes.value = notes;
  }

  Future<void> loadProfilePhoto() async {
    final accountEmail = email.value;
    final path = await _photoService.loadPath(accountEmail);
    if (email.value.toLowerCase() == accountEmail.toLowerCase()) {
      avatarPath.value = path;
    }
  }

  Future<bool> updateProfilePhoto(ImageSource source) async {
    if (isPhotoLoading.value) return false;
    isPhotoLoading.value = true;
    try {
      final path = await _photoService.pickAndSave(email.value, source);
      if (path == null) return false;
      avatarPath.value = path;
      return true;
    } finally {
      isPhotoLoading.value = false;
    }
  }

  Future<bool> updateProfilePhotoFromFile() async {
    if (isPhotoLoading.value) return false;
    isPhotoLoading.value = true;
    try {
      final path = await _photoService.pickFileAndSave(email.value);
      if (path == null) return false;
      avatarPath.value = path;
      return true;
    } finally {
      isPhotoLoading.value = false;
    }
  }

  Future<void> removeProfilePhoto() async {
    final accountEmail = email.value;
    await _photoService.remove(accountEmail);
    if (email.value.toLowerCase() == accountEmail.toLowerCase()) {
      avatarPath.value = null;
    }
  }
}
