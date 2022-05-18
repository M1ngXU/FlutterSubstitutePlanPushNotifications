import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
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
Widget _getTitle(BuildContext ctx, String title, String? description) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title),
      if (description != null) Text(description, style: Theme.of(ctx).textTheme.bodySmall)
    ]
);
Widget _formattedLanguage(BuildContext ctx, String? nullableLocale) => Text(
  LocaleNames.of(ctx)?.nameOf(nullableLocale ?? S.of(ctx).invalidLocale)
      ?? S.of(ctx).systemLanguage.replaceAll(' ', '\n'),
  textAlign: TextAlign.center,
);

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
                _showHolidays = CacheManager.singleton.showHolidays = v;
                return true;
              },
              initialValue: _showHolidays,
              leading: const Icon(Icons.announcement_outlined),
              title: _getTitle(
                  context,
                  S.of(context).holidays,
                  S.of(context).showSubstitutesForHolidays
              ),
            ),
          ],
        ),
        SettingsSection(
          title: Text(S.of(context).language),
          tiles: [
            SettingsTile.navigation(
              title: Text(S.of(context).language),
              value: isCupertino(context) ? _formattedLanguage(context, _language) : null,
              trailing: isMaterial(context) ? Row(children: [_formattedLanguage(context, _language), const Icon(Icons.chevron_right)]) : null,
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
            SettingsTile.navigation(
              title: _getTitle(
                  context,
                  S.of(context).dateLocale,
                  S.of(context).dateFormatting
              ),
              value: isCupertino(context) ? _formattedLanguage(context, _dateLocale) : null,
              trailing: isMaterial(context) ? Row(children: [_formattedLanguage(context, _dateLocale), const Icon(Icons.chevron_right)]) : null,
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
          ],
        ),
        SettingsSection(
            title: const Text(appName),
            tiles: [
              SettingsTile(
                enabled: loggedIn,
                title: Text(S.of(context).self),
                trailing: loggedIn ? Text(_self, textAlign: TextAlign.right,) : const SizedBox(),
                leading: Icon(PlatformIcons(context).time),
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
                leading: Icon(PlatformIcons(context).time),
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
                title: _getTitle(
                    context,
                    S.of(context).lastFetched,
                    loggedIn ? _refreshing ? S.of(context).refreshingSubstitutes : S.of(context).clickToRefresh : null
                ),
                trailing: loggedIn ? _lastClientUpdate.formattedDateTimeText() : const SizedBox(),
                leading: _refreshing ? LayoutBuilder(
                    builder: (context, constraints) =>
                        SizedBox.fromSize(
                            size: Size.square((
                                TextPainter(
                                    text: const TextSpan(),
                                    maxLines: 1,
                                    textScaleFactor: MediaQuery.of(context).textScaleFactor,
                                    textDirection: ui.TextDirection.ltr
                                )..layout()
                            ).height),
                            child: const CircularProgressIndicator()
                        )
                ) : Icon(PlatformIcons(context).time),
                enabled: !_refreshing && CacheManager.singleton.loggedIn,
                onPressed: (_) => Manager.singleton.refresh(force: true)
            ),
            SettingsTile(
                enabled: CacheManager.singleton.loggedIn,
                title: Text(S.of(context).clearSubstitutes),
                leading: Icon(PlatformIcons(context).clear),
                onPressed: (_) {
                  CacheManager.singleton.substitutes = [];
                  Manager.singleton.refresh(force: true);
                }
            ),
            SettingsTile(
                enabled: CacheManager.singleton.loggedIn,
                title: _getTitle(
                    context,
                    S.of(context).clearCache,
                    S.of(context).exceptLoginData
                ),
                leading: Icon(PlatformIcons(context).clear),
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
        SettingsSection(
          tiles: [SettingsTile(title: Text.rich(
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Programmed by ',
                  ),
                  TextSpan(
                    text: 'M1ngXU',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              style: Theme.of(context).textTheme.subtitle1,
            textAlign: TextAlign.right,
          ),)],
        )
      ],
    );
  }
}
