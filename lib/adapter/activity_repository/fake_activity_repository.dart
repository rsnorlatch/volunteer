import 'package:get/get.dart';
import 'package:volunteer/adapter/activity_repository/activity_repository_interface.dart';
import 'package:volunteer/data/models/activity_model.dart';

class FakeActivityRepository implements ActivityRepositoryInterface {
  final List<BloodActivityModel> _activites = [];

  @override
  Future<List<BloodActivityModel>> getAllAsync() async {
    return _activites;
  }

  @override
  Future<void> insertAsync(BloodActivityModel activity) async {
    _activites.add(activity);
  }

  Future<void> insertAll(List<BloodActivityModel> activities) async {
    _activites.addAll(activities);
  }

  @override
  Future<BloodActivityModel?> getByIdAsync(String activityId) async {
    return _activites
        .where((activity) => activity.id == activityId)
        .firstOrNull;
  }

  @override
  Future<void> updateAsync(BloodActivityModel newActivity) async {
    for (int i = 0; i < _activites.length; i++) {
      if (_activites[i].id == newActivity.id) {
        _activites[i] = newActivity;
        break;
      }
    }
  }

  @override
  Future<void> deleteByIdAsync(String activityId) async {
    _activites.removeWhere((activity) => activity.id == activityId);
  }
}
