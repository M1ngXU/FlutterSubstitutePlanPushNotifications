import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:substitute_plan_push_notifications/cache/manager.dart';
import 'package:substitute_plan_push_notifications/substitute/time.dart';
import 'package:substitute_plan_push_notifications/util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:quiver/collection.dart';

import '../generated/l10n.dart';

part 'substitute.g.dart';

const _cancellation = 'CANCLED';
const _bookableChange = 'BOOKABLE_CHANGE';
const _additional = 'ADDITIONAL';
const event = 'EVENT';
const _substitution = 'SUBSTITUTION';
Map<String, String Function()> _translationByKind = {
  _cancellation: () => S.current.cancellation,
  _bookableChange: () => S.current.bookableChange,
  _substitution: () => S.current.substitution,
  event: () => S.current.event,
  _additional: () => S.current.additional
};
Map<String, IconData Function(PlatformIcons)> _iconByKind = {
  _cancellation: (p) => isMaterial(p.context) ? Icons.cancel_outlined : CupertinoIcons.clear_circled,
  _bookableChange: (_) => Icons.drive_file_move_outline,
  _substitution: (_) => Icons.find_replace_rounded,
  event: (_) => Icons.event_note_outlined,
  _additional: (p) => p.addCircledOutline
};
Map<String, String Function(Substitute)> _kindFormatter = {
  _cancellation: (s) => s.translatedKind,
  _bookableChange: (s) => '${s.translatedKind} => ${s._rooms}',
  _substitution: (s) => '${s.translatedKind} => ${s._teachers}|${s._rooms}',
  event: (s) => s.comment.isEmpty ? s.translatedKind : s.formattedComment,
  _additional: (s) {
    var kind = s.translatedKind;
    String before = '';
    String after = '';
    if (s.comment.isNotEmpty) {
      before = '${s.formattedComment} (';
      after = ')';
    }
    return '$before$kind$after';
  }
};
const _separator = '+';

JsonArray _hoursToJson(TreeSet<Time> hours) => hours.toList(growable: false).map((t) => t.toJson()).toList(growable: false);
TreeSet<Time> _hoursFromJson(List<dynamic> hours) {
  TreeSet<Time> t = TreeSet<Time>();
  t.addAll(castToJsonArray(hours).map(Time.fromJson));
  return t;
}
List<String> _tryRetrieveShortcuts(JsonObject? json, String key, JsonObject? parent, bool checkParent) {
  var l = castToJsonArray(json?[key]).map((e) => e['shortcut'] as String).toList();
  if (l.isEmpty && checkParent && parent != null) l = _tryRetrieveShortcuts(parent, key, null, false);
  return l;
}
String _spaceParenthesisIfNotEmpty(String s) => s.isNotEmpty ? ' ($s)' : '';

enum SubstituteState {
  removed,
  added,
  modified,
  noChange,
  expired
}
extension SubstituteStateExtension on SubstituteState {
  bool get needsSave => this == SubstituteState.added || this == SubstituteState.modified || this == SubstituteState.noChange;
}

@JsonSerializable(explicitToJson: true)
class Substitute {
  final int id;
  final DateTime date;
  String comment;
  final List<String> teachers;
  final String subject;
  final List<String> rooms;
  String kind;
  @JsonKey(fromJson: _hoursFromJson, toJson: _hoursToJson)
  late TreeSet<Time> hours = TreeSet<Time>();
  SubstituteState? state;

  Substitute(
      this.id,
      DateTime date,
      this.comment,
      this.teachers,
      this.subject,
      this.rooms,
      this.kind,
      this.hours,
      this.state
  ) : date = DateTime(date.year, date.month, date.day);

  factory Substitute.createDummy({int id = 0, date = 0, description = 'description', teachers, subject = 'subject', rooms, kind = 'kind', hours, state = SubstituteState.added}) {
    var t = TreeSet<Time>();
    t.add(Time(0, '4', DateTime(0, 0, 0, 12, 15), DateTime(0, 0, 0, 13, 0)));
    t.add(Time(-1, '1', DateTime(0, 0, 0, 5, 1), DateTime(0, 0, 0, 6, 2)));
    return Substitute(id, DateTime.fromMillisecondsSinceEpoch(date), description, teachers ?? ['teacher'], subject, rooms ?? ['room'], kind, hours ?? t, state);
  }

