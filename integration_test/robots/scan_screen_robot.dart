import 'package:chemobile/helpers/dev_print.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class ScanScreenRobot {
  const ScanScreenRobot(this.tester);

  final WidgetTester tester;

  Future<void> saveScan() async {
    await tester.pumpAndSettle();
    await _validateScanScreen();
    await _findOcrResult();
    await _saveOcrResult();
  }

  Future<void> _validateScanScreen() async {
    expect(find.widgetWithText(AppBar, 'Chemobile Scan'), findsOneWidget);
  }

  // is supposed to run through the scanning process and stop at the last step (value correction)
  Future<void> _findOcrResult() async {
    Key valueSelectorKey = const Key('valueSelector');
    Key valueCorrectorKey = const Key('valueCorrector');

    await tester.pumpAndSettle(const Duration(seconds: 30));
    Finder stageIndicator = find.byWidgetPredicate(
      (Widget widget) {
        bool foundValueSelector = widget is Container && widget.key == valueSelectorKey;
        bool foundValueCorrector = widget is Container && widget.key == valueCorrectorKey;

        return foundValueSelector || foundValueCorrector;
      },
    );
    Widget stageIndicatorWidget = const Text('someInitialStuffThatIsNeverUsed');
    expect(stageIndicator, findsOneWidget);

    try {
      stageIndicatorWidget = tester.widget(stageIndicator);
    } on StateError {
      devPrint('Error with stageIndicatorWidget, ignore for now');
    }

    if (stageIndicatorWidget.key == valueSelectorKey) {
      devPrint("========== VALUE SELECTOR DETECTED: continue to value corrector");
      Finder valueButton =
          find.descendant(of: stageIndicator, matching: find.byType(OutlinedButton));
      expect(valueButton, findsWidgets);
      await tester.tap(valueButton.first);
    }
    await tester.pumpAndSettle(const Duration(seconds: 10));
    Finder valueCorrector = find.byKey(valueCorrectorKey);
    expect(valueCorrector, findsOneWidget);
  }

  Future<void> _saveOcrResult() async {
    Finder submitButton = find.byKey(const Key('submitScan'));
    await tester.dragUntilVisible(
        submitButton, find.byKey(const Key('scanScreenListView')), const Offset(0, -100));
    await tester.pumpAndSettle(const Duration(seconds: 10));
    await tester.tap(submitButton);
  }
}
