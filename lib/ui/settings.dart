import 'dart:math';
import 'dart:ui' as ui;

import 'package:substitute_plan_push_notifications/cache/manager.dart';
import 'package:substitute_plan_push_notifications/main.dart';
import 'package:substitute_plan_push_notifications/manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:intl/intl.dart';
import 'package:settings_ui/settings_ui.dart';

import '../generated/l10n.dart';
import '../util.dart';
import 'languages.dart';

const List<IconData> _filter = [
  Icons.exposure_zero,
  Icons.filter_1_rounded,
  Icons.filter_2_rounded,
  Icons.filter_3_rounded,
  Icons.filter_4_rounded,
  Icons.filter_5_rounded,
  Icons.filter_6_rounded,
  Icons.filter_7_rounded,
  Icons.filter_8_rounded,
  Icons.filter_9_rounded,
  Icons.filter_9_plus_rounded,
];
IconData _getFilterIcon(int i) => _filter[min(max(i, 0), _filter.length - 1)];

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool? _showHolidays;
  String? _dateLocale;
  String? _language;
  String _self = '';
  int _knownIDs = 0;
  DateTime _lastServerUpdate = DateTime(0);
  DateTime _lastClientUpdate = DateTime(0);
  bool _refreshing = false;

  _SettingsScreenState();

  void _setDateLocale(CacheManager m) => setState(() => _dateLocale = m.nullableDateLocale);
  void _setLanguage(CacheManager m) => setState(() => _language = m.nullableLanguage);
  void _setShowHolidays(CacheManager m) => setState(() => _showHolidays = m.showHolidays);
  void _setSelf(CacheManager m) => setState(() => _self = m.loginData?.self?.toInformationString() ?? '');
  void _setKnownIDs(CacheManager m) => setState(() => _knownIDs = m.substitutes.length);
  void _setLastServerUpdate(CacheManager m) => setState(() => _lastServerUpdate = m.lastServerUpdate);
  void _setLastClientUpdate(CacheManager m) => setState(() => _lastClientUpdate = m.lastClientUpdate);
  void _setRefreshing(Manager m) => setState(() => _refreshing = m.refreshing);

  @override
  void initState() {
    super.initState();

    CacheManager.getInstance().then((m) {
      _setShowHolidays(m);
      m.onShowHolidayChangedCallback.putIfAbsent(hashCode, putIfAbsent(m, _setShowHolidays));

      _setDateLocale(m);
      m.onDateLocaleChangedCallback.putIfAbsent(hashCode, putIfAbsent(m, _setDateLocale));

      _setLanguage(m);
      m.onLanguageChangedCallback.putIfAbsent(hashCode, putIfAbsent(m, _setLanguage));

      _setSelf(m);
      m.onLoginDataChangedCallback.putIfAbsent(hashCode, putIfAbsent(m, _setSelf));

      _setKnownIDs(m);
      m.onSubstituteChangedCallback.putIfAbsent(hashCode, putIfAbsent(m, _setKnownIDs));

      _setLastServerUpdate(m);
      m.onLastServerUpdateChangedCallback.putIfAbsent(hashCode, putIfAbsent(m, _setLastServerUpdate));

      _setLastClientUpdate(m);
      m.onLastClientUpdateChangedCallback.putIfAbsent(hashCode, putIfAbsent(m, _setLastClientUpdate));
    });

    Manager.createOrGetInstance().then((m) {
      _setRefreshing(m);
      m.onRefreshingChangedCallback.putIfAbsent(hashCode, putIfAbsent(m, _setRefreshing));
    });
  }

  @override
  void dispose() {
    CacheManager.singleton..onShowHolidayChangedCallback.remove(hashCode)
      ..onDateLocaleChangedCallback.remove(hashCode)
      ..onLanguageChangedCallback.remove(hashCode)
      ..onLoginDataChangedCallback.remove(hashCode)
      ..onSubstituteChangedCallback.remove(hashCode)
      ..onLastServerUpdateChangedCallback.remove(hashCode)
      ..onLastClientUpdateChangedCallback.remove(hashCode);
    Manager.singleton.onRefreshingChangedCallback.remove(hashCode);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showHolidays == null) return const SizedBox();
    bool loggedIn = CacheManager.singleton.loggedIn;
    return SettingsList(
      sections: [
        SettingsSection(
          title: Text(S.of(context).settings),
          tiles: [
            SettingsTile.switchTile(
              onToggle: (v) {
                CacheManager.singleton.showHolidays = v;
                return false;
              },
              initialValue: _showHolidays,
              leading: const Icon(Icons.announcement),
              title: Text(S.of(context).holidays),
              description: Text(S.of(context).showSubstitutesForHolidays),
            ),
          ],
        ),
        SettingsSection(
          title: Text(S.of(context).language),
          tiles: [
            SettingsTile(
              title: Text(S.of(context).dateLocale),
              description: Text(S.of(context).dateFormatting),
              trailing: Row(children: [
                Text((LocaleNames.of(context)?.nameOf(_dateLocale ?? S.of(context).invalidLocale) ?? S.of(context).systemLanguage)
                    .replaceAll(' ', '\n'), textAlign: TextAlign.center,),
                const Icon(Icons.chevron_right)
              ]),
              leading: const Icon(Icons.language),
              onPressed: (context) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => LanguageScreen(
                      DateFormat.allLocalesWithSymbols(),
                      _dateLocale,
                      (l) => CacheManager.singleton.dateLocale = l
                  ),
                ));
              },
            ),
            SettingsTile(
              title: Text(S.of(context).language),
              trailing: Row(children: [
                Text((LocaleNames.of(context)?.nameOf(_language ?? S.of(context).invalidLocale) ?? S.of(context).systemLanguage)
                    .replaceAll(' ', '\n'), textAlign: TextAlign.center,),
                const Icon(Icons.chevron_right)
              ]),
              leading: const Icon(Icons.language),
              onPressed: (context) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => LanguageScreen(
                      S.delegate.supportedLocales.map((l) => l.toLanguageTag()).toList(),
                      _language,
                      (l) => CacheManager.singleton.language = l
                  )
                ));
              },
            ),
          ],
        ),
        SettingsSection(
            title: const Text(appName),
            tiles: [
              SettingsTile(
                enabled: loggedIn,
                title: Text(S.of(context).self),
                trailing: loggedIn ? Text(_self, textAlign: TextAlign.right,) : const SizedBox(),
                leading: const Icon(Icons.accessibility_rounded),
              ),
              SettingsTile(
                enabled: CacheManager.singleton.loggedIn,
                title: Text(S.of(context).knownIDs),
                trailing: loggedIn ? Text(
                    _knownIDs.toString(), textAlign: TextAlign.center) : const SizedBox(),
                leading: Icon(_getFilterIcon(_knownIDs)),
              ),
              SettingsTile(
                enabled: CacheManager.singleton.loggedIn,
                title: Text(S.of(context).lastUploaded),
                trailing: loggedIn ? _lastServerUpdate.formattedDateTimeText() : const SizedBox(),
                leading: const Icon(Icons.access_time),
                onPressed: (_) async {
                  await Manager.singleton.getLastServerUpdate();
                },
              ),
            ]
        ),
        SettingsSection(
          title: Text(S.of(context).actions),
          tiles: [
            SettingsTile(
                title: Text(S.of(context).lastFetched),
                description: loggedIn ? (_refreshing
                    ? Text(S.of(context).refreshingSubstitutes)
                    : Text(S.of(context).clickToRefresh)) : const SizedBox(),
                trailing: loggedIn ? _lastClientUpdate.formattedDateTimeText() : const SizedBox(),
                leading: _refreshing ? LayoutBuilder(
                    builder: (context, constraints) =>
                        SizedBox.fromSize(
                            size: Size.square((
                                TextPainter(
                                    text: const TextSpan(),
                                    maxLines: 1,
                                    textScaleFactor: MediaQuery
                                        .of(context)
                                        .textScaleFactor,
                                    textDirection: ui.TextDirection.ltr
                                )
                                  ..layout()
                            ).height),
                            child: const CircularProgressIndicator()
                        )
                ) : const Icon(Icons.access_time_rounded),
                enabled: !_refreshing && CacheManager.singleton.loggedIn,
                onPressed: (_) => Manager.singleton.refresh(force: true)
            ),
            SettingsTile(
                enabled: CacheManager.singleton.loggedIn,
                title: Text(S.of(context).clearSubstitutes),
                leading: const Icon(Icons.clear_rounded),
                onPressed: (_) {
                  CacheManager.singleton.substitutes = [];
                  Manager.singleton.refresh(force: true);
                }
            ),
            SettingsTile(
                enabled: CacheManager.singleton.loggedIn,
                title: Text(S.of(context).clearCache),
                description: Text(S.of(context).exceptLoginData),
                leading: const Icon(Icons.clear_rounded),
                onPressed: (_) {
                  CacheManager.singleton.clearCacheExceptLoginData();
                  Manager.singleton.refresh(force: true);
                }
            ),
            SettingsTile(
              enabled: CacheManager.singleton.loggedIn,
              title: Text(S.of(context).logout),
              leading: const Icon(Icons.logout_rounded),
              onPressed: (_) => Manager.singleton.logout(),
            ),
          ],
        ),
      ],
    );
  }
}
