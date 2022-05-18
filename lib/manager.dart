import 'dart:collection';

import 'package:substitute_plan_push_notifications/cache/logger.dart';
import 'package:substitute_plan_push_notifications/cache/manager.dart';
import 'package:substitute_plan_push_notifications/generated/l10n.dart';
import 'package:substitute_plan_push_notifications/notification_manager.dart';
import 'package:substitute_plan_push_notifications/protocol/agent.dart';
import 'package:substitute_plan_push_notifications/substitute/manager.dart';
import 'package:substitute_plan_push_notifications/substitute/substitute.dart';
import 'package:substitute_plan_push_notifications/util.dart';

class Manager {
  static Manager? _singleton;

  final CacheManager cacheManager;
  Agent? _agent;

  HashMap<int, Function()> onRefreshingChangedCallback = HashMap();
  HashMap<int, Function()> onLoggedIn = HashMap();
  bool _refreshing = false;
  bool get refreshing => _refreshing;
  set refreshing(bool v) {
    _refreshing = v;
    for (var f in onRefreshingChangedCallback.values) {
      f();
    }
  }

  Manager._(this.cacheManager, this._agent) {
    onLoggedIn.putIfAbsent(hashCode, () => cacheManager.invokeLoginDataUpdate);
  }

  static Manager get singleton => _singleton!;

  static Future<Manager> createOrGetInstance() async {
    if (_singleton != null) return _singleton!;
    CacheManager cm = await CacheManager.getInstance();
    return _singleton = Manager._(cm, cm.loginData != null ? await Agent.create(cm.loginData!) : null);
  }

  /// loads the times out of the cache or fetches them if not existing
  Future<Times?> _getTimes() async => cacheManager.times ??= await _agent?.getTimes();

  /// checks for the last upload of a substitute plan
  Future<DateTime?> getLastServerUpdate() async {
    var l = await _agent?.getLastServerUpdate();
    if (l != null) cacheManager.lastServerUpdate = l;
    return l;
  }

  Iterable<T> _doneRefreshWithEmptyIterable<T>() {
    refreshing = false;
    cacheManager.lastClientUpdate = DateTime.now();
    Logger.ve(S.current.refreshFailed);
    return const Iterable.empty();
  }

  /// loads the new substitute plan and returns the delta;
  /// sets the old one to the newly fetched one
  Future<Iterable<Substitute>> _refresh() async {
    Logger.vi(S.current.refreshingSubstitutes);
    refreshing = true;
    var times = await _getTimes();
    if (times == null) return _doneRefreshWithEmptyIterable();
    var updates = await _agent?.getUpdates(times);
    var newSubstitutes = updates?.value;
    var lastUpload = updates?.key;
    if (lastUpload != null) cacheManager.lastServerUpdate = lastUpload;
    if (newSubstitutes == null) return _doneRefreshWithEmptyIterable();
    var delta = updateSubstituteList(cacheManager.substitutes, newSubstitutes)
        .where((substitute) => substitute.state != null && substitute.state != SubstituteState.noChange);
    // pointer is same
    cacheManager.substitutes = newSubstitutes.where((s) => s.state?.needsSave ?? false).toList();
    refreshing = false;
    cacheManager.lastClientUpdate = DateTime.now();
    Logger.vi(S.current.doneRefreshingSubstitutes);
    return delta;
  }

  Future<bool> login(String url, String username, String password, String school) async {
    try {
      Uri uri = Uri.parse(url);
      Logger.vi(S.current.loggingIn);
      cacheManager.loginData = (_agent = await Agent.login(uri, username, password, school))!.loginData;
      for (var f in onLoggedIn.values) {
        f.call();
      }
      Logger.vi(S.current.loggedIn);
      return true;
    } catch (e, s) {
      Logger.ve(S.current.loginFailed, e, s);
    }
    return false;
  }

  logout() async {
    Logger.vi(S.current.loggingOut);
    await cacheManager.clearCache();
    Logger.vi(S.current.loggedOut);
  }

  /// returns whether there was a delta
  /// 
  /// only downloads substitute plan if last server update is newer than last client update
  /// if force == true the substitute plan is force-updated, e.g. when holidays have to be shown
  /// (though no changed are expected, unless there was an update
  Future<bool> refresh({bool force = false}) async {
    if (refreshing || !cacheManager.loggedIn) return false;
    bool needsRefresh = force;
    if (!needsRefresh) {
      Logger.vi(S.current.checkingLastSubstitutePlanUpload);
      needsRefresh = (await getLastServerUpdate())?.isAfter(cacheManager.lastClientUpdate) == true;
      if (needsRefresh) {
        Logger.vi(S.current.newVersion);
      } else {
        Logger.vi(S.current.nothingNew);
      }
    }
    if (!needsRefresh) return false;
    var updates = sortSubstitutes((await _refresh()).toList());
    var content = updates.values.map((s) => '${s.first.formattedDate}: '
        + (s.length == 1
            ? s.first.toReadableString()
            : s.map((e) => '${e.lessons.replaceFirstMapped(RegExp(r'^.*?(\d(\+\d)*)$'), (match) => match[1] ?? '')}:'
            ' ${e.translatedKind}').join('; ')
        )
    ).join('\n');
    if (content.isNotEmpty) NotificationManager.sendNotification(S.current.substitutePlanUpdate, content);
    return updates.isNotEmpty;
  }
}