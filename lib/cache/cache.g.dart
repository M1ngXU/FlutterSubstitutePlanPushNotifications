// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cache _$CacheFromJson(Map<String, dynamic> json) => Cache(
      loginData: json['loginData'] == null
          ? null
          : LoginData.fromJson(json['loginData'] as Map<String, dynamic>),
      substitutes: (json['substitutes'] as List<dynamic>?)
              ?.map((e) => Substitute.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      times: _timesFromJson(json['times'] as Map<String, dynamic>?),
      lastServerUpdate: _tryParseDate(json['lastServerUpdate'] as String?),
      lastClientUpdate: _tryParseDate(json['lastClientUpdate'] as String?),
      showHolidays: json['showHolidays'] as bool? ?? false,
      version: json['version'] as int? ?? 0,
    )
      ..dateLocale = json['dateLocale'] as String?
      ..language = json['language'] as String?;

Map<String, dynamic> _$CacheToJson(Cache instance) => <String, dynamic>{
      'loginData': instance.loginData?.toJson(),
      'substitutes': instance.substitutes.map((e) => e.toJson()).toList(),
      'showHolidays': instance.showHolidays,
      'times': _timesToJson(instance.times),
      'dateLocale': instance.dateLocale,
      'language': instance.language,
      'lastServerUpdate': instance.lastServerUpdate.toIso8601String(),
      'lastClientUpdate': instance.lastClientUpdate.toIso8601String(),
      'version': instance.version,
    };
