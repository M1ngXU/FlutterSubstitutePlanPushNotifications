import 'dart:convert';

import 'package:substitute_plan_push_notifications/cache/logger.dart';
import 'package:json_annotation/json_annotation.dart';

import '../util.dart';

part 'response.g.dart';

T? processResponse<T>(String body) {
  var response = _SduiResponse.fromJson(jsonDecode(body));
  response.print();
  return response.data is T? ? response.data as T? : null;
}

@JsonSerializable()
class _SduiResponse {
  final Object? data;
  final String status;
  final _Meta meta;

  _SduiResponse(this.data, this.status, this.meta);

  factory _SduiResponse.fromJson(JsonObject json) => _$SduiResponseFromJson(json);

  JsonObject toJson() => _$SduiResponseToJson(this);

  print() {
    meta.print();
    if (status != 'SUCCESS') Logger.e('Status not `SUCCESS`, but `$status`.');
  }
}

@JsonSerializable()
class _Meta {
  final List<String> warnings;
  final List<String> errors;
  final List<String> success;

  _Meta(this.warnings, this.errors, this.success);

  factory _Meta.fromJson(JsonObject json) => _$MetaFromJson(json);

  JsonObject toJson() => _$MetaToJson(this);

  print() {
    success.forEach(Logger.vi);
    warnings.forEach(Logger.vw);
    errors.forEach(Logger.ve);
  }
}