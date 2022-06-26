import 'dart:ui';

import 'package:substitute_plan_push_notifications/cache/manager.dart';
import 'package:substitute_plan_push_notifications/manager.dart';
import 'package:substitute_plan_push_notifications/substitute/manager.dart';
import 'package:substitute_plan_push_notifications/substitute/substitute.dart';
import 'package:declarative_refresh_indicator/declarative_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';

import '../generated/l10n.dart';
import '../util.dart';

class SubstituteScreen extends StatefulWidget {
  const SubstituteScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SubstituteScreenState();
}

class _SubstituteScreenState extends State<SubstituteScreen> {
  List<Substitute> _substitutes = [
    /* mock data
    Substitute.createDummy(kind: 'CANCLED', subject: '3d1', hours: doubleTreeSet(Time(3, '3', DateTime(0, 0, 0, 9, 35), DateTime(0, 0, 0, 10, 20)), Time(4, '4', DateTime(0, 0, 0, 10, 25), DateTime(0, 0, 0, 11, 10))), date: DateTime(2022, 5, 9).millisecondsSinceEpoch),
    Substitute.createDummy(kind: 'BOOKABLE_CHANGE', rooms: ['1234'], subject: '5M1', hours: singleTreeSet(Time(5, '5', DateTime(0, 0, 0, 11, 25), DateTime(0, 0, 0, 12, 10))), date: DateTime(2022, 5, 9).millisecondsSinceEpoch),
    Substitute.createDummy(kind: 'SUBSTITUTION', rooms: ['1234'], teachers: ['AM', 'FRANK'], subject: '3f1', hours: singleTreeSet(Time(6, '6', DateTime(0, 0, 0, 12, 15), DateTime(0, 0, 0, 13, 0))), date: DateTime(2022, 5, 9).millisecondsSinceEpoch),
    Substitute.createDummy(kind: 'CANCLED', subject: '3d1', hours: doubleTreeSet(Time(3, '3', DateTime(0, 0, 0, 9, 35), DateTime(0, 0, 0, 10, 20)), Time(4, '4', DateTime(0, 0, 0, 10, 20), DateTime(0, 0, 0, 11, 10))), date: DateTime(2022, 5, 16).millisecondsSinceEpoch),
    Substitute.createDummy(kind: 'BOOKABLE_CHANGE', rooms: ['1234'], subject: '5M1', hours: singleTreeSet(Time(5, '5', DateTime(0, 0, 0, 11, 25), DateTime(0, 0, 0, 12, 10))), date: DateTime(2022, 5, 16).millisecondsSinceEpoch),
    Substitute.createDummy(kind: 'SUBSTITUTION', rooms: ['1234'], teachers: ['AM', 'FRANK'], subject: '3f1', hours: singleTreeSet(Time(6, '6', DateTime(0, 0, 0, 12, 15), DateTime(0, 0, 0, 13, 0))), date: DateTime(2022, 5, 9).millisecondsSinceEpoch),
    Substitute.createDummy(kind: 'CANCLED', subject: '3d1', hours: doubleTreeSet(Time(3, '3', DateTime(0, 0, 0, 9, 35), DateTime(0, 0, 0, 10, 20)), Time(4, '4', DateTime(0, 0, 0, 10, 25), DateTime(0, 0, 0, 11, 10))), date: DateTime(2022, 5, 16).millisecondsSinceEpoch),
    Substitute.createDummy(kind: 'BOOKABLE_CHANGE', rooms: ['1234'], subject: '5M1', hours: singleTreeSet(Time(5, '5', DateTime(0, 0, 0, 11, 25), DateTime(0, 0, 0, 12, 10))), date: DateTime(2022, 5, 16).millisecondsSinceEpoch),
    Substitute.createDummy(kind: 'SUBSTITUTION', rooms: ['1234'], teachers: ['AM', 'FRANK'], subject: '3f1', hours: singleTreeSet(Time(6, '6', DateTime(0, 0, 0, 12, 15), DateTime(0, 0, 0, 13, 0))), date: DateTime(2022, 5, 9).millisecondsSinceEpoch),
    Substitute.createDummy(kind: 'EVENT', description: 'Ferien!', hours: singleTreeSet(Time(0, 'ALL DAY', DateTime(0), DateTime(0, 0, 0, 23, 59))), date: DateTime(2022, 5, 12).millisecondsSinceEpoch),
    Substitute.createDummy(kind: 'ADDITIONAL', subject: '2geo4', description: 'Klausur 1/2', hours: doubleTreeSet(Time(8, '8', DateTime(0, 0, 0, 13, 55), DateTime(0, 0, 0, 14, 40)), Time(9, '9', DateTime(0, 0, 0, 14, 45), DateTime(0, 0, 0, 15, 30))), date: DateTime(2022, 5, 12).millisecondsSinceEpoch),
     */
  ];
  bool _refreshing = false;

  _SubstituteScreenState();

  DateFormat get _timeFormatter => DateFormat.jm(CacheManager.singleton.dateLocale);

  _setSubstitutes(CacheManager m) => setState(() => _substitutes = m.substitutes);
  _setRefreshing(Manager m) => _refreshing = m.refreshing;

  @override
  void initState() {
    CacheManager.getInstance().then((m) {
      _setSubstitutes(m);
      m.onSubstituteChangedCallback.putIfAbsent(hashCode, putIfAbsent(m, _setSubstitutes));
    });
    Manager.createOrGetInstance().then((m) {
      _setRefreshing(m);
      m.onRefreshingChangedCallback.putIfAbsent(hashCode, putIfAbsent(m, _setRefreshing));
    });
    super.initState();
  }

  @override
  void dispose() {
    CacheManager.singleton.onSubstituteChangedCallback.remove(hashCode);
    Manager.singleton.onRefreshingChangedCallback.remove(hashCode);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(
      child: DeclarativeRefreshIndicator(
          refreshing: _refreshing,
          triggerMode: RefreshIndicatorTriggerMode.anywhere,
          child: _substitutes.isNotEmpty ? StickyGroupedListView(
              physics: const AlwaysScrollableScrollPhysics(),
              floatingHeader: true,
              elements: sortSubstitutes(_substitutes).values.expand((e) => e).toList(),
              groupBy: (Substitute e) => e.date,
              groupSeparatorBuilder: (Substitute e) => SizedBox(
                height: 50,
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[300],
                      border: Border.all(
                        color: Colors.blue[300]!,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                      child: Text(e.formattedDate, textAlign: TextAlign.center),
                    ),
                  ),
                ),
              ),
              itemBuilder: (context, Substitute e) => Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
                elevation: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  leading: Icon(e.icon(context)),
                  title: Text(e.toReadableString()),
                  trailing: Text(e.getTimeRangeString(context, _timeFormatter),
                    style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
                    textAlign: TextAlign.right,
                  ),
                  textColor: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : null,
                  tileColor: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.black87 : null,
                  iconColor: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : null,
                ),
              ),
              itemComparator: (Substitute e1, Substitute e2) => e1.subjectHourComparison(e2)
          ) : ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [Center(child: Text(S.of(context).noSubstitutes, style: Theme.of(context).textTheme.titleLarge))]
          ),
          onRefresh: () => Manager.singleton.refresh(force: true)
      )
  );
}