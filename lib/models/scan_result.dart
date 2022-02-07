import 'package:json_annotation/json_annotation.dart';

part 'scan_result.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.snake,
  createToJson: true,
)
class ScanResult {
  int? id;
  final double measurementValue;
  final String measurementUnit;
  final String title;
  int position;
  final String? imagePath;

  ScanResult({
    this.id,
    required this.measurementValue,
    required this.measurementUnit,
    required this.title,
    required this.position,
    required this.imagePath,
  });

  ScanResult.copyFrom(ScanResult otherScanResult)
      : id = null,
        measurementValue = otherScanResult.measurementValue,
        measurementUnit = otherScanResult.measurementUnit,
        title = otherScanResult.title,
        position = otherScanResult.position,
        imagePath = otherScanResult.imagePath;

  factory ScanResult.fromJson(Map<String, dynamic> data) => _$ScanResultFromJson(data);
  Map<String, dynamic> toJson() => _$ScanResultToJson(this);
}
