import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

class LoginFormRobot {
  const LoginFormRobot(this.tester);

  final WidgetTester tester;

  Future<void> login(
      {String userIdentifier = 'matt',
      String password = 'bla',
      String elnUrl = 'keks',
      String validationUser = 'Matthias Döring'}) async {
    await tester.pumpAndSettle();
    await _enterText(const Key('userIdentifierInput'), userIdentifier);
    await _enterText(const Key('passwordInput'), password);
    await _enterText(const Key('elnUrlInput'), elnUrl);
    await _submit();

    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, validationUser), findsOneWidget);
  }

  Future<void> _enterText(Key widgetKey, String input) async {
    await tester.pumpAndSettle(const Duration(seconds: 3));
    Finder inputfield = find.byWidgetPredicate(
      (widget) => widget is TextFormField && widget.key == widgetKey,
    );
    await tester.enterText(inputfield, input);
  }

  Future<void> _submit() async {
    await tester.pumpAndSettle();
    Finder submitButton = find.widgetWithText(OutlinedButton, 'Login');
    await tester.tap(submitButton);
  }
}
