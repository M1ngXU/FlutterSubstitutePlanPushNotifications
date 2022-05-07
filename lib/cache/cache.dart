import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import '../util.dart';
import 'account.dart';

part 'cache.g.dart';

@JsonSerializable(explicitToJson: true)
class Cache {
  List<Account> accounts;

  Cache(this.accounts);

  factory Cache.fromJson(JSONObject json) => _$CacheFromJson(json);

  JSONObject toJson() => _$CacheToJson(this);

  /// JSON representation for the [`Cache`].
  @override
  String toString() => jsonEncode(toJson());
}