import 'package:volunteer/data/models/registration.dart';

abstract interface class RegistrationRepositoryInterface {
  Future<List<Registration>> getAllAsync();

  Future<Registration?> getByIdAsync(String id);

  Future<void> insertAsync(Registration registration);

  Future<void> updateAsync(Registration registration);

  Future<void> deleteByIdAsync(String registrationId);
}
