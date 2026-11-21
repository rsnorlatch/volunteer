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
}
