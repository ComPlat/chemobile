import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message, {bool success = false}) {
  var colorScheme = Theme.of(context).colorScheme;
  var backgroundColor = success ? colorScheme.primary : colorScheme.error;

  final snackBar = SnackBar(
    content: Text(message),
    backgroundColor: backgroundColor,
    duration: const Duration(seconds: 3),
    behavior: SnackBarBehavior.fixed,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
