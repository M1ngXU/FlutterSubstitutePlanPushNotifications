// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'substitute.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Substitute _$SubstituteFromJson(Map<String, dynamic> json) => Substitute(
      json['id'] as String,
      DateTime.parse(json['date'] as String),
      json['description'] as String,
      json['teacher'] as String,
      json['subject'] as String,
      json['room'] as String,
      json['kind'] as String,
      json['day'] as int,
      _hoursFromJson(json['hours'] as List<Map<String, dynamic>>),
      $enumDecode(_$SubstituteStateEnumMap, json['state']),
    );

Map<String, dynamic> _$SubstituteToJson(Substitute instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'description': instance.description,
      'teacher': instance.teacher,
      'subject': instance.subject,
      'room': instance.room,
      'kind': instance.kind,
      'day': instance.day,
      'hours': _hoursToJson(instance.hours),
      'state': _$SubstituteStateEnumMap[instance.state],
    };

const _$SubstituteStateEnumMap = {
  SubstituteState.removed: 'removed',
  SubstituteState.added: 'added',
};
