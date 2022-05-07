import 'dart:collection';
import 'dart:convert';

import 'package:better_sdui_push_notification/substitute/time.dart';
import 'package:better_sdui_push_notification/util.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:quiver/collection.dart';

part 'substitute.g.dart';

const _cancelled = 'CANCLED';
const _bookableChange = 'BOOKABLE_CHANGE';
const _additional = 'ADDITIONAL';
const _event = 'EVENT';
const _substitution = 'SUBSTITUTION';
const _separator = '+';

JSONArray _hoursToJson(TreeSet<Time> hours) => hours.toList(growable: false).map((t) => t.toJson()).toList(growable: false);
TreeSet<Time> _hoursFromJson(JSONArray hours) {
  TreeSet<Time> t = TreeSet<Time>();
  t.addAll(hours.map(Time.fromJson));
  return t;
}
List<String> _tryRetrieveShortcuts(JSONObject? json, String key, JSONObject? parent, bool checkParent) {
  var l = _castOr<JSONArray>(json?[key], []).map((e) => e['shortcut'] as String).toList();
  if (l.isEmpty && checkParent && parent != null) l = _tryRetrieveShortcuts(parent, key, null, false);
  return l;
}
/// casts `t` to `T` if it is possible, otherwise returns `def`
T _castOr<T>(Object? t, T def) => t is T ? t : def;
JSONObject? _getKey(JSONObject? json, String key) => _castOr(json?[key], null);

enum SubstituteState {
  removed,
  added,
  modified,
  noChange
}

@JsonSerializable(explicitToJson: true)
class Substitute {
  final String id;
  late final DateTime date;
  final String description;
  final List<String> teachers;
  final String subject;
  final List<String> rooms;
  final String kind;
  final int day;
  @JsonKey(fromJson: _hoursFromJson, toJson: _hoursToJson)
  late TreeSet<Time> hours = TreeSet<Time>();
  SubstituteState? state;

  Substitute(
      this.id,
      DateTime date,
      this.description,
      this.teachers,
      this.subject,
      this.rooms,
      this.kind,
      this.day,
      this.hours,
      this.state) {
    this.date = DateTime(date.year, date.month, date.day);
  }

  factory Substitute.createDummy({id = 'id', date = 0, description = 'description', teachers, subject = 'subject', rooms, kind = 'kind', day = 1, hours, state = SubstituteState.added}) {
    var t = TreeSet<Time>();
    t.add(Time(0, '4'));
    t.add(Time(-1, '1'));
    return Substitute(id, DateTime.fromMillisecondsSinceEpoch(date), description, teachers ?? ['teacher'], subject, rooms ?? ['room'], kind, day, hours ?? t, state);
  }

  static List<Substitute> fromSduiJson(JSONObject json, HashMap<String, Time> times, String grade, {JSONObject? parent}) {
    List<Substitute> s = [];
    String? kind = _castOr(json['kind'], null);
    if (kind != null && kind.isNotEmpty && _castOr<JSONArray>(json['grades'], []).any((g) => g['shortcut'] == grade)) {
      s.addAll(
          _castOr<List<int>>(json['dates'], [])
              .map((d) => DateTime.fromMillisecondsSinceEpoch(d * 1000))
              .where((d) => d.isAfter(DateTime.now()))
              .map((d) =>
                Substitute(
                    _castOr(json['id'], ''),
                    d,
                    json['description'],
                    _tryRetrieveShortcuts(json, 'teachers', parent, kind == _cancelled || kind == _bookableChange),
                    _getKey(_getKey(json, 'course'), 'meta')?['shortname'] ?? '',
                    _tryRetrieveShortcuts(json, 'bookables', parent, kind == _cancelled),
                    kind,
                    _castOr(json['day'], 0),
                    singleTreeSet(times[json['time_id']] ?? Time(0, 'ALL DAY')),
                    null
                )
              )
      );
    }
    s.addAll((json['substituted_target_lessons'] as JSONArray? ?? [])
        .expand((lesson) => fromSduiJson(lesson, times, grade, parent: json)));
    return s;
  }

  factory Substitute.fromJson(JSONObject json) => _$SubstituteFromJson(json);

  JSONObject toJson() => _$SubstituteToJson(this);

  /// JSON representation for the [`Substitute`].
  @override
  String toString() => jsonEncode(toJson());

  @override
  bool operator ==(Object other) => other is Substitute && _deepCompare(other);

  bool _deepCompare(Substitute other) => id == other.id
      && date == other.date
      && description == other.description
      && deepEqualSet(teachers.toSet(), other.teachers.toSet())
      && subject == other.subject
      && deepEqualSet(rooms.toSet(), other.rooms.toSet())
      && kind == other.kind
      && day == other.day
      && deepEqualSet(hours, other.hours)
      && state == other.state;

  @override
  int get hashCode => Object.hash(id, date, description, teachers, subject, rooms, kind, day, hours, state);

  String formatByKind() {
    switch (kind) {
      case _cancelled:
        return 'cancelled';
      case _bookableChange:
        return '${'bookable change'} => $_rooms';
      case _substitution:
        return '${'substitution'} => $_teachers|$_rooms';
      case _event:
      case _additional:
        return '$kind ($description)';
      default:
        return '$kind ($subject: $_teachers|$_rooms)';
    }
  }

  String get _rooms => rooms.join(_separator);
  String get _teachers => teachers.join(_separator);

  String toReadableString() => '${'Lesson'} ${hours.map((e) => e.name).join(_separator)} ($subject): ${formatByKind()}';

  bool subjectHourEquality(Object other) => other is Substitute && subjectHourComparison(other) == 0;

  int subjectHourComparison(Substitute o) {
    int d = date.compareTo(o.date);
    Time selfFirst = hours.isNotEmpty ? hours.first : Time(-99999, '');
    Time otherFirst = o.hours.isNotEmpty ? o.hours.first : Time(-99999, '');
    // if the dates AND the lessons are the same, return 0, since 'they are the same'
    return d == 0 && subject != o.subject ? selfFirst.compareTo(otherFirst) : d;
  }
}