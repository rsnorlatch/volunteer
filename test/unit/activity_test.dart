import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:volunteer/adapter/activity_repository/fake_activity_repository.dart';
import 'package:volunteer/adapter/profile_repository/fake_profile_repository.dart';
import 'package:volunteer/adapter/registration_repository/FakeRegistrationRepository.dart';
import 'package:volunteer/adapter/session_manager/fake_session_manager.dart';
import 'package:volunteer/data/models/activity.dart';
import 'package:volunteer/data/models/activity_mapper.dart';
import 'package:volunteer/data/models/registration.dart';
import 'package:volunteer/entities/profile.dart';
import 'package:volunteer/entities/role.dart';
import 'package:volunteer/services/activity_service.dart';
import 'package:volunteer/services/fake_activity_service_binding.dart';

void main() {
  late ActivityService service;
  late FakeSessionManager session;
  late FakeProfileRepository profile;
  late FakeActivityRepository repo;
  late FakeRegistrationRepository registration;

  setUp(() async {
    FakeActivityServiceBinding().dependencies();

    service = Get.find<ActivityService>();
    session = Get.find<FakeSessionManager>();
    profile = Get.find<FakeProfileRepository>();
    registration = Get.find<FakeRegistrationRepository>();
    repo = Get.find<FakeActivityRepository>();

    await profile
        .insertAsync(Profile("achilless", "achilless@gmail.com", Role.donor));

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
    ).toModel());

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
    ).toModel());

    expect(repo.getAll(), isEmpty);
  });

  test(
      "when creating an activity but user is not an organizer, should not create an activity",
      () async {
    await session.validateAndSetCurrentUserAsync(
        "achilless@gmail.com", "Password123");

    await service.createActivityAsync(BloodActivity.create(
      title: "activity 1",
      description: "activity 1",
      date: "2026-11-12",
      time: "09.00 - 12.00",
      quota: 100,
      location: "somewhere",
      organizer: "PMI",
      bloodGroups: "AB",
    ).toModel());

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
    ).toModel());

    await session.destroyAsync();

    await session.validateAndSetCurrentUserAsync(
        "achilless@gmail.com", "Password123");

    await service.applyAsync(activityId, "0837387382");

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
    ).toModel());

    await session.destroyAsync();

    await service.applyAsync(activityId, "0837387382");

    final queried = await repo.getByIdAsync(activityId);

    expect(queried, isNotNull);
    expect(queried!.registered, 0);
  });

  test("when an activity is created, it should be viewable", () async {
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
    ).toModel());

    final feed = service.activityList;

    expect(feed, isNotEmpty);
  });

  test(
    "if someone apply for an activity, an organizer can accept it",
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
      ).toModel());

      await session.destroyAsync();

      await session.validateAndSetCurrentUserAsync(
          "achilless@gmail.com", "Password123");

      await service.applyAsync(activityId, "0838838124");

      final latestRegistration = (await registration.getAll()).last;

      await service.acceptRegistration(latestRegistration.id);

      final acceptedRegistration =
          await registration.getByIdAsync(latestRegistration.id);

      expect(acceptedRegistration!.status, RegistrationStatus.accepted);
    },
  );

  test("if someone apply for an activity, an organizer can reject it",
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
    ).toModel());

    await session.destroyAsync();

    await session.validateAndSetCurrentUserAsync(
        "achilless@gmail.com", "Password123");

    await service.applyAsync(activityId, "0838838124");

    final latestRegistration = (await registration.getAll()).last;

    await service.rejectRegistration(latestRegistration.id);

    final acceptedRegistration =
        await registration.getByIdAsync(latestRegistration.id);

    expect(acceptedRegistration!.status, RegistrationStatus.rejected);
  });

  test("someone that is either accepted or rejected can be marked as pending",
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
    ).toModel());

    await session.destroyAsync();

    await session.validateAndSetCurrentUserAsync(
        "achilless@gmail.com", "Password123");

    await service.applyAsync(activityId, "0838838124");

    final latestRegistration = (await registration.getAll()).last;

    await service.acceptRegistration(latestRegistration.id);

    await service.markAsPendingAsync(latestRegistration.id);

    final acceptedRegistration =
        await registration.getByIdAsync(latestRegistration.id);

    expect(acceptedRegistration!.status, RegistrationStatus.pending);
  });

  test("someone that is accepted can be marked as rejected", () async {},
      skip: true);

  test("someone that is rejected can be accepted", () async {}, skip: true);

  test(
      "when an activity is held at 9.00 - 12.00, when currently it is 13.00 should not be visible in the activity list",
      () async {},
      skip: true);
}
