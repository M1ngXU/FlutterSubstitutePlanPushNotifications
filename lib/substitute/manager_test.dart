import 'package:better_sdui_push_notification/substitute/manager.dart';
import 'package:better_sdui_push_notification/substitute/substitute.dart';
import 'package:better_sdui_push_notification/substitute/time.dart';
import 'package:quiver/collection.dart';
import 'package:test/test.dart';

import '../util.dart';

void main() {
  group('update substitute list', () {
    test('old is empty, added', () {
      var s = [Substitute.createDummy()];
      updateSubstituteList([], s);
      expect(s.length, equals(1));
      expect(s[0].state, equals(SubstituteState.added));
    });

    test('new is empty, removed', () {
      var o = [Substitute.createDummy(date: DateTime.now().add(const Duration(days: 999)).millisecondsSinceEpoch)];
      List<Substitute> s = [];
      updateSubstituteList(o, s);
      expect(s.length, equals(1));
      expect(s[0].state, equals(SubstituteState.removed));
      expect(s[0], equals(o[0]));
    });

    test('different element, modified', () {
      var o = [Substitute.createDummy(date: 0, subject: 'CB')];
      List<Substitute> s = [Substitute.createDummy(date: 0, subject: 'AD')];
      updateSubstituteList(o, s);
      expect(s.length, equals(1));
      expect(s[0].state, equals(SubstituteState.modified));
    });

    test('same element, noChange', () {
      var o = [Substitute.createDummy()];
      List<Substitute> s = [Substitute.createDummy()];
      updateSubstituteList(o, s);
      expect(s.length, equals(1));
      expect(s[0].state, equals(SubstituteState.noChange));
    });

    test('`complex`, multiple substitutes', () {
      // using microseconds to get date in future
      var o = [
        Substitute.createDummy(id: 'a', subject: 'b', date: DateTime.now().microsecondsSinceEpoch),
        Substitute.createDummy(id: 'b', room: 'a', date: DateTime.now().microsecondsSinceEpoch),
        Substitute.createDummy(id: 'c', teacher: 'd', date: DateTime.now().microsecondsSinceEpoch),
      ];
      var s = [
        Substitute.createDummy(id: 'b', room: 'a', date: DateTime.now().microsecondsSinceEpoch),
        Substitute.createDummy(id: 'c', teacher: 'f', date: DateTime.now().microsecondsSinceEpoch),
        Substitute.createDummy(id: 'd', teacher: 'd', date: DateTime.now().microsecondsSinceEpoch),
      ];
      updateSubstituteList(o, s);
      expect(s.length, equals(4));
      expect(s[0].state, equals(SubstituteState.noChange));
      expect(s[1].state, equals(SubstituteState.modified));
      expect(s[2].state, equals(SubstituteState.added));
      expect(s[3].state, equals(SubstituteState.removed));
      expect(s[3], equals(o[0]));
    });
  });
  
  group('sort substitutes', () {
    test('different dates', () {
      var d0 = DateTime(2022, 1, 1);
      var d1 = DateTime(2022, 1, 2);
      var d2 = DateTime(2022, 1, 3);
      var s0 = Substitute.createDummy(date: d0.millisecondsSinceEpoch);
      var s1 = Substitute.createDummy(date: d1.millisecondsSinceEpoch);
      var s2 = Substitute.createDummy(date: d2.millisecondsSinceEpoch);
      var res = sortSubstitutes([s0, s1, s2]);
      expect(res.length, equals(3));
      expect(res[d0], equals(singleTreeSet(s0)));
      expect(res[d1], equals(singleTreeSet(s1)));
      expect(res[d2], equals(singleTreeSet(s2)));
    });

    test('same date, partially different subjects', () {
      var d = DateTime(2022, 1, 1);
      var s0 = Substitute.createDummy(date: d.millisecondsSinceEpoch, subject: "a", hours: singleTreeSet(Time(0, "0")));
      var s1 = Substitute.createDummy(date: d.millisecondsSinceEpoch, subject: "b", hours: singleTreeSet(Time(1, "1")));
      var s2 = Substitute.createDummy(date: d.millisecondsSinceEpoch, subject: "b", hours: singleTreeSet(Time(4, "3")));
      var s3 = Substitute.createDummy(date: d.millisecondsSinceEpoch, subject: "c", hours: singleTreeSet(Time(5, "4")));
      var res = sortSubstitutes([s0, s1, s2, s3]);
      expect(res.length, equals(1));
      expect(res[d]!.length, equals(3));
      expect(res[d]!.first, equals(s0));
      expect(res[d]!.skip(1).first, equals(Substitute.createDummy(date: d.millisecondsSinceEpoch, subject: "b", hours: doubleTreeSet(Time(1, "1"), Time(4, "3")))));
      expect(res[d]!.last, equals(s3));
    });
  });
}