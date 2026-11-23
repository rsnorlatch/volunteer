import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:volunteer/adapter/activity_repository/fake_activity_repository.dart';
import 'package:volunteer/adapter/profile_repository/fake_profile_repository.dart';
import 'package:volunteer/adapter/session_manager/fake_session_manager.dart';
import 'package:volunteer/data/models/activity.dart';
import 'package:volunteer/entities/profile.dart';
import 'package:volunteer/entities/role.dart';
import 'package:volunteer/services/activity_service.dart';
import 'package:volunteer/services/fake_activity_service_binding.dart';

// TODO: implement a better model for BloodActivity to separate the display model and the domain model
void main() {
  late ActivityService service;
  late FakeSessionManager session;
  late FakeProfileRepository profile;
  late FakeActivityRepository repo;

  setUp(() async {
    FakeActivityServiceBinding().dependencies();

    service = Get.find<ActivityService>();
    session = Get.find<FakeSessionManager>();
    profile = Get.find<FakeProfileRepository>();
    repo = Get.find<FakeActivityRepository>();

    await profile
        .insertAsync(Profile("achilless", "achilles@gmail.com", Role.donor));

    await profile
        .insertAsync(Profile("tortoise", "tortoise@gmail.com", Role.organizer));
  });

  tearDown(() async {
    Get.reset();
  });

  test("when no activity is created, should have empty activity list",
      () async {
    expect(repo.getAll(), isEmpty);
  });

  test("when an activity is created, should not have empty activity list",
      () async {
    await session.validateAndSetCurrentUserAsync(
        "tortoise@gmail.com", "Password123");

    await service.createActivityAsync(BloodActivity.create(
      title: "activity 1",
      description: "activity 1",
      date: "2026-11-12",
      time: "09.00 - 12.00",
      quota: 100,
      location: "somewhere",
      organizer: "PMI",
      bloodGroups: "AB",
      latitude: -6.9175,
      longitude: 107.6191,
    ));

    expect(repo.getAll(), isNotEmpty);
  });

  test(
      "when creating an activity but user is not logged in, should not create an activity",
      () async {
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

    expect(repo.getAll(), isEmpty);
  });

  test(
      "when creating an activity but user is not an organizer, should not create an activity",
      () async {
    await session.validateAndSetCurrentUserAsync(
        "achilles@gmail.com", "Password123");

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

    expect(repo.getAll(), isEmpty);
  });

  test("when an activity is created, a donor can apply", () async {
    final activityId = Uuid().v4();

    await session.validateAndSetCurrentUserAsync(
        "tortoise@gmail.com", "Password123");

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
      latitude: -6.9175,
      longitude: 107.6191,
    ));

    await session.destroyAsync();

    await session.validateAndSetCurrentUserAsync(
        "achilles@gmail.com", "Password123");

    await service.applyAsync(activityId);

    final queried = await repo.getByIdAsync(activityId);

    expect(queried, isNotNull);
    expect(queried!.registered, greaterThan(0));
    expect(queried.latitude, -6.9175);
    expect(queried.longitude, 107.6191);
  });

  test(
      "when an activity is created but the user is not logged in, should not apply",
      () async {
    final activityId = Uuid().v4();

    await session.validateAndSetCurrentUserAsync(
        "tortoise@gmail.com", "Password123");

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

    await session.destroyAsync();

    await service.applyAsync(activityId);

    final queried = await repo.getByIdAsync(activityId);

    expect(queried, isNotNull);
    expect(queried!.registered, 0);
  });

  test(
      "when an activity is held at 9.00 - 12.00, when currently it is 13.00 should not be able to apply",
      () async {},
      skip: true);

  test(
      "when an activity is held at 2026-11-12 but today is 2026-11-13 should not be able apply",
      () async {},
      skip: true);
}
