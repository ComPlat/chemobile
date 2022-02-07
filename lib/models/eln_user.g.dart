// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eln_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ElnUser _$ElnUserFromJson(Map<String, dynamic> json) => ElnUser(
      json['token'] as String,
      json['uuid'] as String,
      json['firstName'] as String,
      json['lastName'] as String,
      json['elnIdentifier'] as String,
      json['elnUrl'] as String,
    );

Map<String, dynamic> _$ElnUserToJson(ElnUser instance) => <String, dynamic>{
      'token': instance.token,
      'uuid': instance.uuid,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'elnIdentifier': instance.elnIdentifier,
      'elnUrl': instance.elnUrl,
    };
