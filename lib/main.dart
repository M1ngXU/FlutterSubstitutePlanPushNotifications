
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:substitute_plan_push_notifications/auto_update.dart';
import 'package:substitute_plan_push_notifications/cache/logger.dart';
import 'package:substitute_plan_push_notifications/cache/manager.dart';
import 'package:substitute_plan_push_notifications/manager.dart';
import 'package:substitute_plan_push_notifications/notification_manager.dart';
import 'package:substitute_plan_push_notifications/ui/navigator_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';

import 'generated/l10n.dart';
import 'package:substitute_plan_push_notifications/util.dart';

const String appName = 'Substitute Plan Push Notifications';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initPlatformState();
  NotificationManager.init();
  Manager.createOrGetInstance().then((manager) async {
    manager.cacheManager.version = 0;
    manager.cacheManager.onLanguageChangedCallback.putIfAbsent(-1, () => () => S.load(LocaleExtension.parse(manager.cacheManager.language)));
    manager.cacheManager.onLoginDataChangedCallback.putIfAbsent(-1, () => () => manager.refresh());
    runApp(const BetterSduiPushNotifications());
  });
}

class BetterSduiPushNotifications extends StatelessWidget {
  const BetterSduiPushNotifications({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => PlatformProvider(
      //initialPlatform: TargetPlatform.iOS,
      builder: (context) => PlatformApp(
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            LocaleNamesLocalizationsDelegate(),
          ],
          supportedLocales: S.delegate.supportedLocales,
          localeResolutionCallback: (deviceLocale, _) => LocaleExtension.tryParse(CacheManager.singleton.nullableLanguage) ?? deviceLocale,
          title: appName,
          cupertino: (_, __) => CupertinoAppData(
            home: CupertinoPageScaffold(
                resizeToAvoidBottomInset: false,
                child: Stack(
                    children: [
                      Scaffold(
                        key: Logger.scaffold = GlobalKey(),
                      ),
                      const NavigatorScaffoldState()
                    ]
                )
            ),
          ),
          material: (_, __) => MaterialAppData(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            scaffoldMessengerKey: Logger.scaffold = GlobalKey(),
            home: const NavigatorScaffoldState()
          )
      )
  );
}