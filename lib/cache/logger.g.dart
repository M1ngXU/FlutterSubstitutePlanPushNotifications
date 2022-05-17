// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logger.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Log _$LogFromJson(Map<String, dynamic> json) => Log(
      DateTime.parse(json['time'] as String),
      $enumDecode(_$LogTypeEnumMap, json['type']),
      json['content'] as String,
    );

Map<String, dynamic> _$LogToJson(Log instance) => <String, dynamic>{
      'time': instance.time.toIso8601String(),
      'type': _$LogTypeEnumMap[instance.type],
      'content': instance.content,
    };

const _$LogTypeEnumMap = {
  LogType.debug: 'debug',
  LogType.info: 'info',
  LogType.warning: 'warning',
  LogType.error: 'error',
};
