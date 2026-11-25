import 'package:volunteer/adapter/registration_repository/registration_repository_interface.dart';
import 'package:volunteer/data/models/registration.dart';

class FakeRegistrationRepository implements RegistrationRepositoryInterface {
  final registrations = <Registration>[];

  @override
  Future<List<Registration>> getAllAsync() async {
    return registrations;
  }

  @override
  Future<Registration?> getByIdAsync(String id) async {
    return registrations
        .where((registration) => registration.id == id)
        .firstOrNull;
  }

  @override
  Future<void> insertAsync(Registration registration) async {
    registrations.add(registration);
  }

  Future<void> insertAll(List<Registration> registrationsToInsert) async {
    registrations.addAll(registrationsToInsert);
  }

  @override
  Future<void> updateAsync(Registration registration) async {
    for (int i = 0; i < registrations.length; i++) {
      if (registrations[i].id == registration.id) {
        registrations[i] = registration;
      }
    }
  }

  @override
  Future<void> deleteByIdAsync(String registrationId) async {
    registrations.removeWhere((r) => r.id == registrationId);
  }
}
