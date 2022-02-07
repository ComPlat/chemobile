import 'dart:convert';

import 'package:flutter/foundation.dart';

void devPrint(String str) {
  if (kDebugMode) debugPrint(str, wrapWidth: 1000);
}

void printJson(String json) {
  JsonEncoder encoder = const JsonEncoder.withIndent('  ');
  String prettyprint = encoder.convert(json);
  devPrint(prettyprint);
}
