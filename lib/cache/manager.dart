import 'dart:convert';

import 'package:substitute_plan_push_notifications/cache/cache.dart';
import 'package:substitute_plan_push_notifications/cache/logger.dart';
import 'package:substitute_plan_push_notifications/cache/login_data.dart';
import 'package:substitute_plan_push_notifications/manager.dart';
import 'package:substitute_plan_push_notifications/substitute/substitute.dart';
import 'package:substitute_plan_push_notifications/util.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheManager {
  static CacheManager? _singleton;
  late final SharedPreferences _sharedPreferences;
  late Cache _cache;
  Map<int, Function()> onShowHolidayChangedCallback = {};
  Map<int, Function()> onSubstituteChangedCallback = {};
  Map<int, Function()> onLastClientUpdateChangedCallback = {};
  Map<int, Function()> onLastServerUpdateChangedCallback = {};
  Map<int, Function()> onTimesChangedCallback = {};
  Map<int, Function()> onLoginDataChangedCallback = {};
  Map<int, Function()> onDateLocaleChangedCallback = {};
  Map<int, Function()> onLanguageChangedCallback = {};
  Map<int, Function()> onVersionChangedCallback = {};

  bool get loggedIn => loginData?.token != null;

  LoginData? get loginData => _cache.loginData;
  set loginData(LoginData? loginData) {
    _cache.loginData = loginData;
    invokeLoginDataUpdate();
  }
  void invokeLoginDataUpdate() {
    for (var f in onLoginDataChangedCallback.values) {
      f.call();
    }
  }

  /// null if using system locale
  String? get nullableDateLocale => _cache.dateLocale;
  /// either returns the set date locale or the system one
  String get dateLocale => nullableDateLocale ?? getSystemLocale();
  set dateLocale(String? dateLocale) {
    _cache.dateLocale = dateLocale;
    for (var f in onDateLocaleChangedCallback.values) {
      f.call();
    }
  }

  /// null if using system locale
  String? get nullableLanguage => _cache.language;
  /// either returns the set date locale or the system one
  String get language => nullableLanguage ?? getSystemLocale();
  set language(String? language) {
    _cache.language = language;
    for (var f in onLanguageChangedCallback.values) {
      f.call();
    }
  }

  Times? get times => _cache.times;
  set times(Times? times) {
    _cache.times = times;
    for (var f in onTimesChangedCallback.values) {
      f.call();
    }
  }

  int get version => _cache.version;
  set version(int version) {
    _cache.version = version;
    for (var f in onVersionChangedCallback.values) {
      f.call();
    }
  }

  DateTime get lastClientUpdate => _cache.lastClientUpdate;
  set lastClientUpdate(DateTime date) {
    _cache.lastClientUpdate = date;
    for (var f in onLastClientUpdateChangedCallback.values) {
      f.call();
    }
  }

  DateTime get lastServerUpdate => _cache.lastServerUpdate;
  set lastServerUpdate(DateTime date) {
    _cache.lastServerUpdate = date;
    for (var f in onLastServerUpdateChangedCallback.values) {
      f.call();
    }
  }

  List<Substitute> get substitutes => _cache.substitutes;
  set substitutes(List<Substitute> substitutes) {
    _cache.substitutes = substitutes;
    for (var f in onSubstituteChangedCallback.values) {
      f.call();
    }
  }

  bool get showHolidays => _cache.showHolidays;
  set showHolidays(bool newValue) {
    _cache.showHolidays = newValue;
    for (var f in onShowHolidayChangedCallback.values) {
      f.call();
    }
    // update, since showing holidays effects the substitutes shown
    Manager.createOrGetInstance().then((m) => m.refresh(force: true));
  }

  Map<String, Map<int, Function>> get _callbacks => {
    'substitutes': onSubstituteChangedCallback,
    'show holidays': onShowHolidayChangedCallback,
    'last client update': onLastClientUpdateChangedCallback,
    'last server update': onLastServerUpdateChangedCallback,
    'times': onTimesChangedCallback,
    'login data': onLoginDataChangedCallback,
    'date locale': onDateLocaleChangedCallback,
    'language': onLanguageChangedCallback,
    'version': onVersionChangedCallback,
  };

  CacheManager._(this._sharedPreferences) {
    reloadCache();
    for (var kvp in _callbacks.entries) {
      kvp.value.putIfAbsent(0, _getCallbackSaveFunction(kvp.key));
    }
  }
  @visibleForTesting
  CacheManager.mock() {
    _cache = Cache();
  }

  Function() Function() _getCallbackSaveFunction(String name) => () => () {
    Logger.d('Updated `$name` in cache.');
    saveCache();
  };

  reloadCache() {
    try {
      _cache = Cache.fromJson(jsonDecode(_sharedPreferences.getString('cache')!));
    } catch (e) {
      Logger.e('Failed to get shared preferences `cache`. ($e)');
      _cache = Cache.fromJson({});
      saveCache();
    }
  }
  saveCache() async {
    if (!await _sharedPreferences.setString('cache', _cache.toString())) Logger.ve('Failed to save cache?');
  }
  Future clearCache() async {
    await _sharedPreferences.remove('cache');
    reloadCache();
    for (var m in _callbacks.values) {
      for (var f in m.values) {
        f.call();
      }
    }
  }
  clearCacheExceptLoginData() {
    _cache = Cache.fromJson(_cache.toJson()..removeWhere((key, _) => key != 'loginData'));
    saveCache();
    for (var m in _callbacks.values) {
      for (var f in m.values) {
        f.call();
      }
    }
  }

  static Future<CacheManager> getInstance() async {
    if (_singleton == null) {
      CacheManager cm = CacheManager._(await SharedPreferences.getInstance());
      _singleton ??= cm;
    }
    return singleton;
  }

  static CacheManager get singleton => _singleton!;
  @visibleForTesting
  static set singleton(CacheManager cm) => _singleton = cm;
}