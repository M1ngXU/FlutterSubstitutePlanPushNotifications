import 'package:flutter/material.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:settings_ui/settings_ui.dart';

class LanguageScreen extends StatefulWidget {
  final List<String> _locales;
  /// null == system locale
  final String? _current;
  /// null == system locale
  final Function(String?) _onDone;

  const LanguageScreen(this._locales, this._current, this._onDone, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LanguageScreenState();
}

SettingsTile _getTile(
    BuildContext context,
    MapEntry<String, String?> kvp,
    String? current,
    Function(BuildContext) onPressed
) => SettingsTile(
    title: Text(kvp.key),
    trailing: current == kvp.value
        ? Icon(PlatformIcons(context).checkMark, color: Colors.blue)
        : const SizedBox(),
    onPressed: onPressed
);

class _LanguageScreenState extends State<LanguageScreen> {
  List<MapEntry<String, String?>> _others = [];
  late SettingsSection _currentSection;
  late List<SettingsTile> _otherTiles;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _others = [const MapEntry<String?, String>(null, 'System Locale')].followedBy(
        LocaleNames
          .of(context)
          ?.sortedByName
          .where((e) => widget._locales.contains(e.key))
          .cast() ?? []
    ).map((e) => MapEntry<String, String?>(e.value, e.key)).toList();
    SettingsTile? current;
    _otherTiles = _others.map((e) => _getTile(context, e, widget._current, (c) => changeLocale(c, e.value))).toList();
    try {
      _otherTiles.remove(
          current = _otherTiles.firstWhere((e) => e.trailing is Icon));
    } catch (_) {}
    _currentSection = SettingsSection(
        title: const Text('Current'), tiles: current == null ? [] : [current]
    );
    return Scaffold(
        appBar: AppBar(
          title: const Text('Languages'),
          actions: [
            PlatformIconButton(
                icon: Icon(PlatformIcons(context).search),
                onPressed: () =>
                    showSearch(
                      context: context,
                      delegate: CustomSearchDelegate(_others, widget._current),
                    ).then((locale) => changeLocale(context, locale))
            ),
          ],
        ),
        body: SettingsList(sections: [
          _currentSection,
          SettingsSection(title: const Text('Others'), tiles: _otherTiles)
        ])
    );
  }

  void changeLocale(BuildContext c, String? locale) {
    Navigator.pop(c);
    widget._onDone(locale);
  }
}

class CustomSearchDelegate extends SearchDelegate {
  final List<MapEntry<String, String?>> _others;
  final String? _current;

  CustomSearchDelegate(this._others, this._current);

  @override
  List<Widget> buildActions(BuildContext context) => [
      PlatformIconButton(
        icon: Icon(PlatformIcons(context).clear),
        onPressed: () {
          query = '';
        },
      ),
    ];

  @override
  Widget buildLeading(BuildContext context) => PlatformIconButton(
      icon: Icon(PlatformIcons(context).back),
      onPressed: () => close(context, _current)
    );

  @override
  Widget buildSuggestions(BuildContext context) => SettingsList(
      sections: [SettingsSection(tiles: _others
          .where((e) => e.key.toLowerCase().startsWith(query.toLowerCase()) == true)
          .map((e) => _getTile(context, e, _current, (c) => close(c, e.value)))
          .toList()
  )]);

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);
}