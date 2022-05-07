import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart';
import 'package:json_annotation/json_annotation.dart';

part 'response.g.dart';

T? processResponse<T>(Response res) {
  var response = _SduiResponse.fromJson(jsonDecode(res.body));
  response.print();
  return response.data is T ? response.data as T? : null;
}

@JsonSerializable()
class _SduiResponse {
  final Object? data;
  final String status;
  final _Meta meta;

  _SduiResponse(this.data, this.status, this.meta);

  factory _SduiResponse.fromJson(Map<String, dynamic> json) => _$SduiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SduiResponseToJson(this);

  print() {
    if (status != 'SUCCESS') log('Status not `SUCCESS`, but `' + status + '`');
    meta.print();
  }
}

@JsonSerializable()
class _Meta {
  final List<String> warnings;
  final List<String> errors;
  final List<String> success;

  _Meta(this.warnings, this.errors, this.success);

  factory _Meta.fromJson(Map<String, dynamic> json) => _$MetaFromJson(json);

  Map<String, dynamic> toJson() => _$MetaToJson(this);

  print() {
    success.forEach(log);
    warnings.forEach(log);
    errors.forEach(log);
  }
}