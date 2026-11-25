import 'package:volunteer/data/models/activity_model.dart';

abstract interface class ActivityRepositoryInterface {
  Future<List<BloodActivityModel>> getAllAsync();

  Future<void> insertAsync(BloodActivityModel activity);

  Future<BloodActivityModel?> getByIdAsync(String activityId);

  Future<void> updateAsync(BloodActivityModel newActivity);

  Future<void> deleteByIdAsync(String activityId) async {}
}
