import 'dart:collection';
import 'dart:io';
import 'dart:ui';

import 'package:substitute_plan_push_notifications/substitute/time.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:quiver/collection.dart';
import 'package:intl/locale.dart' as l;

import 'cache/manager.dart';

typedef JsonObject = Map<String, dynamic>;
typedef JsonArray = List<JsonObject>;
typedef Times = HashMap<int, Time>;

TreeSet<T> singleTreeSet<T>(T item) => doubleTreeSet(item, item);
TreeSet<T> doubleTreeSet<T>(T item1, T item2) => TreeSet()..addAll([item1, item2]);

bool deepEqualSet<T>(Set<T> set1, Set<T> set2) => set1.length == set2.length && set1.difference(set2).isEmpty;

List<T> castListOr<T>(Object? t, List<T> def) => t is List<dynamic> && t.every((e) => e is T) ? t.cast<T>() : def;
JsonArray castToJsonArray(Object? t) => castListOr(t, []);
/// casts `t` to `T` if it is possible, otherwise returns `def`
T castOr<T>(Object? t, T def) => t is T ? t : def;
JsonObject? getKey(JsonObject? json, String key) => castOr(json?[key], null);

String getSystemLocale() => Intl.systemLocale = Intl.canonicalizedLocale(Platform.localeName);

dynamic Function() Function() putIfAbsent<T>(T t, Function(T) f) => () => () => f(t);

extension ColorExtension on Color {
  Color invert() => Color.fromARGB(255 - alpha, 255 - red, 255 - green, 255 - blue);
}

extension DateTimeExtension on DateTime {
  DateTime stripSeconds() => add(Duration(seconds: -second, milliseconds: -millisecond, microseconds: -microsecond));
  DateTime stripHours() => DateTime(year, month, day);
  Text formattedDateTimeText({Color? color}) => Text(
      DateFormat
          .yMd(CacheManager.singleton.dateLocale)
          .addPattern('', '\n')
          .add_jms()
          .format(this),
      textAlign: TextAlign.right,
      style: TextStyle(fontFeatures: const [FontFeature.tabularFigures()], color: color),
  );
}

extension UriExtension on Uri {
  Uri set(String path, [Map<String, String> query = const {}]) => Uri(scheme: scheme, host: host, path: path, queryParameters: query);
}

extension Toastify on String {
  void toastify({
    Toast toastLength = Toast.LENGTH_SHORT,
    Color backgroundColor = const Color.fromRGBO(0xEE, 0xEE, 0xEE, 0.9),
    Color textColor = Colors.black
  }) => Fluttertoast.showToast(
      msg: this,
      toastLength: toastLength,
      backgroundColor: backgroundColor,
      textColor: textColor
  );
}

extension LocaleExtension on Locale {
  static Locale parse(String? locale) => tryParse(locale)!;

  static Locale? tryParse(String? locale) {
    if (locale == null) return null;
    var parsed = l.Locale.tryParse(locale);
    if (parsed == null) return null;
    return Locale.fromSubtags(
        languageCode: parsed.languageCode,
        scriptCode: parsed.scriptCode,
        countryCode: parsed.countryCode
    );
  }
}