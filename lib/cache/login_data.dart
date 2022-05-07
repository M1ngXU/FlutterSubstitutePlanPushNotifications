import 'dart:convert';

import 'package:better_sdui_push_notification/util.dart';
import 'package:json_annotation/json_annotation.dart';

import '../sdui_protocol/token.dart';

part 'login_data.g.dart';

@JsonSerializable(explicitToJson: true)
class LoginData {
  final String username;
  final String password;
  final String school;
  Token? token;

  LoginData({required this.username, required this.password, required this.school, this.token});

  factory LoginData.fromJson(JsonObject json) => _$LoginDataFromJson(json);

  JsonObject toJson() => _$LoginDataToJson(this);

  /// JSON representation for the [`LoginData`].
  @override
  String toString() => jsonEncode(toJson());
}