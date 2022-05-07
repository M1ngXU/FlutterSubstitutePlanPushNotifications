import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'token.g.dart';

@JsonSerializable()
class Token {
  @JsonKey(name: 'token_type')
  final String type;
  @JsonKey(name: 'access_token')
  final String content;
  DateTime? expires;

  Token({required this.type, required this.content, this.expires});

  factory Token.fromJson(Map<String, dynamic> json) {
    Token t = _$TokenFromJson(json);
    t.expires = DateTime.now().add(Duration(seconds: json['expires_in'] ?? 0));
    return t;
  }

  Map<String, dynamic> toJson() => _$TokenToJson(this);

  /// JSON representation for the [`Token`].
  @override
  String toString() => jsonEncode(toJson());
}