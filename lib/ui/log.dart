import 'package:substitute_plan_push_notifications/cache/logger.dart';
import 'package:substitute_plan_push_notifications/cache/manager.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';

import '../generated/l10n.dart';
import '../util.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  List<Log> logs = [];
  final Map<LogType, bool> _logTypeEnabled = Map.fromEntries(LogType.values.map((e) => MapEntry(e, true)));

  _LogScreenState();

  _setLogs() => setState(() => logs = Logger.singleton.logs);

  @override
  void initState() {
    Logger.singleton.onLogsChanged.putIfAbsent(hashCode, () => _setLogs);
    _setLogs();
    super.initState();
  }

  @override
  void dispose() {
    Logger.singleton.onLogsChanged.remove(hashCode);
    super.dispose();
  }

  Widget _getFilterButton(LogType lt) => IconButton(
      icon: Icon(lt.getIconData(), color: _logTypeEnabled[lt]! ? lt.getColor() : const Color.fromRGBO(128, 128, 128, 0.3)),
      onPressed: () => setState(() => _logTypeEnabled[lt] = !_logTypeEnabled[lt]!),
      tooltip: lt.name[0].toUpperCase() + lt.name.substring(1),
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                      tooltip: S.of(context).clearLogs,
                      onPressed: () => showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) => AlertDialog(
                          title: Text('${S.of(context).deleteLogs} (${(Logger.logLength() / 100).floor() / 10} KB)'),
                          content: Text(S.of(context).irreversibleDeletingLogs),
                          actions: <Widget>[
                            TextButton(
                              child: Text(S.of(context).cancel),
                              onPressed: () => Navigator.of(context).pop()
                            ),
                            TextButton(
                              child: Text(S.of(context).delete),
                              onPressed: () {
                                Navigator.of(context).pop();
                                Logger.clearLogs();
                              },
                            ),
                          ],
                        )
                      ),
                      icon: const Icon(Icons.delete_outline_outlined)
                  )
                ].followedBy(LogType.values.map((lt) => _getFilterButton(lt))).toList()
            ),
            Expanded(child: logs.isNotEmpty ? StickyGroupedListView(
              shrinkWrap: true,
              floatingHeader: true,
              elements: logs.where((l) => _logTypeEnabled[l.type]!).toList(),
              order: StickyGroupedListOrder.DESC,
              groupBy: (Log l) => l.time.stripSeconds(),
              groupSeparatorBuilder: (Log l) => SizedBox(
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
                        DateFormat.Hm(CacheManager.singleton.dateLocale).addPattern(', ', '').add_yMd().format(l.time),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              itemBuilder: (context, Log l) => Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
                elevation: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  leading: l.type.getIcon(),
                  title: ExpandableNotifier(
                      child: ScrollOnExpand(
                          child: ExpandablePanel(
                            collapsed: ExpandableButton(child: Text(l.content, maxLines: 2, overflow: TextOverflow.ellipsis,)),
                            expanded: ExpandableButton(child: Text(l.content)),
                          )
                      )
                  ),
                  trailing: l.time.formattedDateTimeText(),
                ),
              ),
            ) : Center(child: Text(S.of(context).noLogs, style: Theme.of(context).textTheme.titleLarge,)))
          ]
      ),
    );
  }
}