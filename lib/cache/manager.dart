import 'package:shared_preferences/shared_preferences.dart';

class CacheManager {
  late final SharedPreferences _instance;

  CacheManager(this._instance);

  String read() => _instance.getString("cache") ?? "";
  Future<bool> write(String content) => _instance.setString("cache", content);

  static Future<CacheManager> create() async => CacheManager(await SharedPreferences.getInstance());
}