import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:substitute_plan_push_notifications/util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'logger.g.dart';

class Logger {
  static final Logger singleton = Logger._();
  static GlobalKey<ScaffoldMessengerState>? scaffold;

  List<Log> logs = [];
  HashMap<int, Function()> onLogsChanged = HashMap();
  SharedPreferences? _sharedPreferences;

  Logger._() {
    SharedPreferences.getInstance().then((sp) {
      try {
        _sharedPreferences = sp;
        logs = sp.getStringList('logs')?.map((l) => Log.fromJson(jsonDecode(l))).toList() ?? [];
      } catch(e, s) {
        dev.log('[ERROR] Failed to read logs ($e).\n$s');
      }
    });
  }

  void _saveLogs() async {
    if (await _sharedPreferences?.setStringList('logs', logs.map((l) => jsonEncode(l.toJson())).toList()) != true) {
      dev.log('[ERROR] Failed to write logs.');
    }
  }
  void _callCallbacks() {
    for (var f in onLogsChanged.values) {
      f.call();
    }
  }

  void _log(LogType lt, String s, [Object? e, StackTrace? st]) async {
    DateTime current = DateTime.now();
    Log l = Log(current, lt, s + (e != null ? '\nError: $e' + (st != null ? '\nStack trace: $st' : '') : ''));
    logs.add(l);
    dev.log(l.toString());
    _saveLogs();
    _callCallbacks();
  }
  void _snack(String s, LogType lt) {
    try {
      if (scaffold == null) throw "SnackBar key hasn't been init!";
      scaffold!.currentState!.showSnackBar(SnackBar(
          content: Row(
              children: [
                lt.getIcon(scaffold!.currentContext!),
                Flexible(
                    child: Container(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text(s, overflow: TextOverflow.fade),
                    )
                ),
              ]
          ),
          duration: Duration(seconds: (s.length / 10).floor())
      ));
    } catch(e) {
      dev.log('Failed to access scaffold manager ($e).');
    }
  }

  /// debug
  static void d(String s, [Object? e, StackTrace? st]) => singleton._log(LogType.debug, s, e, st);
  /// info
  static void i(String s, [Object? e, StackTrace? st]) => singleton._log(LogType.info, s, e, st);
  /// warning
  static void w(String s, [Object? e, StackTrace? st]) => singleton._log(LogType.warning, s, e, st);
  /// error
  static void e(String s, [Object? e, StackTrace? st]) => singleton._log(LogType.error, s, e, st);

  /// info + snack
  static void vi(String s, [Object? e, StackTrace? st]) {
    singleton._snack(s, LogType.info);
    i(s, e, st);
  }
  /// warning + snack
  static void vw(String s, [Object? e, StackTrace? st]) {
    singleton._snack(s, LogType.warning);
    w(s, e, st);
  }
  /// error + snack
  static void ve(String s, [Object? err, StackTrace? st]) {
    singleton._snack(s, LogType.error);
    e(s, err, st);
  }

  void _clearLogs() {
    logs = [];
    _saveLogs();
    _callCallbacks();
  }

  static void clearLogs() => singleton._clearLogs();
  static int logLength() => (singleton._sharedPreferences?.getStringList('logs') ?? []).fold(0, (v, l) => v + l.length);
}

@JsonSerializable()
class Log {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd hh:mm:ss.SSSS');

  final DateTime time;
  final LogType type;
  final String content;

  Log(this.time, this.type, this.content);

  factory Log.fromJson(JsonObject json) => _$LogFromJson(json);

  JsonObject toJson() => _$LogToJson(this);

  @override
  String toString() => '${_dateFormat.format(time)} ${type.getFormattedString()} $content';
}

enum LogType {
  debug,
  info,
  warning,
  error
}
extension LogTypeExtension on LogType {
  static final Map<LogType, String> _stringRepresentation = {
    LogType.debug: 'DEBUG',
    LogType.info: 'INFO',
    LogType.warning: 'WARNING',
    LogType.error: 'ERROR'
  };
  static const Map<LogType, Color> _colorRepresentation = {
    LogType.debug: Colors.green,
    LogType.info: Colors.blue,
    LogType.warning: Colors.yellow,
    LogType.error: Colors.red
  };
  static final Map<LogType, IconData Function(PlatformIcons)> _iconRepresentation = {
    LogType.debug: (_) => Icons.bug_report_outlined,
    LogType.info: (p) => isMaterial(p.context) ? Icons.info_outline_rounded : CupertinoIcons.info,
    LogType.warning: (_) => Icons.warning_amber_rounded,
    LogType.error: (p) => isMaterial(p.context) ? Icons.error_outline_rounded : CupertinoIcons.exclamationmark_circle
  };

  String getFormattedString() => '[${_stringRepresentation[this]}]'
      .padRight(_stringRepresentation.values.fold<int>(0, (a, s1) => max(a, s1.length)) + 2);

  Color getColor() => _colorRepresentation[this]!;
  IconData getIconData(BuildContext ctx) => _iconRepresentation[this]!(PlatformIcons(ctx));
  Icon getIcon(BuildContext ctx) => Icon(getIconData(ctx), color: getColor());
}