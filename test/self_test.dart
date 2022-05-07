import 'dart:collection';

import 'package:better_sdui_push_notification/sdui_protocol/self.dart';
import 'package:test/test.dart';

void main() {
  test('ser/de data', () {
    final s = Self('a b', 1, 'g');
    expect(Self.fromJson(s.toJson()), equals(s));
  });
  test('from sdui json', () =>
      expect(
          Self.fromSduiJson(<String, dynamic>{
            'firstname': 'a',
            'lastname': 'b',
            'grade': <String, dynamic> {
              'shortcut': 'g'
            },
            'id': 1
          }),
          equals(Self('a b', 1, 'g'))
      )
  );
  test('bad data => exception', () =>
      expect(
          () => Self.fromSduiJson(<String, dynamic>{
            'firstname': 0,
            'lastname': false,
            'grade': <String, dynamic> {
              'shortcut': null
            },
            'id': ['true']
          }),
          throwsA(anything)
      )
  );
}