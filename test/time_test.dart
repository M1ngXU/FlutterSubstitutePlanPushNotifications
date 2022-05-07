import 'package:better_sdui_push_notification/substitute/time.dart';
import 'package:test/test.dart';

void main() {
  test('Order times', () {
    expect(Time(0, '').compareTo(Time(1, '')), equals(-1));
    expect(Time(3, '').compareTo(Time(3, '')), equals(0));
    expect(Time(2, '').compareTo(Time(1, '')), equals(1));
  });
}