import 'package:get/get.dart';
import '../data/models/activity.dart';

class AppController extends GetxController {
  final isLoading = false.obs;
  final role = 'donor'.obs;
  final fullName = 'Sahabat Donor'.obs;
  final email = ''.obs;
  final bloodType = 'O+'.obs;

  final activities = <BloodActivity>[
    BloodActivity(
      id: 'demo-1',
      title: 'Donor Darah Peduli Sesama',
      location: 'Mall Malioboro, Yogyakarta',
      startDateTime: DateTime(2026, 12, 5, 9, 0),
      endDateTime: DateTime(2026, 12, 5, 14, 0),
      organizer: 'PMI Yogyakarta',
      bloodGroups: BloodActivity.bloodGroupsFromString('A+, B+, O+, AB+'),
      description:
          'Mari berbagi kehidupan melalui donor darah. Setetes darah Anda sangat berarti.',
      quota: 100,
      registered: 64,
    ),
    BloodActivity(
      id: 'demo-2',
      title: 'Aksi Donor Darah Kampus',
      location: 'Universitas Gadjah Mada',
      startDateTime: DateTime(2026, 12, 12, 8, 0),
      endDateTime: DateTime(2026, 12, 12, 12, 0),
      organizer: 'Volunteer Campus',
      bloodGroups: BloodActivity.bloodGroupsFromString('Semua golongan'),
      description: 'Kegiatan donor darah terbuka untuk masyarakat umum.',
      quota: 80,
      registered: 32,
    ),
    BloodActivity(
      id: 'demo-3',
      title: 'Sehat Bersama, Donor Bersama',
      location: 'Jogja City Mall',
      startDateTime: DateTime(2026, 12, 20, 10, 0),
      endDateTime: DateTime(2026, 12, 20, 15, 0),
      organizer: 'PMI Kota Yogyakarta',
      bloodGroups: BloodActivity.bloodGroupsFromString('O+, O-, A+'),
      description: 'Donor darah rutin untuk memenuhi kebutuhan stok darah.',
      quota: 120,
      registered: 48,
    ),
  ].obs;

  final users = <Map<String, dynamic>>[].obs;

  final facilities = <Map<String, dynamic>>[
    {
      'name': 'PMI Kota Yogyakarta',
      'address': 'Jl. Tegalgendu, Yogyakarta',
      'distance': '1.2 km',
      'type': 'Unit Donor Darah',
    },
    {
      'name': 'RS Bethesda',
      'address': 'Jl. Jend. Sudirman, Yogyakarta',
      'distance': '2.4 km',
      'type': 'Rumah Sakit',
    },
    {
      'name': 'RSUP Dr. Sardjito',
      'address': 'Jl. Kesehatan, Yogyakarta',
      'distance': '4.5 km',
      'type': 'Rumah Sakit',
    },
  ].obs;

  final notifications = <Map<String, dynamic>>[
    {
      'id': 'n1',
      'title': 'Pendaftaran berhasil',
      'body': 'Pendaftaran kegiatan donor Anda telah dikirim.',
      'is_read': false,
    },
    {
      'id': 'n2',
      'title': 'Pengingat donor',
      'body': 'Jangan lupa menjaga kesehatan sebelum donor darah.',
      'is_read': false,
    },
    {
      'id': 'n3',
      'title': 'Terima kasih, Volunteer!',
      'body': 'Setiap kontribusi Anda berarti bagi sesama.',
      'is_read': true,
    },
  ].obs;

  final registrants = <Map<String, dynamic>>[].obs;

  final registeredActivityIds = <String>[].obs;

  bool get demoMode => true;

