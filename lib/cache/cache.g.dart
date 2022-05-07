// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cache _$CacheFromJson(Map<String, dynamic> json) => Cache(
      (json['accounts'] as List<dynamic>)
          .map((e) => Account.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CacheToJson(Cache instance) => <String, dynamic>{
      'accounts': instance.accounts.map((e) => e.toJson()).toList(),
    };
