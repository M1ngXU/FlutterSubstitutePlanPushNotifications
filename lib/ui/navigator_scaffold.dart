import 'package:substitute_plan_push_notifications/main.dart';
import 'package:substitute_plan_push_notifications/ui/log.dart';
import 'package:substitute_plan_push_notifications/ui/settings.dart';
import 'package:substitute_plan_push_notifications/ui/substitutes.dart';
import 'package:flutter/material.dart';

import '../cache/manager.dart';
import '../generated/l10n.dart';
import 'login.dart';

const double _subNavigationSpacing = 5;
const Divider _divider = Divider(thickness: 2);
const Color _grey = Color.fromARGB(128, 128, 128, 128);
Color _getTransitionColorByContext(BuildContext context) =>
    Color.lerp(Theme.of(context).drawerTheme.backgroundColor, _grey, 0.7) ?? _grey;

class NavigatorScaffoldState extends StatefulWidget {
  const NavigatorScaffoldState({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => NavigatorScaffold();
}

class SubNavigation {
  String Function(S) title;
  IconData iconData;
  Widget body;

  Icon get icon => Icon(iconData);
  Widget buildWidget(
      BuildContext context,
      Widget currentlySelected,
      void Function(BuildContext, Widget) setSelected
  ) => Column(
    children: [
      const SizedBox(height: _subNavigationSpacing),
      Material(
          color: Colors.transparent,
          child: ListTile(
            selected: currentlySelected.runtimeType == body.runtimeType,
            selectedTileColor: _getTransitionColorByContext(context),
            leading: icon,
            title: Text(title(S.of(context))),
            onTap: () => setSelected(context, body),
          )
      ),
      const SizedBox(height: _subNavigationSpacing),
    ],
  );

  SubNavigation(this.title, this.iconData, this.body);
}

class NavigatorScaffold extends State<NavigatorScaffoldState> {
  final List<SubNavigation?> _widgets = [
    null,
    SubNavigation((s) => s.logs, Icons.info_outline_rounded, const LogScreen()),
    SubNavigation((s) => s.settings, Icons.settings, const SettingsScreen()),
  ];
  final _substituteScreen = SubNavigation((s) => s.substitutes, Icons.more_time_rounded, const SubstituteScreen());
  final _loginScreen = SubNavigation((s) => s.login, Icons.login_rounded, LoginScreen());
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  Widget? _currentlySelected;
  bool _opened = false;

  NavigatorScaffold();

  void _setSelected(BuildContext context, Widget selected) {
    setState(() => _currentlySelected = selected);
    Navigator.pop(context);
  }

  void _setMainWidget(CacheManager m) =>
      setState(() {
        bool changeCurrent = _currentlySelected == _widgets[0]?.body;
        _widgets[0] = !m.loggedIn ? _loginScreen : _substituteScreen;
        if (changeCurrent) _currentlySelected = _widgets[0]?.body;
      });

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
    : Scaffold(
      appBar: AppBar(
          leading: IconButton(
              icon: Icon(_opened ? Icons.arrow_back : Icons.menu),
              onPressed: () => _opened ? Navigator.pop(context) : _key.currentState?.openDrawer()
          ),
          title: const Text(appName, overflow: TextOverflow.fade,)
      ),
      body: Scaffold(
        key: _key,
        onDrawerChanged: (s) => setState(() => _opened = s),
        drawer: Drawer(
          child: ListView(
            children: [
              // header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: ListTile(
                      title: Center(
                          child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  image: const DecorationImage(
                                    image: AssetImage('assets/images/icon.png'),
                                    fit: BoxFit.cover
                                  ),
                                  borderRadius: const BorderRadius.all(Radius.circular(50)),
                                  border: Border.all(
                                    color: _getTransitionColorByContext(context),
                                    width: 4
                                  )
                                ),
                              )
                          )
                        ),
                        subtitle: const Text(appName, textAlign: TextAlign.center,),
                  )
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _divider,
                    _widgets[0]!.buildWidget(context, _currentlySelected!, _setSelected),
                    _divider,
                    _widgets[1]!.buildWidget(context, _currentlySelected!, _setSelected),
                    _divider,
                    _widgets[2]!.buildWidget(context, _currentlySelected!, _setSelected),
                    _divider,
                    Container(
                      alignment: Alignment.centerRight,
                        child: Text.rich(
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
                            style: Theme.of(context).textTheme.subtitle1
                        )
                    )
                  ],
                )
              )
            ],
          ),
        ),
        body: _currentlySelected,
      ),
    );
}