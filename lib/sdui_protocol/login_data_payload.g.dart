// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_data_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginDataPayload _$LoginDataPayloadFromJson(Map<String, dynamic> json) =>
    LoginDataPayload(
      json['identifier'] as String,
      json['password'] as String,
      json['slink'] as String,
    );

Map<String, dynamic> _$LoginDataPayloadToJson(LoginDataPayload instance) =>
    <String, dynamic>{
      'identifier': instance.username,
      'password': instance.password,
      'slink': instance.school,
    };
