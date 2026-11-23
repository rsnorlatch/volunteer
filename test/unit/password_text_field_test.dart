import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volunteer/shared/widgets/password_text_field.dart';

void main() {
  testWidgets('password visibility can be toggled without clearing input',
      (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PasswordTextField(
            label: 'Kata sandi',
            hint: 'Masukkan kata sandi',
            controller: controller,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'password123');
    expect(tester.widget<EditableText>(find.byType(EditableText)).obscureText,
        isTrue);

    await tester.tap(find.byTooltip('Tampilkan kata sandi'));
    await tester.pumpAndSettle();

    expect(tester.widget<EditableText>(find.byType(EditableText)).obscureText,
        isFalse);
    expect(controller.text, 'password123');

    await tester.tap(find.byTooltip('Sembunyikan kata sandi'));
    await tester.pumpAndSettle();

    expect(tester.widget<EditableText>(find.byType(EditableText)).obscureText,
        isTrue);
    expect(controller.text, 'password123');
  });

  testWidgets('reset password fields toggle visibility independently',
      (tester) async {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    addTearDown(passwordController.dispose);
    addTearDown(confirmController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              PasswordTextField(
                label: 'Password Baru',
                hint: 'Minimal 8 karakter',
                controller: passwordController,
              ),
              PasswordTextField(
                label: 'Konfirmasi Password',
                hint: 'Masukkan kembali password baru',
                controller: confirmController,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'NewPassword123');
    await tester.enterText(find.byType(TextFormField).at(1), 'NewPassword123');
    await tester.tap(find.byTooltip('Tampilkan kata sandi').first);
    await tester.pumpAndSettle();

    final fields = tester.widgetList<EditableText>(find.byType(EditableText));
    expect(fields.map((field) => field.obscureText), [false, true]);
    expect(passwordController.text, 'NewPassword123');
    expect(confirmController.text, 'NewPassword123');
  });
}
