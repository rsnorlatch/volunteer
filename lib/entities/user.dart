import 'package:uuid/uuid.dart';

class User {
  User(this.username, this.email, this.password) : id = const Uuid().v4();

  String id;
  String username;
  String email;
  String password; // Dummy lokal untuk tugas frontend, bukan penyimpanan produksi.
}
