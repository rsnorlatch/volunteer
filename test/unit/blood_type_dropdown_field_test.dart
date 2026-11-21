import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volunteer/shared/widgets/blood_type_dropdown_field.dart';
import 'package:volunteer/shared/widgets/custom_text_field.dart';

void main() {
  testWidgets('dropdown matches input size and stays within the field width',
      (tester) async {
    String? selectedBloodType;
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 280,
              child: Form(
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'Email',
                      hint: 'nama@email.com',
                      controller: controller,
                    ),
                    BloodTypeDropdownField(
                      initialValue: null,
                      onChanged: (value) => selectedBloodType = value,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final dropdown = tester
        .widget<DropdownButton<String>>(find.byType(DropdownButton<String>));
    expect(dropdown.menuWidth, 280);
    final decorators = find.byType(InputDecorator);
    expect(
      tester.getSize(decorators.at(1)).height,
      tester.getSize(decorators.first).height,
    );

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('O+').last);
    await tester.pumpAndSettle();

    expect(selectedBloodType, 'O+');
  });
}
