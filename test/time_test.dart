import 'dart:collection';

import 'package:substitute_plan_push_notifications/substitute/time.dart';
import 'package:test/test.dart';

void main() {
  test('Order times', () {
    expect(Time(0, '').compareTo(Time(1, '')), -1);
    expect(Time(3, '').compareTo(Time(3, '')), 0);
    expect(Time(2, '').compareTo(Time(1, '')), 1);
  });

  test('server json to hashmap, two elements', () =>
      expect(
          Time.fromServerJson([
            <String, dynamic>{
              'begins_at': '1970-01-01T07:25:00+01:00',
              'id': 12345,
              'meta': <String, dynamic>{
                'displayname': '1'
              }
            }, <String, dynamic>{
              'begins_at': '1970-01-01T07:10:00+01:00',
              'id': 12346,
              'meta': <String, dynamic>{
                'displayname': '2'
              }
            },
          ]),
          equals(HashMap.from(<int, Time>{
            12345: Time(DateTime.parse('1970-01-01T07:25:00+01:00').millisecondsSinceEpoch, '1'),
            12346: Time(DateTime.parse('1970-01-01T07:10:00+01:00').millisecondsSinceEpoch, '2')
          }))
      )
  );

  test('bad data, no exception', () =>
    expect(
        () => Time.fromServerJson([
          <String, dynamic>{
            'begins_at': true,
            'id': ['array'],
            'meta': null
          }, <String, dynamic>{
            'begins_at': true,
            'id': ['array'],
            'meta': <String, dynamic> {
              'displayname': ['yay']
            }
          }
        ]),
        returnsNormally
    )
  );
}