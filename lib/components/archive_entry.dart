import 'dart:io';

import 'package:chemobile/models/sample_task.dart';
import 'package:chemobile/models/scan_result.dart';
import 'package:flutter/material.dart';

class ArchiveEntry extends StatelessWidget {
  final SampleTask sampleTask;
  final void Function(SampleTask sampleTask) onTap;
  const ArchiveEntry({Key? key, required this.sampleTask, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScanResult lastScanResult = sampleTask.scanResults[sampleTask.scanResults.length - 1];
    return Card(
      child: ListTile(
        leading: Image.file(File(lastScanResult.imagePath!), height: 60.0),
        trailing: const Icon(Icons.chevron_right, size: 36),
        title: Text(title(), textAlign: TextAlign.left),
        subtitle: Text(subtitle(), textAlign: TextAlign.left, textScaleFactor: 0.8),
        onTap: () => onTap(sampleTask),
      ),
    );
  }

  String title() {
    return sampleTask.title();
  }

  String subtitle() {
    return "${sampleTask.scanResults.length} scan results";
  }
}
