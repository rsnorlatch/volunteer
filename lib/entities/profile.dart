import 'package:uuid/uuid.dart';
import 'package:volunteer/entities/role.dart';

class Profile {
  Profile(this.username, this.email, this.role) : id = const Uuid().v4();

  String id;
  String? userId;
  String username;
  String email;
  Role role;

  Profile withUserId(String userId) {
    this.userId = userId;
    return this;
  }
}
