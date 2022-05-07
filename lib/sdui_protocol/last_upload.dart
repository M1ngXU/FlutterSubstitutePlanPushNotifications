import 'dart:developer';

import 'package:better_sdui_push_notification/util.dart';
import 'package:intl/intl.dart';

DateTime lastUpload(JsonObject json) {
  String? lastUploaded = castOr(json['Last-Uploaded'], null);
  if (lastUploaded != null) {
    try {
      return DateFormat('yyyy-MM-dd hh:mm:ss').parse(lastUploaded);
    } catch (e, s) {
      log('Failed to format `Last-Uploaded: $lastUploaded`. ($e)\n$s');
    }
  }
  return DateTime.now();
}