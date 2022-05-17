import 'package:substitute_plan_push_notifications/cache/logger.dart';
import 'package:substitute_plan_push_notifications/util.dart';
import 'package:intl/intl.dart';

DateTime lastUpload(JsonObject json) {
  String? lastUploaded = castOr(json['Last-Uploaded'], null);
  if (lastUploaded != null) {
    try {
      return DateFormat('yyyy-MM-dd hh:mm:ss').parse(lastUploaded);
    } catch (e, s) {
      Logger.e('Failed to format `Last-Uploaded: $lastUploaded`. ($e)\n$s');
    }
  }
  return DateTime.now();
}