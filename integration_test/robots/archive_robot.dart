import 'package:chemobile/components/weighted_sample_archive_entry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

class ArchiveRobot {
  const ArchiveRobot(this.tester);

  final WidgetTester tester;

  Future<void> findArchivedScans({required int count}) async {
    await tester.pumpAndSettle();
    await _validateArchiveScreen();

    expect(find.byType(WeightedSampleArchiveEntry), findsNWidgets(count));
  }

  Future<void> openFirstScan() async {
    await tester.tap(find.byType(WeightedSampleArchiveEntry).first);
  }

  Future<void> _validateArchiveScreen() async {
    expect(find.widgetWithText(AppBar, 'Previous Scans'), findsOneWidget);
  }
}
