import 'package:volunteer/data/models/activity.dart';

class FakeActivityRepository {
  final List<BloodActivity> _activites = [];

  List<BloodActivity> getAll() {
    return _activites;
  }

  Future<void> insertAsync(BloodActivity activity) async {
    _activites.add(activity);
  }

  Future<BloodActivity?> getByIdAsync(String activityId) async {
    return _activites
        .where((activity) => activity.id == activityId)
        .firstOrNull;
  }

  Future<void> updateAsync(BloodActivity newActivity) async {
    for (int i = 0; i <= _activites.length; i++) {
      if (_activites[i].id == newActivity.id) {
        _activites[i] = newActivity;
        break;
      }
    }
  }
}
