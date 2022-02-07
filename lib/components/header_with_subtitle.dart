import 'package:flutter/material.dart';

class HeaderWithSubtitle extends StatefulWidget {
  final String title;
  final String? subtitle;
  const HeaderWithSubtitle({Key? key, required this.title, this.subtitle}) : super(key: key);

  @override
  State<HeaderWithSubtitle> createState() => _HeaderWithSubtitleState();
}

class _HeaderWithSubtitleState extends State<HeaderWithSubtitle> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        widget.title,
        textAlign: TextAlign.center,
        maxLines: 1,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      subtitle: subtitle(),
    );
  }

  Widget? subtitle() {
    if (widget.subtitle == null) {
      return null;
    }

    return Text(
      widget.subtitle!,
      textAlign: TextAlign.center,
      textScaleFactor: 0.8,
      style: const TextStyle(color: Colors.white70),
    );
  }
}
