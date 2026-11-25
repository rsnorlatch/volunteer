import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:volunteer/adapter/activity_repository/fake_activity_repository.dart';
import 'package:volunteer/adapter/profile_repository/fake_profile_repository.dart';
import 'package:volunteer/adapter/registration_repository/fake_registration_repository.dart';
import 'package:volunteer/adapter/session_manager/fake_session_manager.dart';
import 'package:volunteer/data/models/activity_model.dart';
import 'package:volunteer/data/models/bloodtype.dart';
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
    expect(await repo.getAllAsync(), isEmpty);
  });

  test("when an activity is created, should not have empty activity list",
      () async {
    await session.validateAndSetCurrentUserAsync(
        "tortoise@gmail.com", "Password123");

    await service.createActivityAsync(BloodActivityModel.create(
      title: "activity 1",
      description: "activity 1",
      startDateTime: DateTime.now().add(const Duration(hours: 1)),
      endDateTime: DateTime.now().add(const Duration(hours: 2)),
      quota: 100,
      location: "somewhere",
      organizer: "PMI",
      bloodGroups: <BloodType>[BloodType.abPlus],
      latitude: -6.9175,
      longitude: 107.6191,
    ));

    expect(await repo.getAllAsync(), isNotEmpty);
  });

  test(
      "when creating an activity but user is not logged in, should not create an activity",
      () async {
    await service.createActivityAsync(BloodActivityModel.create(
      title: "activity 1",
      description: "activity 1",
      startDateTime: DateTime.now().add(const Duration(hours: 1)),
      endDateTime: DateTime.now().add(const Duration(hours: 2)),
      quota: 100,
      location: "somewhere",
      organizer: "PMI",
      bloodGroups: <BloodType>[BloodType.abPlus],
    ));

    expect(await repo.getAllAsync(), isEmpty);
  });

  test(
      "when creating an activity but user is not an organizer, should not create an activity",
      () async {
    await session.validateAndSetCurrentUserAsync(
        "achilless@gmail.com", "Password123");

    await service.createActivityAsync(BloodActivityModel.create(
      title: "activity 1",
      description: "activity 1",
      startDateTime: DateTime.now().add(const Duration(hours: 1)),
      endDateTime: DateTime.now().add(const Duration(hours: 2)),
      quota: 100,
      location: "somewhere",
      organizer: "PMI",
      bloodGroups: <BloodType>[BloodType.abPlus],
    ));

    expect(await repo.getAllAsync(), isEmpty);
  });

  test("when an activity is created, a donor can apply", () async {
    final activityId = Uuid().v4();

    await session.validateAndSetCurrentUserAsync(
        "tortoise@gmail.com", "Password123");

    await service.createActivityAsync(BloodActivityModel.create(
      id: activityId,
      title: "activity 1",
      description: "activity 1",
      startDateTime: DateTime.now().add(const Duration(hours: 1)),
      endDateTime: DateTime.now().add(const Duration(hours: 2)),
      quota: 100,
      location: "somewhere",
      organizer: "PMI",
      bloodGroups: <BloodType>[BloodType.abPlus],
      latitude: -6.9175,
      longitude: 107.6191,
    ));

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

    await service.createActivityAsync(BloodActivityModel.create(
      id: activityId,
      title: "activity 1",
      description: "activity 1",
      startDateTime: DateTime.now().add(const Duration(hours: 1)),
      endDateTime: DateTime.now().add(const Duration(hours: 2)),
      quota: 100,
      location: "somewhere",
      organizer: "PMI",
      bloodGroups: <BloodType>[BloodType.abPlus],
    ));

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

    await service.createActivityAsync(BloodActivityModel.create(
      id: activityId,
      title: "activity 1",
      description: "activity 1",
      startDateTime: DateTime.now().add(const Duration(hours: 1)),
      endDateTime: DateTime.now().add(const Duration(hours: 2)),
      quota: 100,
      location: "somewhere",
      organizer: "PMI",
      bloodGroups: <BloodType>[BloodType.abPlus],
    ));

    final feed = await service.getActivityListAsync();

    expect(feed, isNotEmpty);
  });

  test(
    "if someone apply for an activity, an organizer can accept it",
    () async {
      final activityId = Uuid().v4();

      await session.validateAndSetCurrentUserAsync(
          "tortoise@gmail.com", "Password123");

      await service.createActivityAsync(BloodActivityModel.create(
        id: activityId,
        title: "activity 1",
        description: "activity 1",
        startDateTime: DateTime.now().add(const Duration(hours: 1)),
        endDateTime: DateTime.now().add(const Duration(hours: 2)),
        quota: 100,
        location: "somewhere",
        organizer: "PMI",
        bloodGroups: <BloodType>[BloodType.abPlus],
      ));

      await session.destroyAsync();

      await session.validateAndSetCurrentUserAsync(
          "achilless@gmail.com", "Password123");

      await service.applyAsync(activityId, "0838838124");

      final latestRegistration = (await registration.getAllAsync()).last;

      await service.acceptRegistrationAsync(latestRegistration.id);

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

    await service.createActivityAsync(BloodActivityModel.create(
      id: activityId,
      title: "activity 1",
      description: "activity 1",
      startDateTime: DateTime.now().add(const Duration(hours: 1)),
      endDateTime: DateTime.now().add(const Duration(hours: 2)),
      quota: 100,
      location: "somewhere",
      organizer: "PMI",
      bloodGroups: <BloodType>[BloodType.abPlus],
    ));

    await session.destroyAsync();

    await session.validateAndSetCurrentUserAsync(
        "achilless@gmail.com", "Password123");

    await service.applyAsync(activityId, "0838838124");

    final latestRegistration = (await registration.getAllAsync()).last;

    await service.rejectRegistrationAsync(latestRegistration.id);

    final acceptedRegistration =
        await registration.getByIdAsync(latestRegistration.id);

    expect(acceptedRegistration!.status, RegistrationStatus.rejected);
  });

  test("someone that is either accepted or rejected can be marked as pending",
      () async {
    final activityId = Uuid().v4();

    await session.validateAndSetCurrentUserAsync(
        "tortoise@gmail.com", "Password123");

    await service.createActivityAsync(BloodActivityModel.create(
      id: activityId,
      title: "activity 1",
      description: "activity 1",
      startDateTime: DateTime.now().add(const Duration(hours: 1)),
      endDateTime: DateTime.now().add(const Duration(hours: 2)),
      quota: 100,
      location: "somewhere",
      organizer: "PMI",
      bloodGroups: <BloodType>[BloodType.abPlus],
    ));

    await session.destroyAsync();

    await session.validateAndSetCurrentUserAsync(
        "achilless@gmail.com", "Password123");

    await service.applyAsync(activityId, "0838838124");

    final latestRegistration = (await registration.getAllAsync()).last;

    await service.acceptRegistrationAsync(latestRegistration.id);

    await service.markAsPendingAsync(latestRegistration.id);

    final acceptedRegistration =
        await registration.getByIdAsync(latestRegistration.id);

    expect(acceptedRegistration!.status, RegistrationStatus.pending);
  });

  test(
    "someone that is accepted can be marked as rejected",
    () async {
      final activityId = Uuid().v4();

      await session.validateAndSetCurrentUserAsync(
          "tortoise@gmail.com", "Password123");

      await service.createActivityAsync(BloodActivityModel.create(
        id: activityId,
        title: "activity 1",
        description: "activity 1",
        startDateTime: DateTime.now().add(const Duration(hours: 1)),
        endDateTime: DateTime.now().add(const Duration(hours: 2)),
        quota: 100,
        location: "somewhere",
        organizer: "PMI",
        bloodGroups: <BloodType>[BloodType.abPlus],
      ));

      await session.destroyAsync();

      await session.validateAndSetCurrentUserAsync(
          "achilless@gmail.com", "Password123");

      await service.applyAsync(activityId, "0838838124");

      final latestRegistration = (await registration.getAllAsync()).last;

      await service.acceptRegistrationAsync(latestRegistration.id);

      await service.rejectRegistrationAsync(latestRegistration.id);

      final acceptedRegistration =
          await registration.getByIdAsync(latestRegistration.id);

      expect(acceptedRegistration!.status, RegistrationStatus.rejected);
    },
  );

  test("someone that is rejected can be accepted", () async {
    final activityId = Uuid().v4();

    await session.validateAndSetCurrentUserAsync(
        "tortoise@gmail.com", "Password123");

    await service.createActivityAsync(BloodActivityModel.create(
      id: activityId,
      title: "activity 1",
      description: "activity 1",
      startDateTime: DateTime.now().add(const Duration(hours: 1)),
      endDateTime: DateTime.now().add(const Duration(hours: 2)),
      quota: 100,
      location: "somewhere",
      organizer: "PMI",
      bloodGroups: <BloodType>[BloodType.abPlus],
    ));

    await session.destroyAsync();

    await session.validateAndSetCurrentUserAsync(
        "achilless@gmail.com", "Password123");

    await service.applyAsync(activityId, "0838838124");

    final latestRegistration = (await registration.getAllAsync()).last;

    await service.rejectRegistrationAsync(latestRegistration.id);

    await service.acceptRegistrationAsync(latestRegistration.id);

    final acceptedRegistration =
        await registration.getByIdAsync(latestRegistration.id);

    expect(acceptedRegistration!.status, RegistrationStatus.accepted);
  });

  test("when an activity is held an hour ago, should not be on the feed",
      () async {
    await session.validateAndSetCurrentUserAsync(
        "tortoise@gmail.com", "Password123");

    await service.createActivityAsync(BloodActivityModel.create(
      quota: 20,
      title: "peduli sesama",
      id: Uuid().v4(),
      location: "somewhere",
      organizer: "PMI",
      endDateTime: DateTime.now().subtract(Duration(hours: 1)),
      startDateTime: DateTime.now().subtract(Duration(hours: 2)),
      bloodGroups: <BloodType>[],
      description: "blablabla",
      latitude: 120,
      longitude: 120,
      ownerEmail: "",
    ));

    final feed = await service.getActivityListAsync();

    expect(feed, isEmpty);
  });

  test("when an activity is created it can be deleted by the organizer",
      () async {
    await session.validateAndSetCurrentUserAsync(
        "tortoise@gmail.com", "Password123");

    final activityId = Uuid().v4();
    await service.createActivityAsync(BloodActivityModel.create(
      id: activityId,
      quota: 20,
      title: "peduli sesama",
      location: "somewhere",
      organizer: "PMI",
      startDateTime: DateTime.now().add(Duration(hours: 1)),
      endDateTime: DateTime.now().add(Duration(hours: 2)),
      bloodGroups: <BloodType>[],
      description: "blablabla",
      latitude: 120,
      longitude: 120,
      ownerEmail: "",
    ));

    await service.deleteActivityAsync(activityId);

    final feed = await service.getActivityListAsync();

    expect(feed, isEmpty);
  });

  test(
      "when an activity is created and then the title is edited, should reflect the newest title",
      () async {
    await session.validateAndSetCurrentUserAsync(
        "tortoise@gmail.com", "Password123");

    final activityId = Uuid().v4();
    await service.createActivityAsync(BloodActivityModel.create(
      id: activityId,
      quota: 20,
      title: "peduli sesama",
      location: "somewhere",
      organizer: "PMI",
      startDateTime: DateTime.now().add(Duration(hours: 1)),
      endDateTime: DateTime.now().add(Duration(hours: 2)),
      bloodGroups: <BloodType>[],
      description: "blablabla",
      latitude: 120,
      longitude: 120,
      ownerEmail: "",
    ));

    await service.editAsync(BloodActivityModel.create(
      id: activityId,
      quota: 20,
      title: "peduli bersama",
      location: "somewhere",
      organizer: "PMI",
      startDateTime: DateTime.now().add(Duration(hours: 1)),
      endDateTime: DateTime.now().add(Duration(hours: 2)),
      bloodGroups: <BloodType>[],
      description: "blablabla",
      latitude: 120,
      longitude: 120,
      ownerEmail: "",
    ));

    final newactivity = (await service.getActivityListAsync()).last;

    expect(newactivity.title, "peduli bersama");
  });

  test("when a registration is created, should be viewable", () async {
    final activityId = Uuid().v4();

    await session.validateAndSetCurrentUserAsync(
        "tortoise@gmail.com", "Password123");

    await service.createActivityAsync(BloodActivityModel.create(
      id: activityId,
      title: "activity 1",
      description: "activity 1",
      startDateTime: DateTime.now().add(const Duration(hours: 1)),
      endDateTime: DateTime.now().add(const Duration(hours: 2)),
      quota: 100,
      location: "somewhere",
      organizer: "PMI",
      bloodGroups: <BloodType>[BloodType.abPlus],
    ));

    await session.destroyAsync();

    await session.validateAndSetCurrentUserAsync(
        "achilless@gmail.com", "Password123");

    await service.applyAsync(activityId, "0838838124");

    expect(await service.getRegistrationAsync(), isNotEmpty);
  });

  test("when registration is created, should be able to retrieve it's id",
      () async {
    final activityId = Uuid().v4();

    await session.validateAndSetCurrentUserAsync(
        "tortoise@gmail.com", "Password123");

    await service.createActivityAsync(BloodActivityModel.create(
      id: activityId,
      title: "activity 1",
      description: "activity 1",
      startDateTime: DateTime.now().add(const Duration(hours: 1)),
      endDateTime: DateTime.now().add(const Duration(hours: 2)),
      quota: 100,
      location: "somewhere",
      organizer: "PMI",
      bloodGroups: <BloodType>[BloodType.abPlus],
    ));

    await session.destroyAsync();

    await session.validateAndSetCurrentUserAsync(
        "achilless@gmail.com", "Password123");

    final id = await service.applyAsync(activityId, "0838838124");

    expect(id, isNotNull);
  });

  test(
      "when rejecting someone in an activity, should decrement the registered count",
      () async {
    final activityId = Uuid().v4();

    await session.validateAndSetCurrentUserAsync(
        "tortoise@gmail.com", "Password123");

    await service.createActivityAsync(BloodActivityModel.create(
      id: activityId,
      title: "activity 1",
      description: "activity 1",
      startDateTime: DateTime.now().add(const Duration(hours: 1)),
      endDateTime: DateTime.now().add(const Duration(hours: 2)),
      quota: 100,
      location: "somewhere",
      organizer: "PMI",
      bloodGroups: <BloodType>[BloodType.abPlus],
    ));

    await session.destroyAsync();

    await session.validateAndSetCurrentUserAsync(
        "achilless@gmail.com", "Password123");

    final id = await service.applyAsync(activityId, "0838838124");

    await session.destroyAsync();

    await session.validateAndSetCurrentUserAsync(
        "tortoise@gmail.com", "Password123");

    await service.rejectRegistrationAsync(id!);

    final latestActivity = (await service.getActivityListAsync()).last;

    expect(latestActivity.registered, 0);
  });

  test(
      "when marking a rejected registration as accepted, should increment the registered count",
      () async {
    final activityId = Uuid().v4();

    await session.validateAndSetCurrentUserAsync(
        "tortoise@gmail.com", "Password123");

    await service.createActivityAsync(BloodActivityModel.create(
      id: activityId,
      title: "activity 1",
      description: "activity 1",
      startDateTime: DateTime.now().add(const Duration(hours: 1)),
      endDateTime: DateTime.now().add(const Duration(hours: 2)),
      quota: 100,
      location: "somewhere",
      organizer: "PMI",
      bloodGroups: <BloodType>[BloodType.abPlus],
    ));

    await session.destroyAsync();

    await session.validateAndSetCurrentUserAsync(
        "achilless@gmail.com", "Password123");

    final id = await service.applyAsync(activityId, "0838838124");

    await session.destroyAsync();

    await session.validateAndSetCurrentUserAsync(
        "tortoise@gmail.com", "Password123");

    await service.rejectRegistrationAsync(id!);
    await service.acceptRegistrationAsync(id);

    final latestActivity = (await service.getActivityListAsync()).last;

    expect(latestActivity.registered, 1);
  });
}
