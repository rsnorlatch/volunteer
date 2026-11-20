import 'package:volunteer/adapter/activity_repository/fake_activity_repository.dart';
import 'package:volunteer/adapter/session_manager/session_manager_interface.dart';
import 'package:volunteer/data/models/activity.dart';
import 'package:volunteer/entities/role.dart';

class ActivityService {
  ActivityService(this.repository, this.session);

  FakeActivityRepository repository;
  SessionManagerInterface session;

  Future<void> createActivityAsync(BloodActivity activity) async {
    final currentProfile = await session.getCurrentProfileAsync();

    if (currentProfile == null) return;

    if (currentProfile.role != Role.organizer) return;

    await repository.insertAsync(
      activity.copyWith(ownerEmail: currentProfile.email),
    );
  }

  Future<void> applyAsync(String activityId) async {
    if (await session.getCurrentProfileAsync() == null) return;

    final activity = await repository.getByIdAsync(activityId);

    if (activity == null) {
      return;
    }

    await repository.updateAsync(BloodActivity(
      id: activity.id,
      title: activity.title,
      description: activity.description,
      bloodGroups: activity.bloodGroups,
      organizer: activity.organizer,
      location: activity.location,
      quota: activity.quota,
      date: activity.date,
      time: activity.time,
      registered: activity.registered + 1,
    ));
  }
}
