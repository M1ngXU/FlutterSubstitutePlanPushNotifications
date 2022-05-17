// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginData _$LoginDataFromJson(Map<String, dynamic> json) => LoginData(
      Uri.parse(json['uri'] as String),
      Token.fromJson(json['token'] as Map<String, dynamic>),
      self: json['self'] == null
          ? null
          : Self.fromJson(json['self'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LoginDataToJson(LoginData instance) => <String, dynamic>{
      'uri': instance.uri.toString(),
      'token': instance.token.toJson(),
      'self': instance.self?.toJson(),
    };
