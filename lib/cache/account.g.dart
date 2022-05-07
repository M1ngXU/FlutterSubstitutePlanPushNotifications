// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) => Account(
      loginData: LoginData.fromJson(json['loginData'] as Map<String, dynamic>),
      substitutes: json['substitutes'],
    );

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'loginData': instance.loginData.toJson(),
      'substitutes': instance.substitutes.map((e) => e.toJson()).toList(),
    };
