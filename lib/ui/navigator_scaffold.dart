import 'package:better_sdui_push_notification/ui/settings.dart';
import 'package:better_sdui_push_notification/ui/substitutes.dart';
import 'package:flutter/material.dart';

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
  final String title;
  final IconData iconData;
  final StatefulWidget body;

  Icon get icon => Icon(iconData);
  Widget buildWidget(
      BuildContext context,
      StatefulWidget currentlySelected,
      void Function(BuildContext, StatefulWidget) setSelected
  ) => Column(
    children: [
      const SizedBox(height: 8),
      Material(
          color: Colors.transparent,
          child: ListTile(
            selected: currentlySelected == body,
            selectedTileColor: _getTransitionColorByContext(context),
            leading: icon,
            title: Text(title),
            onTap: () => setSelected(context, body),
          )
      ),
      const SizedBox(height: 8),
    ],
  );

  SubNavigation(this.title, this.iconData, this.body);
}

class NavigatorScaffold extends State<NavigatorScaffoldState> {
  static final widgets = [
    SubNavigation('Substitutes', Icons.access_time, const SubstituteUIState()),
    SubNavigation('Settings', Icons.settings, const SettingsState()),
  ];
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  StatefulWidget _currentlySelected = const SubstituteUIState();
  bool _opened = false;

  NavigatorScaffold();

  void _setSelected(BuildContext context, StatefulWidget selected) {
    setState(() => _currentlySelected = selected);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
        leading: IconButton(
            icon: Icon(_opened ? Icons.arrow_back : Icons.menu),
            onPressed: () => _opened ? Navigator.pop(context) : _key.currentState?.openDrawer()
        ),
        title: const Text('Better Sdui Push Notifications')
    ),
    body: Scaffold(
      key: _key,
      onDrawerChanged: (s) => setState(() => _opened = s),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            // header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
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
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _divider,
                  widgets[0].buildWidget(context, _currentlySelected, _setSelected),
                  _divider,
                  widgets[1].buildWidget(context, _currentlySelected, _setSelected)
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