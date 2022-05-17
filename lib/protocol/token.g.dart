// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Token _$TokenFromJson(Map<String, dynamic> json) => Token(
      type: json['token_type'] as String,
      content: json['access_token'] as String,
      expires: json['expires'] == null
          ? null
          : DateTime.parse(json['expires'] as String),
    );

Map<String, dynamic> _$TokenToJson(Token instance) => <String, dynamic>{
      'token_type': instance.type,
      'access_token': instance.content,
      'expires': instance.expires?.toIso8601String(),
    };
