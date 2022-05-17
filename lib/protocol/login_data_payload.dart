import 'dart:convert';

import 'package:substitute_plan_push_notifications/util.dart';
import 'package:json_annotation/json_annotation.dart';

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

  factory LoginDataPayload.fromJson(JsonObject json) => _$LoginDataPayloadFromJson(json);

  JsonObject toJson() => _$LoginDataPayloadToJson(this);

  /// JSON representation for the [`LoginDataPayload`].
  @override
  String toString() => jsonEncode(toJson());
}