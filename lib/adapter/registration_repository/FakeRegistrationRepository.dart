import 'package:get/get_rx/get_rx.dart';
import 'package:volunteer/data/models/registration.dart';

class FakeRegistrationRepository {
  final registrations = <Registration>[];

  Future<List<Registration>> getAll() async {
    return registrations;
  }

  Future<Registration?> getByIdAsync(String id) async {
    return registrations
        .where((registration) => registration.id == id)
        .firstOrNull;
  }

  Future<void> insertAsync(Registration registration) async {
    registrations.add(registration);
  }

  Future<void> updateAsync(Registration registration) async {
    for (int i = 0; i <= registrations.length - 1; i++) {
      if (registrations[i].id == registration.id) {
        registrations[i] = registration;
      }
    }
  }
}
