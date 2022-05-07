import 'dart:collection';
import 'dart:convert';

import 'package:better_sdui_push_notification/substitute/time.dart';
import 'package:json_annotation/json_annotation.dart';

import '../substitute/substitute.dart';
import '../util.dart';
import 'login_data.dart';

part 'cache.g.dart';

JsonObject? _timesToJson(Times? times) => times != null ? Map.fromEntries(times.entries.map((e) => MapEntry(e.key.toString(), e.value))) : null;
Times? _timesFromJson(JsonObject times) => HashMap.fromEntries(times.entries.map((e) => MapEntry(int.parse(e.key), e.value)));

@JsonSerializable(explicitToJson: true)
class Cache {
  LoginData loginData;
  /// ***USE UPDATE FUNCTION TO CALL CALLBACKS***
  @JsonKey(defaultValue: [])
  List<Substitute> substitutes;
  List<Function(List<Substitute>)> onSubstituteChangeCallback = [];
  @JsonKey(fromJson: _timesFromJson, toJson: _timesToJson)
  Times? times;
  DateTime lastServerUpdate;
  DateTime lastClientUpdate;

  updateSubstitutes(List<Substitute> substitutes) {
    this.substitutes = substitutes;
    for (var f in onSubstituteChangeCallback) {
      f.call(substitutes);
    }
  }

  Cache(this.loginData, this.substitutes, this.times, this.lastServerUpdate, this.lastClientUpdate);

  factory Cache.fromJson(JsonObject json) => _$CacheFromJson(json);

  JsonObject toJson() => _$CacheToJson(this);

  /// JSON representation for the [`Cache`].
  @override
  String toString() => jsonEncode(toJson());
}