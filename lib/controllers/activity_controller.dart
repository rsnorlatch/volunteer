import 'package:get/get.dart';

import 'package:volunteer/controllers/notification_controller.dart';
import 'package:volunteer/controllers/profile_controller.dart';
import 'package:volunteer/core/utils/formatters.dart';
import 'package:volunteer/data/models/activity_model.dart';
import 'package:volunteer/data/models/app_notification.dart';
import 'package:volunteer/data/models/registration.dart';
import 'package:volunteer/entities/role.dart';

enum ActivityFilter { all, nearest, weekend }

class ActivityController extends GetxController {
  final activities = <BloodActivityModel>[].obs;
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

  bool isActive(BloodActivityModel a) {
    return !a.startDateTime.isBefore(_today());
  }

  List<BloodActivityModel> get upcomingActivities {
    final list = activities.where(isActive).toList();
    list.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    return list;
  }

  List<BloodActivityModel> get visibleActivities {
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
        list = list.where((a) => a.startDateTime.isBefore(limit)).toList();
        break;
      case ActivityFilter.weekend:
        list = list.where((a) {
          final w = a.startDateTime.weekday;
          return w == DateTime.saturday || w == DateTime.sunday;
        }).toList();
        break;
    }
    return list;
  }

  BloodActivityModel? byId(String id) =>
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
      final d = a?.startDateTime;
      if (d == null || d.isBefore(today)) continue;
      if (next == null || d.isBefore(next)) next = d;
    }
    return next == null ? 'Siap daftar' : Fmt.shortOf(next);
  }

  Registration register(
    BloodActivityModel a, {
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

  List<BloodActivityModel> activitiesOf(String ownerEmail) => activities
      .where((a) => a.ownerEmail.toLowerCase() == ownerEmail.toLowerCase())
      .toList();

  bool canManageActivity(String activityId) {
    final activity = byId(activityId);
    final email = _profile.email.value.trim().toLowerCase();
    return _profile.role.value == Role.organizer &&
        _profile.isAuthenticated.value &&
        email.isNotEmpty &&
        activity != null &&
        activity.ownerEmail.toLowerCase() == email;
  }

  List<Registration> registrantsOf(String activityId) {
    final list =
        registrations.where((r) => r.activityId == activityId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  bool addActivity(BloodActivityModel a) {
    final email = _profile.email.value.trim();
    if (_profile.role.value != Role.organizer ||
        !_profile.isAuthenticated.value ||
        email.isEmpty) {
      return false;
    }
    activities.insert(0, a.copyWith(ownerEmail: email));
    return true;
  }

  bool updateActivity(BloodActivityModel a) {
    if (!canManageActivity(a.id)) return false;
    final i = activities.indexWhere((x) => x.id == a.id);
    if (i < 0) return false;
    activities[i] = a.copyWith(ownerEmail: activities[i].ownerEmail);
    return true;
  }

  bool deleteActivity(String id) {
    if (!canManageActivity(id)) return false;
    activities.removeWhere((a) => a.id == id);
    registrations.removeWhere((r) => r.activityId == id);
    return true;
  }

  bool setRegistrantStatus(String id, RegistrationStatus status) {
    final i = registrations.indexWhere((r) => r.id == id);
    if (i < 0 || !canManageActivity(registrations[i].activityId)) return false;
    final registration = registrations[i];
    if (registration.status == status) return true;

    final activityIndex =
        activities.indexWhere((a) => a.id == registration.activityId);
    final activity = activities[activityIndex];
    if (status != RegistrationStatus.rejected &&
        registration.status == RegistrationStatus.rejected &&
        activity.registered >= activity.quota) {
      return false;
    }

    if (status == RegistrationStatus.rejected &&
        registration.status != RegistrationStatus.rejected) {
      activities[activityIndex] = activity.copyWith(
        registered: (activity.registered - 1).clamp(0, activity.quota),
      );
    } else if (status != RegistrationStatus.rejected &&
        registration.status == RegistrationStatus.rejected) {
      activities[activityIndex] =
          activity.copyWith(registered: activity.registered + 1);
    }
    registration.status = status;
    registrations.refresh();
    return true;
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

    final act1 = BloodActivityModel.dateTimeRangeFromString(
      Fmt.isoDate(saturday),
      '09:00 - 13:00',
    );
    final act2 = BloodActivityModel.dateTimeRangeFromString(
      Fmt.isoDate(sunday),
      '08:00 - 12:00',
    );
    final act3 = BloodActivityModel.dateTimeRangeFromString(
      Fmt.isoDate(today.add(const Duration(days: 8))),
      '10:00 - 14:00',
    );
    final act4 = BloodActivityModel.dateTimeRangeFromString(
      Fmt.isoDate(today.add(const Duration(days: 2))),
      '09:00 - 12:00',
    );

    final toBeInsertedActivities = [
      BloodActivityModel(
        id: 'act-1',
        title: 'Donor Darah Peduli Sesama',
        location: 'PMI Kota Bandung, Jl. Aceh No. 45',
        startDateTime: act1?.$1 ?? DateTime.now(),
        endDateTime: act1?.$2 ?? DateTime.now(),
        organizer: org,
        bloodGroups: BloodActivityModel.bloodGroupsFromString('O+, O-, A+, B+'),
        description: '',
        quota: 100,
        registered: 4,
      ),
      BloodActivityModel(
        id: 'act-2',
        title: 'Berbagi untuk Negeri',
        location: 'RS Harapan Sehat, Jl. Merdeka No. 12',
        startDateTime: act2?.$1 ?? DateTime.now(),
        endDateTime: act2?.$2 ?? DateTime.now(),
        organizer: org,
        bloodGroups: BloodActivityModel.bloodGroupsFromString('A+, A-'),
        description: '',
        quota: 80,
        registered: 2,
      ),
      BloodActivityModel(
        id: 'act-3',
        title: 'Sehat Bersama',
        location: 'Klinik Medika, Jl. Cendana No. 9',
        startDateTime: act3?.$1 ?? DateTime.now(),
        endDateTime: act3?.$2 ?? DateTime.now(),
        organizer: org,
        bloodGroups: BloodActivityModel.bloodGroupsFromString('B+, B-'),
        description: '',
        quota: 60,
        registered: 0,
      ),
      BloodActivityModel(
        id: 'act-4',
        title: 'Aksi Donor Kampus',
        location: 'Aula Kampus, Jl. Dipati Ukur',
        startDateTime: act4?.$1 ?? DateTime.now(),
        endDateTime: act4?.$2 ?? DateTime.now(),
        organizer: org,
        bloodGroups: BloodActivityModel.bloodGroupsFromString(
          'A+, A-, B+, B-, O+, O-, AB+, AB-',
        ),
        description: '',
        quota: 150,
        registered: 1,
      ),
    ];

    activities.assignAll(toBeInsertedActivities);

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
