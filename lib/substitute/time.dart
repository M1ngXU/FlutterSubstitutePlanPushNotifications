import 'dart:collection';
import 'dart:convert';

import 'package:better_sdui_push_notification/util.dart';
import 'package:json_annotation/json_annotation.dart';

part 'time.g.dart';

@JsonSerializable(explicitToJson: true)
class Time implements Comparable<Time> {
  final int order;
  final String name;

  Time(this.order, this.name);

  factory Time.fromJson(JsonObject json) => _$TimeFromJson(json);

  static HashMap<int, Time> fromSduiJson(JsonArray json) {
    var t = HashMap<int, Time>();
    for (var time in json) {
      t.putIfAbsent(
          castOr(time['id'], 0),
          () => Time(
              DateTime.tryParse(castOr(time['begins_at'], ''))?.millisecondsSinceEpoch ?? 0,
              castOr(getKey(time, 'meta')?['displayname'], '')
          )
      );
    }
    return t;
  }

  JsonObject toJson() => _$TimeToJson(this);

  /// JSON representation for the [`Time`].
  @override
  String toString() => jsonEncode(toJson());

  @override
  int compareTo(Time other) => order - other.order;

  @override
  bool operator ==(Object other) => other is Time && order == other.order && name == other.name;

  @override
  int get hashCode => Object.hash(order, name);
}