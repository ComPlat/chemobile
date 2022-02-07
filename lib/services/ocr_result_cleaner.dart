import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrResultCleaner {
  List<String> results = [];

  OcrResultCleaner();

  List<double> processResult(RecognizedText recognizedText) {
    _prepareRecognizedText(recognizedText);

    _removeNonDigitsInAllLines();
    _removeEmptyLines();
    _removeLinesLowerThanFour();
    _addDecimalPoint();

    return results.map((r) => double.parse(r)).toList();
  }

  void _prepareRecognizedText(RecognizedText recognizedText) {
    for (final textBlock in recognizedText.blocks) {
      for (final textLine in textBlock.lines) {
        results.add(textLine.text);
      }
    }
  }

  void _removeNonDigitsInAllLines() {
    List<String> subResults = [];

    for (final result in results) {
      subResults.add(result.replaceAll(RegExp("[^\\d]"), ""));
    }

    results = subResults;
  }

  void _removeEmptyLines() {
    List<String> subResults = [];

    for (final result in results) {
      if (result.isNotEmpty) {
        subResults.add(result);
      }
    }

    results = subResults;
  }

  void _removeLinesLowerThanFour() {
    List<String> subResults = [];

    for (final result in results) {
      if (result.length > 4) {
        subResults.add(result);
      }
    }

    results = subResults;
  }

  void _addDecimalPoint() {
    List<String> subResults = [];

    for (final result in results) {
      String resultWithDecimalPoint = result.replaceAllMapped(
        RegExp(r'^(.*)(.{4})$'),
        (Match m) => "${m[1]}.${m[2]}",
      );

      subResults.add(resultWithDecimalPoint);
    }

    results = subResults;
  }
}
