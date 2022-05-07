// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Time _$TimeFromJson(Map<String, dynamic> json) => Time(
      json['order'] as int,
      json['name'] as String,
      json['from'] == null ? null : DateTime.parse(json['from'] as String),
      json['to'] == null ? null : DateTime.parse(json['to'] as String),
    );

Map<String, dynamic> _$TimeToJson(Time instance) => <String, dynamic>{
      'order': instance.order,
      'name': instance.name,
      'from': instance.from.toIso8601String(),
      'to': instance.to.toIso8601String(),
    };
