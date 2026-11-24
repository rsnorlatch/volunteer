import 'package:uuid/uuid.dart';
import 'package:volunteer/adapter/activity_repository/fake_activity_repository.dart';
import 'package:volunteer/adapter/registration_repository/FakeRegistrationRepository.dart';
import 'package:volunteer/adapter/session_manager/session_manager_interface.dart';
import 'package:volunteer/data/models/activity_model.dart';
import 'package:volunteer/data/models/registration.dart';
import 'package:volunteer/entities/role.dart';

class ActivityService {
  ActivityService(this.activity, this.session, this.registration);

  FakeActivityRepository activity;
  FakeRegistrationRepository registration;
  SessionManagerInterface session;

  List<BloodActivityModel> get activityList => activity.getAll();

  Future<void> createActivityAsync(BloodActivityModel activity) async {
    final currentProfile = await session.getCurrentProfileAsync();

    if (currentProfile == null) return;

    if (currentProfile.role != Role.organizer) return;

    await this.activity.insertAsync(
          activity.copyWith(ownerEmail: currentProfile.email),
        );
  }

  Future<void> applyAsync(String activityId, String phoneNumber) async {
    if (await session.getCurrentProfileAsync() == null) return;

    final activity = await this.activity.getByIdAsync(activityId);

    if (activity == null) {
      return;
    }

    final currentUserProfile = await session.getCurrentProfileAsync();

    await this.activity.updateAsync(
          activity.copyWith(registered: activity.registered + 1),
        );

    await registration.insertAsync(Registration(
      id: Uuid().v4(),
      phone: phoneNumber,
      userKey: currentUserProfile!.id,
      donorName: currentUserProfile.username,
      bloodType: currentUserProfile.bloodType,
      activityId: activityId,
      status: RegistrationStatus.pending,
      createdAt: DateTime.now(),
    ));
  }

  Future<void> acceptRegistration(String registrationId) async {
    final currentRegistration = await registration.getByIdAsync(registrationId);

    await registration.updateAsync(Registration(
      id: registrationId,
      phone: currentRegistration!.phone,
      userKey: currentRegistration.userKey,
      createdAt: currentRegistration.createdAt,
      status: RegistrationStatus.accepted,
      activityId: currentRegistration.activityId,
      bloodType: currentRegistration.bloodType,
      donorName: currentRegistration.donorName,
    ));
  }
}
