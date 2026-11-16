# Volunteer - BloodDonor (Frontend)

Project Flutter frontend dengan GetX dan autentikasi dummy lokal (in-memory). Tidak menggunakan Supabase/API/backend.

## Menjalankan

1. Buka folder project `volunteer` di VS Code.
2. Jalankan `flutter pub get`.
3. Jalankan `flutter run`.

## Catatan

- Registrasi dan login memakai data dummy yang tersimpan selama aplikasi berjalan.
- Buat akun terlebih dahulu pada halaman Daftar, lalu login menggunakan email atau username dan password yang sama.
- Data akan hilang ketika aplikasi ditutup/restart. Ini bukan autentikasi produksi.
- `pubspec.lock` akan disesuaikan otomatis oleh `flutter pub get` sesuai dependency di `pubspec.yaml`.
