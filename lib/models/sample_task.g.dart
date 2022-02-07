// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sample_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SampleTask _$SampleTaskFromJson(Map<String, dynamic> json) => SampleTask(
      json['id'] as int?,
      json['required_scan_results'] as int,
      json['sample_id'] as int?,
      json['short_label'] as String?,
      (json['scan_results'] as List<dynamic>)
          .map((e) => ScanResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['display_name'] as String?,
      json['description'] as String,
      json['user_uuid'] as String,
      (json['target_amount_value'] as num?)?.toDouble(),
      json['target_amount_unit'] as String?,
      json['sample_svg_file'] as String?,
    );

Map<String, dynamic> _$SampleTaskToJson(SampleTask instance) =>
    <String, dynamic>{
      'id': instance.id,
      'required_scan_results': instance.requiredScanResults,
      'sample_id': instance.sampleId,
      'short_label': instance.shortLabel,
      'scan_results': instance.scanResults.map((e) => e.toJson()).toList(),
      'display_name': instance.displayName,
      'description': instance.description,
      'user_uuid': instance.userUuid,
      'target_amount_value': instance.targetAmountValue,
      'target_amount_unit': instance.targetAmountUnit,
      'sample_svg_file': instance.sampleSvgFile,
    };
