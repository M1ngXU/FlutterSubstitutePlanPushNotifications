import 'package:better_sdui_push_notification/sdui_protocol/last_upload.dart';
import 'package:test/test.dart';

void main() {
  test('from sdui json', () =>
      expect(
          lastUpload(<String, dynamic>{'Last-Uploaded': '2022-02-02 02:02:02'}),
          equals(DateTime(2022, 2, 2, 2, 2, 2))
      )
  );
  group('bad data => return now', () {
    test('wrong format', () => expect(
        lastUpload(<String, dynamic>{'Last-Uploaded': '2f22-02-02 02:02:02'})
            .difference(DateTime.now())
            .inSeconds,
        lessThan(60)
    ));
    test('no `Last-Uploaded`', () => expect(
        lastUpload(<String, dynamic>{})
            .difference(DateTime.now())
            .inSeconds,
        lessThan(60)
    ));
  });
}