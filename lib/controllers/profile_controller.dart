import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:volunteer/entities/profile.dart';
import 'package:volunteer/entities/role.dart';
import 'package:volunteer/services/profile_photo_service.dart';

class ProfileController extends GetxController {
  ProfileController({ProfilePhotoService? photoService})
      : _photoService = photoService ?? ProfilePhotoService();

  final ProfilePhotoService _photoService;
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

  String get userKey => email.value.toLowerCase();

  String get initial {
    final n = name.value.trim();
    return n.isEmpty ? '?' : n[0].toUpperCase();
  }

  void setFromProfile(Profile p) {
    name.value = p.username;
    email.value = p.email;
    avatarPath.value = null;
    role.value = p.role;
    phone.value = '';
    bloodType.value = p.bloodType;
    medicalNotes.value = '';
    isAuthenticated.value = true;
  }

  void clearSession() {
    name.value = '';
    email.value = '';
    avatarPath.value = null;
    phone.value = '';
    bloodType.value = '';
    medicalNotes.value = '';
    role.value = Role.donor;
    isAuthenticated.value = false;
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
