import 'package:uuid/uuid.dart';

class User {
  new(this.username, this.email, this.password);

  Uuid id = Uuid();
  String username;
  String email;
  String password;

  User withId(Uuid id) {
    this.id = id;

    return this;
  }
}
