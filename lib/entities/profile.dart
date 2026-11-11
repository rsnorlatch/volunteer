import 'package:uuid/uuid.dart';
import 'package:volunteer/entities/role.dart';

class Profile {
  new(this.username, this.email, this.role);

  Uuid id = Uuid();
  Uuid? userId;
  String username;
  String email;
  Role role;

  Profile withUserId(Uuid userId) {
    this.userId = userId;

    return this;
  }
}
