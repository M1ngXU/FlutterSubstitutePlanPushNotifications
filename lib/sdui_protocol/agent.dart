import 'dart:convert';
import 'package:better_sdui_push_notification/sdui_protocol/response.dart';
import 'package:better_sdui_push_notification/sdui_protocol/token.dart';
import 'package:http/http.dart';

import '../cache/login_data.dart';
import 'login_data_payload.dart';

var headers = {
  'Content-type' : 'application/json',
  'Accept': 'application/json',
};

Uri uriByPath(String path) {
  return Uri.https("api.sdui.app", path);
}

class SduiAgent {
  late final LoginData loginData;

  SduiAgent(this.loginData);

  static Future<SduiAgent> login(LoginData loginData) async {
    loginData.token = Token.fromJson(processResponse(await post(uriByPath("/v1/auth/login"), body: jsonEncode(LoginDataPayload.fromLoginData(loginData)), headers: headers)));
    return SduiAgent(loginData);
  }

  static Future<SduiAgent> create(LoginData loginData) async => loginData.token == null ? await login(loginData) : SduiAgent(loginData);
}