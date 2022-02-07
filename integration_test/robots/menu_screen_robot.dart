import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

class MenuScreenRobot {
  const MenuScreenRobot(this.tester);

  final WidgetTester tester;

  Future<void> openTaskList() async {
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Weighted samples'));
  }

  Future<void> openArchive() async {
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Previous Scans'));
  }
}
