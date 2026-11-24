import 'package:volunteer/data/models/activity_model.dart';

class FakeActivityRepository {
  final List<BloodActivityModel> _activites = [];

  List<BloodActivityModel> getAll() {
    return _activites;
  }

  Future<void> insertAsync(BloodActivityModel activity) async {
    _activites.add(activity);
  }

  Future<BloodActivityModel?> getByIdAsync(String activityId) async {
    return _activites
        .where((activity) => activity.id == activityId)
        .firstOrNull;
  }

  Future<void> updateAsync(BloodActivityModel newActivity) async {
    for (int i = 0; i <= _activites.length; i++) {
      if (_activites[i].id == newActivity.id) {
        _activites[i] = newActivity;
        break;
      }
    }
  }
}
