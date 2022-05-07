import 'package:flutter/material.dart';

class SettingsState extends StatefulWidget {
  const SettingsState({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => Settings();
}

class Settings extends State<SettingsState> {
  Settings();

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text('hi')
    );
  }
}