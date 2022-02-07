import 'package:flutter/material.dart';

class MenuEntry {
  final String ident;
  final String title;
  final String? subTitle;
  final Icon icon;

  MenuEntry({
    required this.ident,
    required this.title,
    this.subTitle,
    required this.icon,
  });
}
