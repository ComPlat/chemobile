import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

class MenuScreenRobot {
  const MenuScreenRobot(this.tester);

  final WidgetTester tester;

  Future<void> openTaskList() async {
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Unfinished tasks'));
  }

  Future<void> openArchive() async {
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Finished tasks'));
  }
}
