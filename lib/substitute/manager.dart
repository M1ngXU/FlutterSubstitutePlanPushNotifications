import 'dart:collection';

import 'package:better_sdui_push_notification/substitute/substitute.dart';
import 'package:quiver/collection.dart';

/// sets all the states
void updateSubstituteList(List<Substitute> old, List<Substitute> cur) {
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
      substitute.state = SubstituteState.removed;
      cur.add(substitute);
    }
  }
}

typedef SortedSubstitutes = SplayTreeMap<DateTime, TreeSet<Substitute>>; 
SortedSubstitutes sortSubstitutes(List<Substitute> substitutes) {
  SortedSubstitutes s = SortedSubstitutes();
  for (var substitute in substitutes) {
    var date = s.putIfAbsent(substitute.date, () => TreeSet<Substitute>(comparator: (a, b) => a.subjectHourComparison(b)));
    try {
      date.firstWhere((sub) => sub.subjectHourEquality(substitute)).hours.addAll(substitute.hours);
    } catch(_) {
      date.add(substitute);
    }
  }
  return s;
}