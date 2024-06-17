// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScanResult _$ScanResultFromJson(Map<String, dynamic> json) => ScanResult(
      id: (json['id'] as num?)?.toInt(),
      measurementValue: (json['measurement_value'] as num).toDouble(),
      measurementUnit: json['measurement_unit'] as String,
      title: json['title'] as String,
      position: (json['position'] as num).toInt(),
      imagePath: json['image_path'] as String?,
    );

Map<String, dynamic> _$ScanResultToJson(ScanResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'measurement_value': instance.measurementValue,
      'measurement_unit': instance.measurementUnit,
      'title': instance.title,
      'position': instance.position,
      'image_path': instance.imagePath,
    };
