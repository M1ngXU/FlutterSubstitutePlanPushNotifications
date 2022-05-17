import 'dart:collection';
import 'dart:convert';

import 'package:substitute_plan_push_notifications/substitute/time.dart';
import 'package:json_annotation/json_annotation.dart';

import '../substitute/substitute.dart';
import '../util.dart';
import 'login_data.dart';

part 'cache.g.dart';

JsonObject? _timesToJson(Times? times) =>
    times != null ? Map.fromEntries(times.entries.map((e) => MapEntry(e.key.toString(), e.value.toString()))) : null;
Times? _timesFromJson(JsonObject? times) =>
    times == null ? null : HashMap.fromEntries(times.entries.map((e) => MapEntry(int.parse(e.key), Time.fromJson(jsonDecode(e.value)))));
DateTime _tryParseDate(String? date) => (date == null ? null : DateTime.tryParse(date)) ?? DateTime(0);

@JsonSerializable(explicitToJson: true)
class Cache {
  LoginData? loginData;
  List<Substitute> substitutes;
  bool showHolidays;
  @JsonKey(fromJson: _timesFromJson, toJson: _timesToJson)
  Times? times;
  String? dateLocale;
  String? language;
  @JsonKey(fromJson: _tryParseDate)
  DateTime lastServerUpdate;
  @JsonKey(fromJson: _tryParseDate)
  DateTime lastClientUpdate;
  int version;

  Cache({
    this.loginData,
    this.substitutes = const [],
    this.times,
    DateTime? lastServerUpdate,
    DateTime? lastClientUpdate,
    this.showHolidays = false,
    this.version = 0
  }) : lastServerUpdate = lastServerUpdate ?? DateTime(0),
        lastClientUpdate = lastClientUpdate ?? DateTime(0);

  factory Cache.fromJson(JsonObject json) => _$CacheFromJson(json);

  JsonObject toJson() => _$CacheToJson(this);

  /// JSON representation for the [`Cache`].
  @override
  String toString() => jsonEncode(toJson());
}