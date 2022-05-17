import 'dart:convert';

import 'package:substitute_plan_push_notifications/util.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'time.g.dart';

DateTime? _parseDate(String s) {
  try {
    return DateFormat('yyyy-MM-ddTHH:mm:ss').parse(s);
  } catch (_) {
    return null;
  }
}

@JsonSerializable(explicitToJson: true)
class Time implements Comparable<Time> {
  final int order;
  final String name;
  final DateTime from;
  final DateTime to;

  Time(this.order, this.name, [DateTime? from, DateTime? to]) :
    from = from ?? DateTime(0),
    to = to ?? DateTime(0);

  factory Time.fromJson(JsonObject json) => _$TimeFromJson(json);

  static Times fromServerJson(JsonArray json) {
    var t = Times();
    for (var time in json) {
      t.putIfAbsent(
          castOr(time['id'], 0),
          () => Time(
            _parseDate(castOr(time['begins_at'], ''))?.millisecondsSinceEpoch ?? 0,
              castOr(getKey(time, 'meta')?['displayname'], ''),
            _parseDate(castOr(time['begins_at'], ''))?.toLocal(),
            _parseDate(castOr(time['ends_at'], ''))?.toLocal(),
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