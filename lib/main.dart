import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'pages/auth/login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const BloodConnectApp());
}

class BloodConnectApp extends StatelessWidget {
  const BloodConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Volunteer BloodConnect',
      theme: AppTheme.lightTheme,
      home: const LoginPage(),
    );
  }
}
