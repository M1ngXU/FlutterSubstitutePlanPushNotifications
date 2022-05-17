// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'substitute.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Substitute _$SubstituteFromJson(Map<String, dynamic> json) => Substitute(
      json['id'] as int,
      DateTime.parse(json['date'] as String),
      json['comment'] as String,
      (json['teachers'] as List<dynamic>).map((e) => e as String).toList(),
      json['subject'] as String,
      (json['rooms'] as List<dynamic>).map((e) => e as String).toList(),
      json['kind'] as String,
      _hoursFromJson(json['hours'] as List),
      $enumDecodeNullable(_$SubstituteStateEnumMap, json['state']),
    );

Map<String, dynamic> _$SubstituteToJson(Substitute instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'comment': instance.comment,
      'teachers': instance.teachers,
      'subject': instance.subject,
      'rooms': instance.rooms,
      'kind': instance.kind,
      'hours': _hoursToJson(instance.hours),
      'state': _$SubstituteStateEnumMap[instance.state],
    };

const _$SubstituteStateEnumMap = {
  SubstituteState.removed: 'removed',
  SubstituteState.added: 'added',
  SubstituteState.modified: 'modified',
  SubstituteState.noChange: 'noChange',
  SubstituteState.expired: 'expired',
};
