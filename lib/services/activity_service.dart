import 'package:volunteer/adapter/activity_repository/fake_activity_repository.dart';
import 'package:volunteer/adapter/session_manager/session_manager_interface.dart';
import 'package:volunteer/data/models/activity_model.dart';
import 'package:volunteer/entities/role.dart';

class ActivityService {
  ActivityService(this.repository, this.session);

  FakeActivityRepository repository;
  SessionManagerInterface session;

  Future<void> createActivityAsync(BloodActivityModel activity) async {
    final currentProfile = await session.getCurrentProfileAsync();

    if (currentProfile == null) return;

    if (currentProfile.role != Role.organizer) return;

    await repository.insertAsync(
      activity.copyWith(ownerEmail: currentProfile.email),
    );
  }

  Future<void> applyAsync(String activityId, String phoneNumber) async {
    if (await session.getCurrentProfileAsync() == null) return;

    final activity = await repository.getByIdAsync(activityId);

    if (activity == null) {
      return;
    }

    await repository.updateAsync(
      activity.copyWith(registered: activity.registered + 1),
    );
  }
}
