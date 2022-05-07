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
    test('Bookable change', () => expect(Substitute.createDummy(kind: 'BOOKABLE_CHANGE', rooms: ['123', '456']).formatByKind(), equals('bookable change => 123+456')));
    test('Substitution', () => expect(Substitute.createDummy(kind: 'SUBSTITUTION', rooms: ['123'], teachers: ['AB', 'BC']).formatByKind(), equals('substitution => AB+BC|123')));
    test('Additional', () => expect(Substitute.createDummy(kind: 'ADDITIONAL', description: 'desc').formatByKind(), equals('ADDITIONAL (desc)')));
    test('Event', () => expect(Substitute.createDummy(kind: 'EVENT', description: 'desc').formatByKind(), equals('EVENT (desc)')));
    test('Unknown', () => expect(Substitute.createDummy(kind: 'UNKNOWN', rooms: ['123', '678'], teachers: ['AB', 'cd'], subject: 'CD').formatByKind(), equals('UNKNOWN (CD: AB+cd|123+678)')));
  });

  test('to readable string', () {
    Substitute s = Substitute.createDummy(kind: 'UNKNOWN', rooms: ['123'], teachers: ['AB'], subject: 'CD');
    expect(s.toReadableString(), equals('Lesson 1+4 (CD): ${s.formatByKind()}'));
  });

  group('subject hour equality/comparison', () {
    test('only subject/date same', () =>
      expect(
          Substitute.createDummy(subject: 'AB', description: 'AB', teachers: ['EF'], rooms: ['FD'], kind: 'C3', day: 0, date: 0, state: SubstituteState.removed)
              .subjectHourEquality(Substitute.createDummy(subject: 'AB', description: 'CD', teachers: ['CD'], rooms: ['FQ'], kind: 'AJ', day: 1, hours: TreeSet<Time>(), date: 0, state: SubstituteState.added)
          ),
          isTrue
      )
    );
    test('different subject', () => expect(Substitute.createDummy(subject: 'AC').subjectHourEquality(Substitute.createDummy(subject: 'AB', hours: TreeSet<Time>())), equals(false)));
    test('same subject, date within 24 hours', () => expect(Substitute.createDummy(date: 0).subjectHourEquality(Substitute.createDummy(date: 1)), isTrue));
    test('same subject, date diff > 24 hours', () => expect(Substitute.createDummy(date: 0).subjectHourEquality(Substitute.createDummy(date: 1000 * 60 * 60 * 24 + 1)), equals(false)));
  });

  group('from sdui json', () {
    test('single event, unknown time_id => ALL DAY', () => expect(Substitute.fromSduiJson(<String, dynamic> {
      'id': 'a',
      'dates': [12345678999],
      'description': 'b',
      'grades': [<String, dynamic>{'shortcut':'g'}],
      'teachers': [<String, dynamic> {'shortcut': 'c'}],
      'course': <String, dynamic> {'meta': <String, dynamic> {'shortname': 'd'}},
      'bookables': [<String, dynamic> {'shortcut': 'e'}, <String, dynamic> {'shortcut': 'd'}],
      'kind': 'EVENT',
      'day': 6,
      'time_id': 't1'
    }, HashMap(), 'g'), equals([Substitute.createDummy(id: 'a', date: 12345678999000, description: 'b', teachers: ['c'], subject: 'd', rooms: ['e', 'd'], kind: 'EVENT', day: 6, hours: singleTreeSet(Time(0, 'ALL DAY')), state: null)])));

    test('`substituted_target_lessons` only, with some in the past, also different times, no time_id', () =>
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
                'teachers': [<String, dynamic>{'shortcut': 'c'}, <String, dynamic>{'shortcut': 'e'}],
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
              Substitute.createDummy(id: 'a', date: 12345678999000, description: 'b', teachers: ['c'], subject: 'd', rooms: ['e'], kind: 'ADDITIONAL', day: 6, hours: singleTreeSet(Time(1, '1')), state: null),
              Substitute.createDummy(id: 'b', date: 99999999999000, description: 'b', teachers: ['c', 'e'], subject: 'd', rooms: ['e'], kind: 'SUBSTITUTION', day: 1, hours: singleTreeSet(Time(3, '2')), state: null)
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
            isEmpty
        )
    );

    test('only cancelled + bookable_change can get teacher from parent, cancelled gets bookable from parent, no time_id => ALL DAY', () =>
        expect(
            Substitute.fromSduiJson(<String, dynamic> {
              'dates': [99999999999],
              'kind': null,
              'grades': [<String, dynamic>{'shortcut':'g'}],
              'teachers': [<String, dynamic>{'shortcut': 'cd'}, <String, dynamic>{'shortcut': 'ef'}],
              'bookables': [<String, dynamic>{'shortcut': 'e'}, <String, dynamic>{'shortcut': 'f'}],
              'substituted_target_lessons': [<String, dynamic>{
                'id': 'a',
                'dates': [99999999999],
                'description': 'b',
                'teachers': null,
                'grades': [<String, dynamic>{'shortcut':'g'}],
                'course': <String, dynamic>{
                  'meta': <String, dynamic>{'shortname': 'd'}
                },
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
                'kind': 'BOOKABLE_CHANGE',
                'day': 1,
                'time_id': 't1'
              }, <String, dynamic>{
                'id': 'c',
                'dates': [0, 99999999999],
                'description': 'b',
                'grades': [<String, dynamic>{'shortcut':'g'}],
                'teachers': null,
                'course': <String, dynamic>{
                  'meta': <String, dynamic>{'shortname': 'd'}
                },
                'kind': 'EVENT',
                'day': 1
              }]
            }, HashMap.from(<String, Time> {
              't1': Time(1, '1'),
            }), 'g'),
            equals([
              Substitute.createDummy(id: 'a', date: 99999999999000, description: 'b', teachers: ['cd', 'ef'], subject: 'd', rooms: ['e', 'f'], kind: 'CANCLED', day: 6, hours: singleTreeSet(Time(1, '1')), state: null),
              Substitute.createDummy(id: 'b', date: 99999999999000, description: 'b', teachers: ['cd', 'ef'], subject: 'd', rooms: List<String>.empty(), kind: 'BOOKABLE_CHANGE', day: 1, hours: singleTreeSet(Time(1, '1')), state: null),
              Substitute.createDummy(id: 'c', date: 99999999999000, description: 'b', teachers: List<String>.empty(), subject: 'd', rooms: List<String>.empty(), kind: 'EVENT', day: 1, hours: singleTreeSet(Time(0, 'ALL DAY')), state: null)
            ])
        )
    );

    group('random data, no exception', () {
      test('invalid kind', () =>
          expect(() =>
              Substitute.fromSduiJson(
                  <String, dynamic>{'kind': false}, HashMap(), 'g'
              ),
              returnsNormally
          )
      );
      test('invalid grade', () =>
          expect(() =>
              Substitute.fromSduiJson(
                  <String, dynamic>{'kind': 'some', 'grades': false}, HashMap(), 'g'
              ),
              returnsNormally
          )
      );
      test('invalid date', () =>
          expect(() =>
              Substitute.fromSduiJson(
                  <String, dynamic>{'kind': 'some', 'grades': [<String, dynamic>{'shortcut': 'g'}], 'dates': [null]}, HashMap(), 'g'
              ),
              returnsNormally
          )
      );
      test('rest invalid', () =>
          expect(
              () => Substitute.fromSduiJson(<String, dynamic>{
                'id': 643,
                'dates': [12345678999],
                'description': 'b',
                'grades': [<String, dynamic>{'shortcut': 'g'}],
                'teachers': 1,
                'course': [<String, dynamic>{'meta': <String, dynamic>{'shortname': 'd'}}],
                'bookables': false,
                'kind': 'f',
                'day': null,
                'time_id': 90
              }, HashMap(), 'g'),
              returnsNormally
          )
      );
    });
  });
}