import 'dart:convert';

import 'package:better_sdui_push_notification/cache/login_data.dart';
import 'package:better_sdui_push_notification/substitute/substitute.dart';
import 'package:better_sdui_push_notification/util.dart';
import 'package:json_annotation/json_annotation.dart';

part 'account.g.dart';

@JsonSerializable(explicitToJson: true)
class Account {
  LoginData loginData;
  late List<Substitute> substitutes;

  Account({required this.loginData, substitutes}) { this.substitutes = substitutes ?? []; }

  factory Account.fromLoginData(LoginData loginData) => Account(loginData: loginData);

  factory Account.fromJson(JSONObject json) => _$AccountFromJson(json);

  JSONObject toJson() => _$AccountToJson(this);

  /// JSON representation for the [`Account`].
  @override
  String toString() => jsonEncode(toJson());
}