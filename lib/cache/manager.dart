import 'dart:convert';

import 'package:better_sdui_push_notification/cache/cache.dart';
import 'package:better_sdui_push_notification/cache/login_data.dart';
import 'package:better_sdui_push_notification/substitute/substitute.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheManager {
  late final SharedPreferences _instance;
  late Cache cache;

  CacheManager._(this._instance) {
    reloadCache();
    cache.onSubstituteChangeCallback.add((_) => saveCache());
  }

  reloadCache() {
    if (!_instance.containsKey('cache')) {
      cache = Cache(LoginData(username: 'max.obreiter@gmail.com', password: '1f9766fd56', school: 'gymnasium-walldorf'), [], null, DateTime.fromMillisecondsSinceEpoch(0), DateTime.fromMillisecondsSinceEpoch(0));
      saveCache();
    } else {
      cache = Cache.fromJson(jsonDecode(_instance.getString('cache') ?? ''));
    }
  }
  Future<bool> saveCache() => _instance.setString('cache', cache.toString());

  static Future<CacheManager> getInstance() async {
    await (await SharedPreferences.getInstance()).remove('cache');
    return CacheManager._(await SharedPreferences.getInstance());
  }
}