// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SduiResponse _$SduiResponseFromJson(Map<String, dynamic> json) =>
    _SduiResponse(
      json['data'],
      json['status'] as String,
      _Meta.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SduiResponseToJson(_SduiResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'status': instance.status,
      'meta': instance.meta,
    };

_Meta _$MetaFromJson(Map<String, dynamic> json) => _Meta(
      (json['warnings'] as List<dynamic>).map((e) => e as String).toList(),
      (json['errors'] as List<dynamic>).map((e) => e as String).toList(),
      (json['success'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$MetaToJson(_Meta instance) => <String, dynamic>{
      'warnings': instance.warnings,
      'errors': instance.errors,
      'success': instance.success,
    };
