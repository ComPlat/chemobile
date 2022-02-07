import 'dart:core';
import 'package:chemobile/models/scan_result.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sample_task.g.dart';

@JsonSerializable(
  explicitToJson: true,
  fieldRename: FieldRename.snake,
  createToJson: true,
)
class SampleTask {
  int? id;
  final int requiredScanResults;
  final int? sampleId;
  final String? shortLabel;
  final List<ScanResult> scanResults;
  final String? displayName;
  final String description;
  final String userUuid;
  final double? targetAmountValue;
  final String? targetAmountUnit;
  final String? sampleSvgFile;

  SampleTask(
    this.id,
    this.requiredScanResults,
    this.sampleId,
    this.shortLabel,
    this.scanResults,
    this.displayName,
    this.description,
    this.userUuid,
    this.targetAmountValue,
    this.targetAmountUnit,
    this.sampleSvgFile,
  );

  SampleTask.newScan(this.userUuid, this.requiredScanResults)
      : id = null,
        sampleId = null,
        shortLabel = null,
        displayName = null,
        scanResults = [],
        description = requiredScanResults == 1 ? 'New single scan' : 'New Double Scan',
        targetAmountValue = null,
        targetAmountUnit = null,
        sampleSvgFile = null;

  SampleTask.copyFrom(SampleTask otherTask)
      : id = null,
        requiredScanResults = otherTask.requiredScanResults,
        sampleId = otherTask.sampleId,
        shortLabel = otherTask.shortLabel,
        scanResults = otherTask.scanResults
            .map((ScanResult scanResult) => ScanResult.copyFrom(scanResult))
            .toList(),
        displayName = otherTask.displayName,
        description = otherTask.description,
        userUuid = otherTask.userUuid,
        targetAmountValue = otherTask.targetAmountValue,
        targetAmountUnit = otherTask.targetAmountUnit,
        sampleSvgFile = otherTask.sampleSvgFile;

  String title() {
    String prefix = shortLabel == null ? '' : '$shortLabel: ';
    String title = displayName ?? description;
    String suffix = ' ($id)';
    String result = '$prefix$title$suffix';
    return result;
  }

  Uri sampleSvgUrl(String svgBaseUrl) {
    return Uri.parse('$svgBaseUrl/images/samples/$sampleSvgFile');
  }

  factory SampleTask.fromJson(Map<String, dynamic> data) => _$SampleTaskFromJson(data);
  Map<String, dynamic> toJson() => _$SampleTaskToJson(this);

  bool archivable() {
    return scanResults.length == requiredScanResults;
  }
}
