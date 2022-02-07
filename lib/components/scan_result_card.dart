import 'dart:io';

import 'package:chemobile/models/scan_result.dart';
import 'package:chemobile/screens/ImageScreen.dart';
import 'package:flutter/material.dart';

class ScanResultCard extends StatefulWidget {
  final ScanResult scanResult;
  const ScanResultCard({Key? key, required this.scanResult}) : super(key: key);

  @override
  State<ScanResultCard> createState() => _ScanResultCardState();
}

class _ScanResultCardState extends State<ScanResultCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(left: 50.0),
      child: ListTile(
        leading: Image.file(File(widget.scanResult.imagePath!), height: 60.0),
        title: Text(widget.scanResult.title, textAlign: TextAlign.left),
        subtitle: Text(
          "${widget.scanResult.measurementValue} ${widget.scanResult.measurementUnit}",
          textAlign: TextAlign.left,
          textScaleFactor: 0.8,
        ),
        onTap: _openImageScreen,
      ),
    );
  }

  void _openImageScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return ImageScreen(
          title: widget.scanResult.title,
          image: File(
            widget.scanResult.imagePath!,
          ),
        );
      }),
    );
  }
}
