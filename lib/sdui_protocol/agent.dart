import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:convert';
import 'package:better_sdui_push_notification/sdui_protocol/last_upload.dart';
import 'package:better_sdui_push_notification/sdui_protocol/response.dart';
import 'package:better_sdui_push_notification/sdui_protocol/self.dart';
import 'package:better_sdui_push_notification/sdui_protocol/token.dart';
import 'package:better_sdui_push_notification/substitute/substitute.dart';
import 'package:better_sdui_push_notification/util.dart';
import 'package:http/http.dart';

import '../cache/login_data.dart';
import '../substitute/time.dart';
import 'login_data_payload.dart';

Map<String, String> get headers => {
  'Content-type' : 'application/json',
  'Accept': 'application/json',
};

Uri _uriByPath(String path, {query}) {
  return Uri.https("api.sdui.app", path, query ?? <String, String>{});
}

class SduiAgent {
  late final LoginData loginData;

  SduiAgent(this.loginData);

  Future<T?> _request<T>(String method, String path, {Map<String, String>? query}) async {
    final request = await HttpClient().openUrl(method, _uriByPath(path, query: query ?? <String, String>{}));
    request.headers.add('authorization', loginData.token!.toString());
    return processResponse(await utf8.decodeStream(await request.close()));
  }

  Future<DateTime> getLastServerUpdate() async =>
      lastUpload(await _request('OPTIONS', '/v1/users/${loginData.self?.id}/timetable/available'));
  
  Future<HashMap<int, Time>> getTimes() async =>
      Time.fromSduiJson(castToJsonArray(await _request('GET', '/v1/timetables/times')));

  Future<List<Substitute>> getUpdates(HashMap<int, Time> times) async =>
    (((await _request('GET', '/v1/timetables', query: <String, String> {
      'identifier': loginData.self?.id.toString() ?? '',
      'entity': 'users'
    })) as JsonObject)['lessons'] as JsonObject).values.expand((e) => Substitute.fromSduiJson(e as JsonObject, times, loginData.self!.grade)).toList().cast();
  
  static Future<Token> _getToken(LoginData loginData) async =>
      Token.fromJson(processResponse((await post(_uriByPath("/v1/auth/login"), body: jsonEncode(LoginDataPayload.fromLoginData(loginData)), headers: headers)).body));

  Future<Self> _getSelf(LoginData loginData) async => Self.fromSduiJson(await _request('GET', '/v1/users/self'));

  /// performs the login if necessary
  static Future<SduiAgent> create(LoginData loginData) async {
    loginData.token ??= await _getToken(loginData);
    var s = SduiAgent(loginData);
    s.loginData.self ??= await s._getSelf(loginData);
    return s;
  }
}