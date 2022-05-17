import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:substitute_plan_push_notifications/cache/logger.dart';
import 'package:substitute_plan_push_notifications/protocol/last_upload.dart';
import 'package:substitute_plan_push_notifications/protocol/response.dart';
import 'package:substitute_plan_push_notifications/protocol/self.dart';
import 'package:substitute_plan_push_notifications/protocol/token.dart';
import 'package:substitute_plan_push_notifications/substitute/substitute.dart';
import 'package:substitute_plan_push_notifications/util.dart';
import 'package:http/http.dart';

import '../cache/login_data.dart';
import '../substitute/time.dart';
import 'login_data_payload.dart';

Map<String, String> getHeaders([String auth = '']) => {
  'Content-type' : 'application/json',
  'Accept': 'application/json',
  if (auth.isNotEmpty) 'authorization': auth
};

class Agent {
  late final LoginData loginData;

  Agent(this.loginData);

  Future<T?> _request<T>(String method, String path, {Map<String, String> query = const {}}) async {
    final url = loginData.uri.set(path, query);
    Logger.d('Performing `$method` to `$url`.');
    // TODO HEADER
    return processResponse((
        await Response.fromStream(await Client().send(Request(method, url)
          ..headers.addAll(getHeaders(loginData.token.toString()))))
    ).body);
  }

  Future<DateTime> getLastServerUpdate() async {
    Logger.d('Fetching `lastServerUpload`.');
    return lastUpload(await _request('OPTIONS', '/v1/users/${loginData.self?.id}/timetable/available'));
  }

  Future<HashMap<int, Time>> getTimes() async {
    Logger.d('Fetching `times`.');
    return Time.fromServerJson(castToJsonArray(await _request('GET', '/v1/timetables/times')));
  }

  /// returns an entry of the last uploaded time and the substitutes
  Future<MapEntry<DateTime?, List<Substitute>>> getUpdates(HashMap<int, Time> times) async {
    Logger.d('Fetching `substitutes`.');
    var response = ((await _request('GET', '/v1/timetables', query: <String, String>{
          'identifier': loginData.self?.id.toString() ?? '',
          'entity': 'users'
        })) as JsonObject);
    return MapEntry(
       DateTime.tryParse(response['last_updated_at']),
        (response['lessons'] as JsonObject).values
            .expand((e) => Substitute.fromSduiJson(e as JsonObject, times, loginData.self!.grade))
            .toList()
            .cast()
    );
  }

  static Future<Token?> _getToken(Uri uri, String username, String password, String school) async {
    Logger.d('Fetching `token`.');
    try {
      return Token.fromJson(processResponse((await post(
          uri.set('/v1/auth/login'),
          body: jsonEncode(LoginDataPayload(username, password, school)),
          headers: getHeaders()
      )).body));
    } catch(e, s) {
      Logger.e('Failed to get token.', e, s);
      return null;
    }
  }

  Future<Self> _getSelf(LoginData loginData) async {
    Logger.d('Fetching `self`.');
    return Self.fromSduiJson(await _request('GET', '/v1/users/self'));
  }

  /// performs the login if necessary and possible
  static Future<Agent> create(LoginData loginData) async {
    var s = Agent(loginData);
    s.loginData.self ??= await s._getSelf(loginData);
    return s;
  }

  static Future<Agent?> login(Uri uri, String username, String password, String school) async {
    var token = await _getToken(uri, username, password, school);
    return token == null ? null : Agent.create(LoginData(uri, token));
  }
}