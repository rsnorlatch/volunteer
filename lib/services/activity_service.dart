import 'package:volunteer/adapter/activity_repository/fake_activity_repository.dart';
import 'package:volunteer/data/models/activity.dart';

class ActivityService {
  ActivityService(this.repository);

  FakeActivityRepository repository;

  Future<void> createActivityAsync(BloodActivity activity) async {
    await repository.insertAsync(activity);
  }

  Future<void> applyAsync(String activityId) async {
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
