import 'package:better_sdui_push_notification/cache/cache.dart';
import 'package:better_sdui_push_notification/cache/manager.dart';
import 'package:better_sdui_push_notification/sdui_protocol/agent.dart';
import 'package:better_sdui_push_notification/substitute/manager.dart';
import 'package:better_sdui_push_notification/substitute/substitute.dart';
import 'package:better_sdui_push_notification/util.dart';

class Manager {
  static Manager? _singleton;

  final CacheManager _cacheManager;
  final SduiAgent _sduiAgent;

  Manager._(this._cacheManager, this._sduiAgent);

  static Future<Manager> get singleton async {
    if (_singleton != null) return _singleton!;
    CacheManager cm = await CacheManager.getInstance();
    return _singleton = Manager._(cm, await SduiAgent.create(cm.cache.loginData));
  }

  Cache get cache => _cacheManager.cache;

  /// loads the times out of the cache or fetches them if not existing
  Future<Times> _getTimes() async =>
      cache.times != null ? cache.times! : cache.times = await _sduiAgent.getTimes();

  /// checks for the last upload of a substitute plan
  Future<DateTime> _getLastServerUpdate() async => cache.lastServerUpdate = await _sduiAgent.getLastServerUpdate();

  /// loads the new substitute plan and returns the delta;
  /// sets the old one to the newly fetched one
  Future<Iterable<Substitute>> _update() async {
    cache.lastClientUpdate = DateTime.now();
    var newSubstitutes = await _sduiAgent.getUpdates(await _getTimes());
    var delta = updateSubstituteList(cache.substitutes, newSubstitutes)
        .where((substitute) => substitute.state != SubstituteState.noChange);
    // pointer is same
    cache.updateSubstitutes(newSubstitutes);
    return delta;
  }

  /// returns the delta - only downloads substitute plan if last server update is newer than last client update
  /// if force == true the substitute plan is force-updated
  /// (though no changed are expected, unless there was an update
  Future<Iterable<Substitute>> update({bool force = false}) async =>
      force || (await _getLastServerUpdate()).isAfter(cache.lastClientUpdate) ? await _update() : const Iterable.empty();
}