import 'package:get/get.dart';

import 'package:volunteer/controllers/notification_controller.dart';
import 'package:volunteer/controllers/profile_controller.dart';
import 'package:volunteer/core/utils/formatters.dart';
import 'package:volunteer/data/models/activity_model.dart';
import 'package:volunteer/data/models/app_notification.dart';
import 'package:volunteer/data/models/registration.dart';
import 'package:volunteer/entities/role.dart';
import 'package:volunteer/services/activity_service.dart';

enum ActivityFilter { all, nearest, weekend }

class ActivityController extends GetxController {
  final activities = <BloodActivityModel>[].obs;
  final registrations = <Registration>[].obs;
  final query = ''.obs;
  final filter = ActivityFilter.all.obs;
  final isLoading = false.obs;

  ProfileController get _profile => Get.find<ProfileController>();
  ActivityService get _service => Get.find<ActivityService>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final acts = await _service.getActivityListAsync();
      activities.assignAll(acts);
      final regs = await _service.getRegistrationsAsync();
      registrations.assignAll(regs);
    } finally {
      isLoading.value = false;
    }
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

  Future<Registration?> register(
    BloodActivityModel a, {
    required String name,
    required String phone,
    required String bloodType,
  }) async {
    try {
      final reg = await _service.applyAsync(
        activityId: a.id,
        phoneNumber: phone,
        donorName: name,
        bloodType: bloodType,
      );

      Get.find<NotificationController>().add(
        'Pendaftaran berhasil',
        'Pendaftaran untuk ${a.title} telah dikirim.',
        NotificationType.registration,
      );

      await load();
      return reg;
    } catch (e) {
      print(e);
      return null;
    }
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

  Future<bool> addActivity(BloodActivityModel a) async {
    try {
      await _service.createActivityAsync(a);
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateActivity(BloodActivityModel a) async {
    if (!canManageActivity(a.id)) return false;
    try {
      await _service.updateActivityAsync(a);
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteActivity(String id) async {
    if (!canManageActivity(id)) return false;
    try {
      await _service.deleteActivityAsync(id);
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> setRegistrantStatus(String id, RegistrationStatus status) async {
    final i = registrations.indexWhere((r) => r.id == id);
    if (i < 0 || !canManageActivity(registrations[i].activityId)) return false;
    try {
      switch (status) {
        case RegistrationStatus.accepted:
          await _service.acceptRegistrationAsync(id);
        case RegistrationStatus.rejected:
          await _service.rejectRegistrationAsync(id);
        case RegistrationStatus.pending:
          await _service.markAsPendingAsync(id);
      }
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }
}
