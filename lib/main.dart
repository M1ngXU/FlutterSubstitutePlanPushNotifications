import 'dart:developer';

import 'package:better_sdui_push_notification/manager.dart';
import 'package:better_sdui_push_notification/ui/navigator_scaffold.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Manager.singleton.then((manager) async {
    (await manager.update()).forEach((s) => log(s.date.toIso8601String() + ': ' + s.toReadableString()));
    print(await manager.update());
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Better SDUI';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const NavigatorScaffoldState(),
    );
  }
}