  Future<bool> login(String username, String password) async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));

    final user = users.firstWhereOrNull(
      (u) => u['email'] == username && u['password'] == password,
    );

    if (user != null) {
      fullName.value = user['name'];
      email.value = user['email'];
      role.value = user['role'];
      isLoading.value = false;
      return true;
    }

    // Akun demo agar halaman dapat dicoba tanpa registrasi.
    if (username == 'donor@volunteer.com' && password == '12345678') {
      fullName.value = 'Sahabat Donor';
      email.value = username;
      role.value = 'donor';
      isLoading.value = false;
      return true;
    }

    if (username == 'organizer@volunteer.com' && password == '12345678') {
      fullName.value = 'Organizer Volunteer';
      email.value = username;
      role.value = 'organizer';
      isLoading.value = false;
      return true;
    }

    isLoading.value = false;
    Get.snackbar('Login gagal', 'Email atau password tidak sesuai.');
    return false;
  }

  Future<bool> signup(
    String name,
    String mail,
    String password,
    String selectedRole,
  ) async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));

    if (users.any((u) => u['email'] == mail)) {
      isLoading.value = false;
      Get.snackbar('Registrasi gagal', 'Email sudah digunakan.');
      return false;
    }

    users.add({
      'name': name,
      'email': mail,
      'password': password,
      'role': selectedRole,
    });

    isLoading.value = false;
    Get.snackbar('Berhasil', 'Akun berhasil dibuat.');
    return true;
  }

  void logout() {
    role.value = 'donor';
    fullName.value = 'Sahabat Donor';
    email.value = '';
    Get.offAllNamed('/login');
  }

  void refreshActivities() {
    activities.refresh();
  }

  void saveActivity({
    String? id,
    required String title,
    required String location,
    required String date,
    required String time,
    required String groups,
    required String description,
    required int quota,
  }) {
    final range = BloodActivity.dateTimeRangeFromString(date, time);
    final activity = BloodActivity(
      id: id ?? 'local-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      location: location,
      startDateTime: range?.$1 ?? DateTime.now(),
      endDateTime: range?.$2 ?? DateTime.now(),
      organizer: fullName.value,
      bloodGroups: BloodActivity.bloodGroupsFromString(groups),
      description: description,
      quota: quota,
      registered: 0,
    );

    if (id == null) {
      activities.insert(0, activity);
    } else {
      final index = activities.indexWhere((a) => a.id == id);
      if (index >= 0) activities[index] = activity;
    }

    activities.refresh();
  }

  void deleteActivity(String id) {
    activities.removeWhere((a) => a.id == id);
  }

  void loadFacilities() {}

  void loadNotifications() {}

  void markNotificationRead(String id) {
    final index = notifications.indexWhere(
      (n) => n['id'] == id,
    );

    if (index >= 0) {
      notifications[index]['is_read'] = true;
      notifications.refresh();
    }
  }

  void updateProfile(String name, String phone, String group) {
    fullName.value = name;
    bloodType.value = group;
  }

  void loadRegistrants(String activityId) {
    registrants.assignAll([
      {
        'id': 'r1',
        'donor_name': 'Andi Pratama',
        'phone': '081234567890',
        'blood_type': 'O+',
        'status': 'pending',
      },
      {
        'id': 'r2',
        'donor_name': 'Siti Rahma',
        'phone': '081234567891',
        'blood_type': 'A+',
        'status': 'pending',
      },
    ]);
  }

  void setRegistrantStatus(String id, String status) {
    final index = registrants.indexWhere(
      (r) => r['id'] == id,
    );

    if (index >= 0) {
      registrants[index]['status'] = status;
      registrants.refresh();
    }
  }

  void registerForActivity(
    BloodActivity activity,
    String name,
    String phone,
    String group,
  ) {
    if (registeredActivityIds.contains(activity.id)) {
      Get.snackbar('Informasi', 'Anda sudah mendaftar kegiatan ini.');
      return;
    }

    registeredActivityIds.add(activity.id);

    registrants.add({
      'id': 'r${DateTime.now().microsecondsSinceEpoch}',
      'donor_name': name,
      'phone': phone,
      'blood_type': group,
      'status': 'pending',
    });

    Get.snackbar('Berhasil', 'Pendaftaran donor berhasil dikirim.');
  }
}
