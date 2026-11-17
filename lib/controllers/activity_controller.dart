import 'package:get/get.dart';

import 'package:volunteer/controllers/notification_controller.dart';
import 'package:volunteer/controllers/profile_controller.dart';
import 'package:volunteer/core/utils/formatters.dart';
import 'package:volunteer/data/models/activity.dart';
import 'package:volunteer/data/models/app_notification.dart';
import 'package:volunteer/data/models/registration.dart';

enum ActivityFilter { all, nearest, weekend }

class ActivityController extends GetxController {
  final activities = <BloodActivity>[].obs;
  final registrations = <Registration>[].obs;
  final query = ''.obs;
  final filter = ActivityFilter.all.obs;

  ProfileController get _profile => Get.find<ProfileController>();

  @override
  void onInit() {
    super.onInit();
    _seed();
  }

  DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  // ---------- Donor ----------

  bool isActive(BloodActivity a) {
    final d = DateTime.tryParse(a.date);
    return d != null && !d.isBefore(_today());
  }

  List<BloodActivity> get upcomingActivities {
    final list = activities.where(isActive).toList();
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  List<BloodActivity> get visibleActivities {
    final q = query.value.trim().toLowerCase();
    var list = upcomingActivities;
    if (q.isNotEmpty) {
      list = list
          .where((a) =>
              a.title.toLowerCase().contains(q) ||
              a.location.toLowerCase().contains(q))
          .toList();
    }
    switch (filter.value) {
      case ActivityFilter.all:
        break;
      case ActivityFilter.nearest:
        final limit = _today().add(const Duration(days: 7));
        list =
            list.where((a) => DateTime.parse(a.date).isBefore(limit)).toList();
        break;
      case ActivityFilter.weekend:
        list = list.where((a) {
          final w = DateTime.parse(a.date).weekday;
          return w == DateTime.saturday || w == DateTime.sunday;
        }).toList();
        break;
    }
    return list;
  }

  BloodActivity? byId(String id) =>
      activities.firstWhereOrNull((a) => a.id == id);

  bool isRegistered(String activityId) {
    final key = _profile.userKey;
    return registrations
        .any((r) => r.activityId == activityId && r.userKey == key);
  }

  List<Registration> get myRegistrations {
    final key = _profile.userKey;
    final list = registrations.where((r) => r.userKey == key).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  String get nextDonorLabel {
    final today = _today();
    DateTime? next;
    for (final r in myRegistrations) {
      if (r.status == RegistrationStatus.rejected) continue;
      final a = byId(r.activityId);
      final d = a == null ? null : DateTime.tryParse(a.date);
      if (d == null || d.isBefore(today)) continue;
      if (next == null || d.isBefore(next)) next = d;
    }
    return next == null ? 'Siap daftar' : Fmt.shortOf(next);
  }

  Registration register(
    BloodActivity a, {
    required String name,
    required String phone,
    required String bloodType,
  }) {
    final reg = Registration(
      id: 'reg-${DateTime.now().microsecondsSinceEpoch}',
      activityId: a.id,
      userKey: _profile.userKey,
      donorName: name,
      phone: phone,
      bloodType: bloodType,
    );
    registrations.add(reg);

    final i = activities.indexWhere((x) => x.id == a.id);
    if (i >= 0) {
      activities[i] =
          activities[i].copyWith(registered: activities[i].registered + 1);
    }

    Get.find<NotificationController>().add(
      'Pendaftaran berhasil',
      'Pendaftaran untuk ${a.title} telah dikirim.',
      NotificationType.registration,
    );
    return reg;
  }

  // ---------- Organizer ----------

  List<BloodActivity> activitiesOf(String organizer) =>
      activities.where((a) => a.organizer == organizer).toList();

  List<Registration> registrantsOf(String activityId) {
    final list =
        registrations.where((r) => r.activityId == activityId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  void addActivity(BloodActivity a) => activities.insert(0, a);

  void updateActivity(BloodActivity a) {
    final i = activities.indexWhere((x) => x.id == a.id);
    if (i >= 0) activities[i] = a;
  }

  void deleteActivity(String id) {
    activities.removeWhere((a) => a.id == id);
    registrations.removeWhere((r) => r.activityId == id);
  }

  void setRegistrantStatus(String id, RegistrationStatus status) {
    final i = registrations.indexWhere((r) => r.id == id);
    if (i >= 0) {
      registrations[i].status = status;
      registrations.refresh();
    }
  }

  // ---------- Data dummy ----------

  void _seed() {
    final today = _today();
    int until(int weekday) {
      final d = (weekday - today.weekday) % 7;
      return d == 0 ? 7 : d;
    }

    final saturday = today.add(Duration(days: until(DateTime.saturday)));
    final sunday = saturday.add(const Duration(days: 1));
    const org = 'PMI Bandung';

    activities.assignAll([
      BloodActivity(
        id: 'act-1',
        title: 'Donor Darah Peduli Sesama',
        location: 'PMI Kota Bandung, Jl. Aceh No. 45',
        date: Fmt.isoDate(saturday),
        time: '09:00 - 13:00',
        organizer: org,
        bloodGroups: 'O+, O-, A+, B+',
        description: '',
        quota: 100,
        registered: 4,
      ),
      BloodActivity(
        id: 'act-2',
        title: 'Berbagi untuk Negeri',
        location: 'RS Harapan Sehat, Jl. Merdeka No. 12',
        date: Fmt.isoDate(sunday),
        time: '08:00 - 12:00',
        organizer: org,
        bloodGroups: 'A+, A-',
        description: '',
        quota: 80,
        registered: 2,
      ),
      BloodActivity(
        id: 'act-3',
        title: 'Sehat Bersama',
        location: 'Klinik Medika, Jl. Cendana No. 9',
        date: Fmt.isoDate(today.add(const Duration(days: 8))),
        time: '10:00 - 14:00',
        organizer: org,
        bloodGroups: 'B+, B-',
        description: '',
        quota: 60,
        registered: 0,
      ),
      BloodActivity(
        id: 'act-4',
        title: 'Aksi Donor Kampus',
        location: 'Aula Kampus, Jl. Dipati Ukur',
        date: Fmt.isoDate(today.add(const Duration(days: 2))),
        time: '09:00 - 12:00',
        organizer: org,
        bloodGroups: 'A+, A-, B+, B-, O+, O-, AB+, AB-',
        description: '',
        quota: 150,
        registered: 1,
      ),
    ]);

    Registration r(String id, String act, String name, String blood,
            RegistrationStatus s, int daysAgo) =>
        Registration(
          id: id,
          activityId: act,
          userKey: 'seed-$id',
          donorName: name,
          phone: '0812345678$id'.replaceAll(RegExp(r'[^0-9]'), ''),
          bloodType: blood,
          status: s,
          createdAt: today.subtract(Duration(days: daysAgo)),
        );

    registrations.assignAll([
      r('1', 'act-1', 'Alya Pratama', 'O+', RegistrationStatus.pending, 5),
      r('2', 'act-1', 'Bima Saputra', 'A+', RegistrationStatus.accepted, 6),
      r('3', 'act-1', 'Citra Lestari', 'B+', RegistrationStatus.pending, 7),
      r('4', 'act-1', 'Dian Putra', 'O-', RegistrationStatus.accepted, 8),
      r('5', 'act-2', 'Eka Wijaya', 'A+', RegistrationStatus.pending, 2),
      r('6', 'act-2', 'Farah Nabila', 'A-', RegistrationStatus.accepted, 3),
      r('7', 'act-4', 'Galih Permana', 'O+', RegistrationStatus.pending, 1),
    ]);
  }
}
