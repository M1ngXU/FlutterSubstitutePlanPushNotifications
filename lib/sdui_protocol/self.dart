import 'dart:convert';

import 'package:better_sdui_push_notification/util.dart';
import 'package:json_annotation/json_annotation.dart';

part 'self.g.dart';

@JsonSerializable()
class Self {
  final String name;
  final int id;
  final String grade;

  Self(this.name, this.id, this.grade);

  factory Self.fromJson(JsonObject json) => _$SelfFromJson(json);
  /// throws an error if failed to extract
  factory Self.fromSduiJson(JsonObject json) {
    json['name'] = '${json['firstname'] as String} ${json['lastname'] as String}';
    json['grade'] = json['grade']['shortcut'] as String;
    return Self.fromJson(json);
  }

  JsonObject toJson() => _$SelfToJson(this);

  /// JSON representation for the [`Self`].
  @override
  String toString() => jsonEncode(toJson());

  @override
  bool operator ==(Object other) => other is Self && name == other.name && id == other.id && grade == other.grade;

  @override
  int get hashCode => Object.hash(name, id, grade);
}