  static List<Substitute> fromSduiJson(JsonObject json, Times times, String grade, {JsonObject? parent}) {
    List<Substitute> s = [];
    String? kind = castOr(json['kind'], null);
    if (kind != null && [json, parent]
        .any((o) {
          var g = castToJsonArray(o?['grades'])
              .map((g) => g['shortcut'])
              .whereType<String>();
          if (CacheManager.singleton.showHolidays) {
            return g.contains(grade);
          } else {
            return (g.length == 1 && g.first == grade) || (g.contains(grade) && o?['comment'].isNotEmpty == true);
          }
    })
    ) {
      s.addAll(
          castListOr<int>(json['dates'], [])
              .map((d) => DateTime.fromMillisecondsSinceEpoch(d * 1000))
              .where((d) => !d.isBefore(DateTime.now().stripHours()))
              .map((d) => Substitute(
                    castOr(json['id'], 0),
                    d,
                    json['comment'] ?? '',
                    _tryRetrieveShortcuts(json, 'teachers', parent,
                        kind == _cancellation || kind == _bookableChange),
                    getKey(getKey(json, 'course'), 'meta')?['shortname'] ?? '',
                    _tryRetrieveShortcuts(
                        json, 'bookables', parent, kind == _cancellation),
                    kind,
                    singleTreeSet(times[json['time_id']] ?? times[parent?['time_id']] ?? Time(-1, '')),
                    null
                )
              )
      );
    }
    s.addAll(castToJsonArray(json['substituted_target_lessons'])
        .expand((lesson) => fromSduiJson(lesson, times, grade, parent: json)));
    return s;
  }

  factory Substitute.fromJson(JsonObject json) => _$SubstituteFromJson(json);

  JsonObject toJson() => _$SubstituteToJson(this);

  /// JSON representation for the [`Substitute`].
  @override
  String toString() => jsonEncode(toJson());

  @override
  bool operator ==(Object other) => other is Substitute && _deepCompare(other);

  bool _deepCompare(Substitute other) => id == other.id
      && date == other.date
      && comment == other.comment
      && deepEqualSet(teachers.toSet(), other.teachers.toSet())
      && subject == other.subject
      && deepEqualSet(rooms.toSet(), other.rooms.toSet())
      && kind == other.kind
      && deepEqualSet(hours, other.hours);

  @override
  int get hashCode => Object.hash(id, date, comment, teachers, subject, rooms, kind, hours, state);

  /// gets the translated lesson representation (e.g. all day, Lesson 1+2)
  String get lessons {
    var lessons = hours.map((e) => e.name).where((e) => e.isNotEmpty);
    return lessons.isEmpty ? S.current.allDay : '${S.current.lesson} ${lessons.join(_separator)}';
  }
  String get formattedDate => DateFormat.MMMMEEEEd(CacheManager.singleton.dateLocale).format(date);
  String get translatedKind => _translationByKind[kind]?.call() ?? S.current.unknownKind;
  String get formattedKind => _kindFormatter[kind]?.call(this) ?? '$kind ($subject: $_teachers|$_rooms)';
  /// tries to format the comment using different regexes
  String get formattedComment => isExam ? S.current.exam : comment;
  bool get isExam => RegExp(r'Beschreibung:\s*.*?;' '\n' r'Stunde:\s*\d\/\d;').hasMatch(comment);

  IconData icon(BuildContext ctx) => _iconByKind[kind]?.call(PlatformIcons(ctx)) ?? PlatformIcons(ctx).helpOutline;

  String get _rooms => rooms.join(_separator);
  String get _teachers => teachers.join(_separator);

  String toReadableString() => '$lessons${_spaceParenthesisIfNotEmpty(subject)}: $formattedKind';

  String getTimeRangeString(BuildContext context, DateFormat timeFormatter) {
    if (hours.every((e) => e.order == -1)) return '';
    StringBuffer result = StringBuffer();
    var first = hours.firstWhere((t) => t.order != -1);
    result.write(timeFormatter.format(first.from.toLocal()));
    if (hours.length > 1) result.write(' (${first.name})');
    result.writeln();
    result.write(timeFormatter.format(hours.last.to.toLocal()));
    if (hours.length > 1) result.write(' (${hours.last.name})');
    return result.toString();
  }

  bool subjectHourEquality(Object other) => other is Substitute && subjectHourComparison(other) == 0;

  int subjectHourComparison(Substitute o) {
    int d = date.compareTo(o.date);
    Time selfFirst = hours.isNotEmpty ? hours.first : Time(-99999, '');
    Time otherFirst = o.hours.isNotEmpty ? o.hours.first : Time(-99999, '');
    // if the dates AND the lessons are the same, return 0, since 'they are the same'
    return d == 0 && subject != o.subject ? selfFirst.compareTo(otherFirst) : d;
  }
}