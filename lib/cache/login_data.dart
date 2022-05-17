import 'dart:convert';

import 'package:substitute_plan_push_notifications/util.dart';
import 'package:json_annotation/json_annotation.dart';

import '../protocol/self.dart';
import '../protocol/token.dart';

part 'login_data.g.dart';

@JsonSerializable(explicitToJson: true)
class LoginData {
  final Uri uri;
  final Token token;
  Self? self;

  LoginData(this.uri, this.token, {this.self});

  factory LoginData.fromJson(JsonObject json) => _$LoginDataFromJson(json);

  JsonObject toJson() => _$LoginDataToJson(this);

  /// JSON representation for the [`LoginData`].
  @override
  String toString() => jsonEncode(toJson());
}