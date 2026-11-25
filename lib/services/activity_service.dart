import 'package:uuid/uuid.dart';
import 'package:volunteer/adapter/activity_repository/activity_repository_interface.dart';
import 'package:volunteer/adapter/registration_repository/registration_repository_interface.dart';
import 'package:volunteer/adapter/session_manager/session_manager_interface.dart';
import 'package:volunteer/data/models/activity_model.dart';
import 'package:volunteer/data/models/registration.dart';
import 'package:volunteer/entities/role.dart';

class ActivityService {
  ActivityService(this.activity, this.session, this.registration);

  ActivityRepositoryInterface activity;
  RegistrationRepositoryInterface registration;
  SessionManagerInterface session;

  Future<List<BloodActivityModel>> getActivityListAsync() async {
    final allActivity = await activity.getAllAsync();

    final currentUser = await session.getCurrentProfileAsync();

    if (currentUser!.role == Role.organizer) return allActivity;

    return allActivity
        .where((activity) => activity.endDateTime.isAfter(DateTime.now()))
        .toList();
  }

  Future<List<Registration>> getRegistrationsAsync() async {
    return registration.getAllAsync();
  }

  Future<void> createActivityAsync(BloodActivityModel activity) async {
    final currentProfile = await session.getCurrentProfileAsync();

    if (currentProfile == null) return;

    if (currentProfile.role != Role.organizer) return;

    await this.activity.insertAsync(
          activity.copyWith(ownerEmail: currentProfile.email),
        );
  }

  Future<void> updateActivityAsync(BloodActivityModel activity) async {
    final currentProfile = await session.getCurrentProfileAsync();

    if (currentProfile == null) return;

    if (currentProfile.role != Role.organizer) return;

    final existing = await this.activity.getByIdAsync(activity.id);
    if (existing == null) return;

    await this.activity.updateAsync(
          activity.copyWith(ownerEmail: existing.ownerEmail),
        );
  }

  Future<void> deleteActivityAsync(String activityId) async {
    final currentProfile = await session.getCurrentProfileAsync();

    if (currentProfile == null) return;

    if (currentProfile.role != Role.organizer) return;

    final regs = await registration.getAllAsync();
    for (final r in regs.where((r) => r.activityId == activityId)) {
      await registration.deleteByIdAsync(r.id);
    }

    await activity.deleteByIdAsync(activityId);
  }

  Future<Registration> applyAsync({
    required String activityId,
    required String phoneNumber,
    required String donorName,
    required String bloodType,
  }) async {
    final profile = await session.getCurrentProfileAsync();

    if (profile == null) {
      throw Exception('No authenticated profile');
    }

    final act = await this.activity.getByIdAsync(activityId);

    if (act == null) {
      throw Exception('Activity not found');
    }

    await this.activity.updateAsync(
          act.copyWith(registered: act.registered + 1),
        );

    final reg = Registration(
      id: Uuid().v4(),
      phone: phoneNumber,
      userKey: profile.id,
      donorName: donorName,
      bloodType: bloodType,
      activityId: activityId,
      status: RegistrationStatus.pending,
      createdAt: DateTime.now(),
    );

    await registration.insertAsync(reg);
    return reg;
  }

  Future<void> acceptRegistrationAsync(String registrationId) async {
    final currentRegistration = await registration.getByIdAsync(registrationId);

    if (currentRegistration == null) return;

    await _updateRegistrationStatusAndQuota(
      currentRegistration,
      RegistrationStatus.accepted,
    );
  }

  Future<void> rejectRegistrationAsync(String registrationId) async {
    final currentRegistration = await registration.getByIdAsync(registrationId);

    if (currentRegistration == null) return;

    await _updateRegistrationStatusAndQuota(
      currentRegistration,
      RegistrationStatus.rejected,
    );
  }

  Future<void> markAsPendingAsync(String registrationId) async {
    final currentRegistration = await registration.getByIdAsync(registrationId);

    if (currentRegistration == null) return;

    await _updateRegistrationStatusAndQuota(
      currentRegistration,
      RegistrationStatus.pending,
    );
  }

  Future<void> _updateRegistrationStatusAndQuota(
    Registration current,
    RegistrationStatus status,
  ) async {
    final act = await this.activity.getByIdAsync(current.activityId);

    if (act == null) return;

    // Rejecting a non-rejected registration frees a slot.
    if (status == RegistrationStatus.rejected &&
        current.status != RegistrationStatus.rejected) {
      await this.activity.updateAsync(
            act.copyWith(
              registered: (act.registered - 1).clamp(0, act.quota),
            ),
          );
    }
    // Un-rejecting (accept / pending) from rejected consumes a slot.
    else if (status != RegistrationStatus.rejected &&
        current.status == RegistrationStatus.rejected) {
      if (act.registered >= act.quota) return;

      await activity.updateAsync(
        act.copyWith(
          registered: act.registered + 1,
        ),
      );
    }

    await registration.updateAsync(Registration(
      id: current.id,
      activityId: current.activityId,
      userKey: current.userKey,
      donorName: current.donorName,
      phone: current.phone,
      bloodType: current.bloodType,
      status: status,
      createdAt: current.createdAt,
    ));
  }
}
