import 'package:json_annotation/json_annotation.dart';

import '../util.dart';

part 'token.g.dart';

@JsonSerializable()
class Token {
  @JsonKey(name: 'token_type')
  final String type;
  @JsonKey(name: 'access_token')
  final String content;
  DateTime? expires;

  Token({required this.type, required this.content, this.expires});

  factory Token.fromJson(JsonObject json) {
    Token t = _$TokenFromJson(json);
    t.expires = DateTime.now().add(Duration(seconds: json['expires_in'] ?? 0));
    return t;
  }

  JsonObject toJson() => _$TokenToJson(this);

  /// Token representation in request
  @override
  String toString() => '$type $content';
}