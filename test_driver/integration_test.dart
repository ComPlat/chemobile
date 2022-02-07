// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:integration_test/integration_test_driver.dart';
import 'package:path/path.dart' as path;

Future<void> main() async {
  // final Map<String, String> envVars = Platform.environment;
  const String adbPath = '/usr/local/bin/adb';
  await Process.run(
    adbPath,
    ['shell', 'pm', 'grant', 'com.example.chemobile', 'android.permission.CAMERA'],
  );

  await integrationDriver(responseDataCallback: (Map<String, dynamic>? data) async {
    await fs.directory(_destinationDirectory).create(recursive: true);

    final file = fs.file(path.join(
      _destinationDirectory,
      '$_testOutputFilename.json',
    ));

    final resultString = _encodeJson(data);
    await file.writeAsString(resultString);
  });
}

String _encodeJson(Map<String, dynamic>? jsonObject) {
  return _prettyEncoder.convert(jsonObject);
}

const _prettyEncoder = JsonEncoder.withIndent('  ');
const _testOutputFilename = 'integration_response_data';
const _destinationDirectory = 'integration_test';
