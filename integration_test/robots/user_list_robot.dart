import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

class UserListRobot {
  const UserListRobot(this.tester);

  final WidgetTester tester;

  Future<bool> userListActive() async {
    await tester.pumpAndSettle(const Duration(seconds: 10));

    try {
      tester.element(find.widgetWithText(AppBar, 'Available Users'));
    } on StateError {
      return false;
    }
    return true;
  }
}
