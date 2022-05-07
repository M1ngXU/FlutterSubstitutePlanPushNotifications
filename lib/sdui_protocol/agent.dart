import 'dart:async';
import 'dart:collection';
import 'dart:developer';
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
    request.headers.add('authorization', 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxMDAwNyIsImp0aSI6IjRhN2UwN2VkNTA2MDFhZDg2OWI5YjZiYThlNjkwY2ZmZTc3YzczOGViMTI3OGM1MzRlZmE5MmJjNjRhZTBkZjBiZDI0NWExMDllYmFjNTk4IiwiaWF0IjoxNjUxODExNDAyLCJuYmYiOjE2NTE4MTE0MDIsImV4cCI6MTY1MTk4NDIwMiwic3ViIjoiMzA1OTk2Iiwic2NvcGVzIjpbXX0.LtlED0n-hFaHcJPV-6Qhms26tjYLOrZ-sR1KnYarx4QGtIRFPjg4hxtKLCLZX6T5sAl5ZnrmnxuSSUObrWvtbsIt4BuUphz5DPaxnqHi7yO_1xUqvll50H5lEX-hIJDigodhQT4jOHQ1-maPE5jxz_u7pOMiElZkugdmqs-8OIz-ydDeIVlJwBltwoEIMjY1rc1S_747a5o_fZ0RJ_RTuAGXEfLJ94wU89M1odbNhkedocizxI0DJ9F0r3vLJ4-RPLkH_7ya5LXu6N3VkuLxCfexkeGk3bN0Q4gJNhC0iS7w6KlYHrdvGnrSeGN_FVFF3LA-jQ29jqiGr7PwwhncwozsNObdqVEN-alnrN_qL3GR0vWj8AnmXE14xd9RxvFF9ChtmNlH3p5Bvw1BruEmAAtSD43eykzZN1EEqkRFfEkR37vVU6E2C_KoTvQAaEQfqjo9UZAJezNcgUV_3UuiQSAZ2yo_Vf8vcE4SRFv2vJB4npZNXKABdjXAfFnM7Qn9sgXNsdQA6rhaKVPWHjyKmwGFssygYvZenmvkPTsmBeJSw-cQKHCDMTFPSxM8EQGEMzCmLkV9N_Qf_83c1cToFsk6NhByRKsoN6Aw_3SbQY45doblicqZRAQHhwTarCpsRfQSbhMsBItoQuso-Yl1aPTlO4O9ks0WJifKJOeY-9k');
    return processResponse(await utf8.decodeStream(await request.close()));
  }

  Future<DateTime> getLastUploaded() async =>
      lastUpload(await _request('OPTIONS', '/v1/users/${loginData.self?.id}/timetable/available'));
  
  Future<HashMap<int, Time>> getTimes() async =>
      Time.fromSduiJson(castToJsonArray(await _request('GET', '/v1/timetables/times')));

  getUpdates(HashMap<int, Time> times) async =>
    ((await _request('GET', '/v1/timetables', query: <String, String> {
      'identifier': loginData.self?.id.toString() ?? '',
      'entity': 'users'
    })) as JsonObject)['lessons'].values.expand((e) => Substitute.fromSduiJson(e as JsonObject, times, loginData.self!.grade)).toList();
  
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