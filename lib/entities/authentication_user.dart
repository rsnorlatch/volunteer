import 'package:uuid/uuid.dart';

class AuthenticationUser {
  AuthenticationUser(this.fullname, this.email, this.password)
      : id = const Uuid().v4();

  String id;
  String fullname;
  String email;
  String
      password; // Dummy lokal untuk tugas frontend, bukan penyimpanan produksi.
}
