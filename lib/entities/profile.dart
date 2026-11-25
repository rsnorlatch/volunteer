import 'package:uuid/uuid.dart';
import 'package:volunteer/entities/role.dart';

class Profile {
  Profile(this.username, this.email, this.role,
      {this.bloodType = '', this.phone = '', this.medicalNotes = ''})
      : id = const Uuid().v4();

  String id;
  String? userId;
  String username;
  String email;
  Role role;
  String bloodType;
  String phone;
  String medicalNotes;

  Profile withUserId(String userId) {
    this.userId = userId;
    return this;
  }

  Profile withId(String id) {
    this.id = id;

    return this;
  }
}
