
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
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: Logger.scaffold = GlobalKey(),
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
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const NavigatorScaffoldState(),
    );
  }
}