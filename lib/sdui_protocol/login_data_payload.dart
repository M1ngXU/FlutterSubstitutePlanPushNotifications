import 'dart:convert';

import 'package:better_sdui_push_notification/util.dart';
import 'package:json_annotation/json_annotation.dart';

import '../cache/login_data.dart';

part 'login_data_payload.g.dart';

@JsonSerializable()
class LoginDataPayload {
  @JsonKey(name: "identifier")
  final String username;
  final String password;
  final showError = true;
  @JsonKey(name: "slink")
  final String school;
  final stayLoggedIn = true;

  LoginDataPayload(this.username, this.password, this.school);
  factory LoginDataPayload.fromLoginData(LoginData ld) => LoginDataPayload(ld.username, ld.password, ld.school);

  factory LoginDataPayload.fromJson(JSONObject json) => _$LoginDataPayloadFromJson(json);

  JSONObject toJson() => _$LoginDataPayloadToJson(this);

  /// JSON representation for the [`LoginDataPayload`].
  @override
  String toString() => jsonEncode(toJson());
}