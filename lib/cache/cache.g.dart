// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cache _$CacheFromJson(Map<String, dynamic> json) => Cache(
      LoginData.fromJson(json['loginData'] as Map<String, dynamic>),
      (json['substitutes'] as List<dynamic>?)
              ?.map((e) => Substitute.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      _timesFromJson(json['times'] as Map<String, dynamic>),
      DateTime.parse(json['lastServerUpdate'] as String),
      DateTime.parse(json['lastClientUpdate'] as String),
    );

Map<String, dynamic> _$CacheToJson(Cache instance) => <String, dynamic>{
      'loginData': instance.loginData.toJson(),
      'substitutes': instance.substitutes.map((e) => e.toJson()).toList(),
      'times': _timesToJson(instance.times),
      'lastServerUpdate': instance.lastServerUpdate.toIso8601String(),
      'lastClientUpdate': instance.lastClientUpdate.toIso8601String(),
    };
