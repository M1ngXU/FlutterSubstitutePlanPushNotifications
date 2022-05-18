import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:substitute_plan_push_notifications/ui/log.dart';
import 'package:substitute_plan_push_notifications/ui/settings.dart';
import 'package:substitute_plan_push_notifications/ui/substitutes.dart';
import 'package:flutter/material.dart';

import '../cache/manager.dart';
import '../generated/l10n.dart';
import '../main.dart';
import 'login.dart';

class NavigatorScaffoldState extends StatefulWidget {
  const NavigatorScaffoldState({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => NavigatorScaffold();
}

class SubNavigation {
  String Function(S) title;
  IconData Function(PlatformIcons) iconData;
  Widget body;

  BottomNavigationBarItem buildWidget(BuildContext context) => BottomNavigationBarItem(
    icon: Icon(iconData(PlatformIcons(context))),
    label: title(S.of(context)),
  );

  SubNavigation(this.title, this.iconData, this.body);
}

class NavigatorScaffold extends State<NavigatorScaffoldState> {
  final List<SubNavigation?> _widgets = [
    null,
    SubNavigation((s) => s.logs, (p) => p.info, const LogScreen()),
    SubNavigation((s) => s.settings, (p) => p.settings, const SettingsScreen()),
  ];
  final _substituteScreen = SubNavigation((s) => s.substitutes, (p) => p.time, const SubstituteScreen());
  final _loginScreen = SubNavigation((s) => s.login, (_) => Icons.login_rounded, LoginScreen());
  int _currentlySelected = 0;

  NavigatorScaffold();

  void _setMainWidget(CacheManager m) => setState(() => _widgets[0] = !m.loggedIn ? _loginScreen : _substituteScreen);

  @override
  void didChangeDependencies() {
    CacheManager.getInstance().then((m) {
      _setMainWidget(m);
      m.onLoginDataChangedCallback.putIfAbsent(hashCode, () => () => _setMainWidget(m));
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    CacheManager.singleton.onLoginDataChangedCallback.remove(hashCode);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _widgets[0] == null
      ? const SizedBox()
      : PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text(appName),
      ),
      bottomNavBar: PlatformNavBar(
        items: _widgets.map((e) => e!.buildWidget(context)).toList(),
        itemChanged: (i) => setState(() => _currentlySelected = i),
        currentIndex: _currentlySelected,
      ),
      body: SafeArea(child: _widgets[_currentlySelected]!.body)
  );
}