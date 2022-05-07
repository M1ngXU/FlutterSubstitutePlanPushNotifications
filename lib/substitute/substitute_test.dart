import 'dart:collection';

import 'package:better_sdui_push_notification/substitute/substitute.dart';
import 'package:better_sdui_push_notification/substitute/time.dart';
import 'package:better_sdui_push_notification/util.dart';
import 'package:quiver/collection.dart';
import 'package:test/test.dart';

void main() {
  test('To Json', () => expect(Substitute.fromJson(Substitute.createDummy().toJson()), equals(Substitute.createDummy())));

  group('format by kind', () {
    test('Cancelled', () => expect(Substitute.createDummy(kind: 'CANCLED').formatByKind(), equals('cancelled')));
    test('Bookable change', () => expect(Substitute.createDummy(kind: 'BOOKABLE_CHANGE', room: '123').formatByKind(), equals('bookable change => 123')));
    test('Substitution', () => expect(Substitute.createDummy(kind: 'SUBSTITUTION', room: '123', teacher: 'AB').formatByKind(), equals('substitution => AB|123')));
    test('Additional', () => expect(Substitute.createDummy(kind: 'ADDITIONAL', description: 'desc').formatByKind(), equals('ADDITIONAL (desc)')));
    test('Event', () => expect(Substitute.createDummy(kind: 'EVENT', description: 'desc').formatByKind(), equals('EVENT (desc)')));
    test('Unknown', () => expect(Substitute.createDummy(kind: 'UNKNOWN', room: '123', teacher: 'AB', subject: 'CD').formatByKind(), equals('UNKNOWN (CD: AB|123)')));
  });

  test('to readable string', () {
    Substitute s = Substitute.createDummy(kind: 'UNKNOWN', room: '123', teacher: 'AB', subject: 'CD');
    expect(s.toReadableString(), equals('Lesson 1+4 (CD): ${s.formatByKind()}'));
  });

  group('subject hour equality/comparison', () {
    test('only subject/date same', () =>
      expect(
          Substitute.createDummy(subject: 'AB', description: 'AB', teacher: 'EF', room: 'FD', kind: 'C3', day: 0, date: 0, state: SubstituteState.removed)
              .subjectHourEquality(Substitute.createDummy(subject: 'AB', description: 'CD', teacher: 'CD', room: 'FQ', kind: 'AJ', day: 1, hours: TreeSet<Time>(), date: 0, state: SubstituteState.added)
          ),
          equals(true)
      )
    );
    test('different subject', () => expect(Substitute.createDummy(subject: 'AC').subjectHourEquality(Substitute.createDummy(subject: 'AB', hours: TreeSet<Time>())), equals(false)));
    test('same subject, date within 24 hours', () => expect(Substitute.createDummy(date: 0).subjectHourEquality(Substitute.createDummy(date: 1)), equals(true)));
    test('same subject, date diff > 24 hours', () => expect(Substitute.createDummy(date: 0).subjectHourEquality(Substitute.createDummy(date: 1000 * 60 * 60 * 24 + 1)), equals(false)));
  });

  group('from sdui json', () {
    test('single event', () => expect(Substitute.fromSduiJson(<String, dynamic> {
      'id': 'a',
      'dates': [12345678999],
      'description': 'b',
      'grades': [<String, dynamic>{'shortcut':'g'}],
      'teachers': [<String, dynamic> {'shortcut': 'c'}],
      'course': <String, dynamic> {'meta': <String, dynamic> {'shortname': 'd'}},
      'bookables': [<String, dynamic> {'shortcut': 'e'}],
      'kind': 'EVENT',
      'day': 6,
      'time_id': 't1'
    }, HashMap.from(<String, Time> {
      't1': Time(1, '1')
    }), 'g'), equals([Substitute.createDummy(id: 'a', date: 12345678999000, description: 'b', teacher: 'c', subject: 'd', room: 'e', kind: 'EVENT', day: 6, hours: singleTreeSet(Time(1, '1')), state: null)])));

    test('`substituted_target_lessons` only, with some in the past, also different times', () =>
        expect(
            Substitute.fromSduiJson(<String, dynamic> {
              'substituted_target_lessons': [<String, dynamic>{
                'id': 'a',
                'dates': [12345678999, 1234],
                'description': 'b',
                'grades': [<String, dynamic>{'shortcut':'g'}],
                'teachers': [<String, dynamic>{'shortcut': 'c'}],
                'course': <String, dynamic>{
                  'meta': <String, dynamic>{'shortname': 'd'}
                },
                'bookables': [<String, dynamic>{'shortcut': 'e'}],
                'kind': 'ADDITIONAL',
                'day': 6,
                'time_id': 't1'
              }, <String, dynamic>{
                'id': 'b',
                'dates': [0, 99999999999],
                'description': 'b',
                'grades': [<String, dynamic>{'shortcut':'g'}, <String, dynamic>{'shortcut':'c'}],
                'teachers': [<String, dynamic>{'shortcut': 'c'}],
                'course': <String, dynamic>{
                  'meta': <String, dynamic>{'shortname': 'd'}
                },
                'bookables': [<String, dynamic>{'shortcut': 'e'}],
                'kind': 'SUBSTITUTION',
                'day': 1,
                'time_id': 't2'
              }]
            }, HashMap.from(<String, Time> {
              't1': Time(1, '1'),
              't2': Time(3, '2')
            }), 'g'),
            equals([
              Substitute.createDummy(id: 'a', date: 12345678999000, description: 'b', teacher: 'c', subject: 'd', room: 'e', kind: 'ADDITIONAL', day: 6, hours: singleTreeSet(Time(1, '1')), state: null),
              Substitute.createDummy(id: 'b', date: 99999999999000, description: 'b', teacher: 'c', subject: 'd', room: 'e', kind: 'SUBSTITUTION', day: 1, hours: singleTreeSet(Time(3, '2')), state: null)
            ])
        )
    );

    test('wrong grades', () =>
        expect(
            Substitute.fromSduiJson(<String, dynamic> {
              'substituted_target_lessons': [<String, dynamic>{
                'id': 'a',
                'dates': [12345678999],
                'description': 'b',
                'grades': [<String, dynamic>{'shortcut':'c'}, <String, dynamic>{'shortcut':'b'}],
                'teachers': [<String, dynamic>{'shortcut': 'c'}],
                'course': <String, dynamic>{
                  'meta': <String, dynamic>{'shortname': 'd'}
                },
                'bookables': [<String, dynamic>{'shortcut': 'e'}],
                'kind': 'ADDITIONAL',
                'day': 6,
                'time_id': 't1'
              }, <String, dynamic>{
                'id': 'b',
                'dates': [99999999999],
                'description': 'b',
                'grades': [<String, dynamic>{'shortcut':'d'}],
                'teachers': [<String, dynamic>{'shortcut': 'c'}],
                'course': <String, dynamic>{
                  'meta': <String, dynamic>{'shortname': 'd'}
                },
                'bookables': [<String, dynamic>{'shortcut': 'e'}],
                'kind': 'SUBSTITUTION',
                'day': 1
              }]
            }, HashMap.from(<String, Time> {
              't1': Time(1, '1')
            }), 'g'),
            equals([])
        )
    );

    test('only cancelled + bookable_change can get teacher from parent, unknown time_id => ALL DAY', () =>
        expect(
            Substitute.fromSduiJson(<String, dynamic> {
              'dates': [99999999999],
              'kind': null,
              'grades': [<String, dynamic>{'shortcut':'g'}],
              'teachers': [<String, dynamic>{'shortcut': 'cd'}],
              'substituted_target_lessons': [<String, dynamic>{
                'id': 'a',
                'dates': [99999999999],
                'description': 'b',
                'teachers': null,
                'grades': [<String, dynamic>{'shortcut':'g'}],
                'course': <String, dynamic>{
                  'meta': <String, dynamic>{'shortname': 'd'}
                },
                'bookables': [<String, dynamic>{'shortcut': 'e'}],
                'kind': 'CANCLED',
                'day': 6,
                'time_id': 't1'
              }, <String, dynamic>{
                'id': 'b',
                'grades': [<String, dynamic>{'shortcut':'g'}],
                'dates': [0, 99999999999],
                'description': 'b',
                'teachers': null,
                'course': <String, dynamic>{
                  'meta': <String, dynamic>{'shortname': 'd'}
                },
                'bookables': [<String, dynamic>{'shortcut': 'e'}],
                'kind': 'BOOKABLE_CHANGE',
                'day': 1
              }, <String, dynamic>{
                'id': 'c',
                'dates': [0, 99999999999],
                'description': 'b',
                'grades': [<String, dynamic>{'shortcut':'g'}],
                'teachers': null,
                'course': <String, dynamic>{
                  'meta': <String, dynamic>{'shortname': 'd'}
                },
                'bookables': [<String, dynamic>{'shortcut': 'e'}],
                'kind': 'EVENT',
                'day': 1,
                'time_id': 'dfa'
              }]
            }, HashMap.from(<String, Time> {
              't1': Time(1, '1'),
            }), 'g'),
            equals([
              Substitute.createDummy(id: 'a', date: 99999999999000, description: 'b', teacher: 'cd', subject: 'd', room: 'e', kind: 'CANCLED', day: 6, hours: singleTreeSet(Time(1, '1')), state: null),
              Substitute.createDummy(id: 'b', date: 99999999999000, description: 'b', teacher: 'cd', subject: 'd', room: 'e', kind: 'BOOKABLE_CHANGE', day: 1, hours: singleTreeSet(Time(0, 'ALL DAY')), state: null),
              Substitute.createDummy(id: 'c', date: 99999999999000, description: 'b', teacher: '', subject: 'd', room: 'e', kind: 'EVENT', day: 1, hours: singleTreeSet(Time(0, 'ALL DAY')), state: null)
            ])
        )
    );
  });
}