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

List<Map<String, dynamic>> _hoursToJson(TreeSet<Time> hours) => hours.toList(growable: false).map((t) => t.toJson()).toList(growable: false);
TreeSet<Time> _hoursFromJson(List<Map<String, dynamic>> hours) {
  TreeSet<Time> t = TreeSet<Time>();
  t.addAll(hours.map(Time.fromJson));
  return t;
}

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
  final String teacher;
  final String subject;
  final String room;
  final String kind;
  final int day;
  @JsonKey(fromJson: _hoursFromJson, toJson: _hoursToJson)
  late TreeSet<Time> hours = TreeSet<Time>();
  SubstituteState? state;

  Substitute(
      this.id,
      DateTime date,
      this.description,
      this.teacher,
      this.subject,
      this.room,
      this.kind,
      this.day,
      this.hours,
      this.state) {
    this.date = DateTime(date.year, date.month, date.day);
  }

  factory Substitute.createDummy({id = 'id', date = 0, description = 'description', teacher = 'teacher', subject = 'subject', room = 'room', kind = 'kind', day = 1, hours, state = SubstituteState.added}) {
    var t = TreeSet<Time>();
    t.add(Time(0, '4'));
    t.add(Time(-1, '1'));
    return Substitute(id, DateTime.fromMillisecondsSinceEpoch(date), description, teacher, subject, room, kind, day, hours ?? t, state);
  }

  static List<Substitute> fromSduiJson(Map<String, dynamic> json, HashMap<String, Time> times, String grade, {Map<String, dynamic>? parent}) {
    List<Substitute> s = [];
    String? kind = json['kind'];
    if (kind != null && kind.isNotEmpty && (json['grades'] as List<Map<String, dynamic>>? ?? []).any((g) => g['shortcut'] == grade)) {
      s.addAll((json['dates'] as List<int>? ?? []).map((d) => DateTime.fromMillisecondsSinceEpoch(d * 1000)).where((d) => d.isAfter(DateTime.now())).map((d) =>
          Substitute(
              json['id'],
              d,
              json['description'],
              json['teachers']?[0]?['shortcut'] ?? ((kind == _cancelled || kind == _bookableChange) ? (parent?['teachers']?[0]?['shortcut']) : null) ?? '',
              json['course']?['meta']?['shortname'] ?? '',
              json['bookables']?[0]?['shortcut'] ?? '',
              kind,
              json['day'],
              singleTreeSet(times[json['time_id']] ?? Time(0, 'ALL DAY')),
              null
          )
      ));
    }
    s.addAll((json['substituted_target_lessons'] as List<Map<String, dynamic>>? ?? [])
        .expand((lesson) => fromSduiJson(lesson, times, grade, parent: json)));
    return s;
  }

  factory Substitute.fromJson(Map<String, dynamic> json) => _$SubstituteFromJson(json);

  Map<String, dynamic> toJson() => _$SubstituteToJson(this);

  /// JSON representation for the [`Substitute`].
  @override
  String toString() => jsonEncode(toJson());

  @override
  bool operator ==(Object other) => other is Substitute && _deepCompare(other);

  bool _deepCompare(Substitute other) => id == other.id
      && date == other.date
      && description == other.description
      && teacher == other.teacher
      && subject == other.subject
      && room == other.room
      && kind == other.kind
      && day == other.day
      && hours.difference(other.hours).isEmpty && hours.length == other.hours.length
      && state == other.state;

  @override
  int get hashCode => Object.hash(id, date, description, teacher, subject, room, kind, day, hours, state);

  String formatByKind() {
    switch (kind) {
      case _cancelled:
        return 'cancelled';
      case _bookableChange:
        return '${'bookable change'} => $room';
      case _substitution:
        return '${'substitution'} => $teacher|$room';
      case _event:
      case _additional:
        return '$kind ($description)';
      default:
        return '$kind ($subject: $teacher|$room)';
    }
  }

  String toReadableString() => '${'Lesson'} ${hours.map((e) => e.name).join('+')} ($subject): ${formatByKind()}';

  bool subjectHourEquality(Object other) => other is Substitute && subjectHourComparison(other) == 0;

  int subjectHourComparison(Substitute o) {
    int d = date.compareTo(o.date);
    Time selfFirst = hours.isNotEmpty ? hours.first : Time(-99999, '');
    Time otherFirst = o.hours.isNotEmpty ? o.hours.first : Time(-99999, '');
    // if the dates AND the lessons are the same, return 0, since 'they are the same'
    return d == 0 && subject != o.subject ? selfFirst.compareTo(otherFirst) : d;
  }
}