import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:volunteer/adapter/activity_repository/fake_activity_repository.dart';
import 'package:volunteer/data/models/activity.dart';
import 'package:volunteer/services/activity_service.dart';
import 'package:volunteer/services/fake_activity_service_binding.dart';

void main() {
  late ActivityService service;

  setUp(() {
    FakeActivityServiceBinding().dependencies();

    service = Get.find<ActivityService>();
  });

  test("when no activity is created, should have empty activity list",
      () async {
    final repo = Get.find<FakeActivityRepository>();

    expect(repo.getAll(), isEmpty);
  });

  test("when an activity is created, should not have empty activity list",
      () async {
    final repo = Get.find<FakeActivityRepository>();

    await service.createActivityAsync(BloodActivity.create(
      title: "activity 1",
      description: "activity 1",
      date: "2026-11-12",
      time: "09.00 - 12.00",
      quota: 100,
      location: "somewhere",
      organizer: "PMI",
      bloodGroups: "AB",
    ));

    expect(repo.getAll(), isNotEmpty);
  });

  test("when an activity is created, a donor can apply", () async {
    final activityId = Uuid().v4();
    final repo = Get.find<FakeActivityRepository>();

    await service.createActivityAsync(BloodActivity.create(
      id: activityId,
      title: "activity 1",
      description: "activity 1",
      date: "2026-11-12",
      time: "09.00 - 12.00",
      quota: 100,
      location: "somewhere",
      organizer: "PMI",
      bloodGroups: "AB",
    ));

    await service.applyAsync(activityId);

    final queried = await repo.getByIdAsync(activityId);

    expect(queried, isNotNull);
    expect(queried!.registered, greaterThan(0));
  });

  test(
      "when an activity is creaated but the user is not logged in, should not apply",
      () async {
    final activityId = Uuid().v4();
  });
}
