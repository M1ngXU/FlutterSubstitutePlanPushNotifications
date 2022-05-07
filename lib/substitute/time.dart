import 'dart:convert';

import 'package:better_sdui_push_notification/util.dart';
import 'package:json_annotation/json_annotation.dart';

part 'time.g.dart';

@JsonSerializable(explicitToJson: true)
class Time implements Comparable<Time> {
  final int order;
  final String name;

  Time(this.order, this.name, );

  factory Time.fromJson(JSONObject json) => _$TimeFromJson(json);

  JSONObject toJson() => _$TimeToJson(this);

  /// JSON representation for the [`Time`].
  @override
  String toString() => jsonEncode(toJson());

  @override
  int compareTo(Time other) => order - other.order;
}