import 'package:get/get.dart';

import 'package:volunteer/entities/profile.dart';
import 'package:volunteer/entities/role.dart';

class ProfileController extends GetxController {
  final name = 'Sahabat Donor'.obs;
  final email = ''.obs;
  final phone = ''.obs;
  final bloodType = ''.obs;
  final medicalNotes = ''.obs;
  final role = Role.donor.obs;
  final isGuest = true.obs;
  final joinedYear = DateTime.now().year;

  String get userKey => (isGuest.value || email.value.isEmpty)
      ? 'guest'
      : email.value.toLowerCase();

  String get initial {
    final n = name.value.trim();
    return n.isEmpty ? '?' : n[0].toUpperCase();
  }

  void setFromProfile(Profile p) {
    name.value = p.username;
    email.value = p.email;
    role.value = p.role;
    phone.value = '';
    bloodType.value = '';
    medicalNotes.value = '';
    isGuest.value = false;
  }

  void setGuest() {
    name.value = 'Sahabat Donor';
    email.value = '';
    phone.value = '';
    bloodType.value = '';
    medicalNotes.value = '';
    role.value = Role.donor;
    isGuest.value = true;
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
}
