import 'dart:collection';

import 'package:substitute_plan_push_notifications/substitute/substitute.dart';
import 'package:quiver/collection.dart';

/// sets all the states
/// returns a reference to the current substitute list for better chaining
List<Substitute> updateSubstituteList(List<Substitute> old, List<Substitute> cur) {
  for (var substitute in cur) {
    try {
      substitute.state = old.firstWhere((other) => substitute.id == other.id) == substitute ? SubstituteState.noChange : SubstituteState.modified;
    } catch(e) {
      substitute.state = SubstituteState.added;
    }
  }
  for (var substitute in old) {
    try {
      cur.firstWhere((other) => substitute.id == other.id);
    } catch(_) {
      substitute.state = substitute.date.isBefore(DateTime.now())
          ? SubstituteState.expired : SubstituteState.removed;
      cur.add(substitute);
    }
  }
  return cur;
}

typedef SortedSubstitutes = SplayTreeMap<DateTime, TreeSet<Substitute>>; 
SortedSubstitutes sortSubstitutes(List<Substitute> substitutes) {
  SortedSubstitutes s = SortedSubstitutes();
  for (var substitute in substitutes) {
    var date = s.putIfAbsent(substitute.date, () => TreeSet<Substitute>(comparator: (a, b) => a.subjectHourComparison(b)));
    // whole day like mdl abitur?
    if (substitute.hours.first.order == -1 && !substitute.isExam) {
      date.clear();
    }
    try {
      var d = date.firstWhere((sub) => sub.subjectHourEquality(substitute));
      if (substitute.kind == event) {
        d.kind = event;
        if (d.comment.isEmpty) d.comment = substitute.comment;
      }
      d.hours.addAll(substitute.hours);
    } catch(_) {
      if (date.isEmpty || date.first.hours.first.order != -1 || substitute.isExam) date.add(substitute);
    }
  }
  return s;
}