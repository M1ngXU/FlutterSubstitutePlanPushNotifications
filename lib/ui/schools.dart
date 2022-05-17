import 'package:substitute_plan_push_notifications/protocol/response.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:substitute_plan_push_notifications/util.dart';


class SchoolSearchDelegate extends SearchDelegate {
  final Uri uri;

  SchoolSearchDelegate(this.uri);

  @override
  List<Widget> buildActions(BuildContext context) => [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () => close(context, null),
    );

  @override
  Widget buildSuggestions(BuildContext context) => FutureBuilder(
    future: get(uri.set('v1/leads', {'search': query})),
    builder: (context, snapshot) =>
        snapshot.connectionState == ConnectionState.done ? SettingsList(sections: [SettingsSection(
            tiles: castToJsonArray(processResponse((snapshot.requireData as Response).body))
                .map((s) => MapEntry(s['slink'] as String?, [s['name'] as String?, (s['city'] as String?)]))
                .where((e) => e.key != null && e.value[0] != null)
                .map((e) => SettingsTile(
                    title: Text(e.value[0]!),
                    description: e.value[1] != null ? Text(e.value[1]!) : null,
                    onPressed: (context) => close(context, e.key)
                ))
                .toList()
        )]) : const SizedBox()
  );

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);
}