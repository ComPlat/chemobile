import 'package:chemobile/components/archive_entry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

class ArchiveRobot {
  const ArchiveRobot(this.tester);

  final WidgetTester tester;

  Future<void> findArchivedScans({required int count}) async {
    await tester.pumpAndSettle();
    await _validateArchiveScreen();

    expect(find.byType(ArchiveEntry), findsNWidgets(count));
  }

  Future<void> openFirstScan() async {
    await tester.tap(find.byType(ArchiveEntry).first);
  }

  Future<void> _validateArchiveScreen() async {
    expect(find.widgetWithText(AppBar, 'Previous Scans'), findsOneWidget);
  }
}
