import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

class TaskListRobot {
  const TaskListRobot(this.tester);

  final WidgetTester tester;

  Future<void> startNewScan() async {
    await tester.pumpAndSettle();
    _validateTaskList();

    await tester.tap(find.widgetWithText(BottomNavigationBar, 'Start single scan'));
  }

  Future<void> backToMenuScreen() async {
    await tester.pumpAndSettle();
    _validateTaskList();

    await tester.tap(find.byType(BackButton));
  }

  void _validateTaskList() async {
    expect(find.widgetWithText(AppBar, 'Finished tasks'), findsOneWidget);
  }
}
