import 'dart:ui';

import 'package:better_sdui_push_notification/cache/manager.dart';
import 'package:better_sdui_push_notification/manager.dart';
import 'package:better_sdui_push_notification/substitute/manager.dart';
import 'package:better_sdui_push_notification/substitute/substitute.dart';
import 'package:better_sdui_push_notification/util.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';

import '../substitute/time.dart';

class SubstituteUIState extends StatefulWidget {
  const SubstituteUIState({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SubstituteUI();
}

class SubstituteUI extends State<SubstituteUIState> {
  List<Substitute> _substitutes = [
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
  ];

  SubstituteUI();

  DateFormat _getTimeFormatter(BuildContext context) => DateFormat.jm(_tryGetLocale(context));
  String? _tryGetLocale(BuildContext context) => Localizations.maybeLocaleOf(context)?.toLanguageTag();

  @override
  void initState() {
    initializeDateFormatting();
    CacheManager.getInstance().then((m) => m.cache.onSubstituteChangeCallback.add((s) => setState(() => _substitutes = s)));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: RefreshIndicator(
            child: StickyGroupedListView(
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
                        child: Text(
                          DateFormat.MMMMEEEEd(_tryGetLocale(context)).format(e.date),
                          textAlign: TextAlign.center,
                        ),
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
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    leading: Icon(e.getIcon()),
                    title: Text(e.toReadableString()),
                    trailing: Text(e.getTimeRangeString(_getTimeFormatter(context)),
                      style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
                itemComparator: (Substitute e1, Substitute e2) => e1.subjectHourComparison(e2)
            ),
            onRefresh: () => Manager.singleton.then((m) => m.update(force: true))
        )
    );
  }
}