import 'package:flutter_test/flutter_test.dart';
import 'package:openhaystack_mobile/accessory/accessory_registry.dart';
import 'package:openhaystack_mobile/findMy/models.dart';

void main() {
  group('isValidLocationReport', () {
    test('accepts reports inside latitude and longitude bounds', () {
      final report = FindMyLocationReport(
        48.137154,
        11.576124,
        5,
        DateTime.utc(2026, 3, 11),
        null,
        null,
      );

      expect(isValidLocationReport(report), isTrue);
    });

    test('accepts boundary longitude values up to 180 degrees', () {
      final report = FindMyLocationReport(
        -12.0,
        180.0,
        5,
        DateTime.utc(2026, 3, 11),
        null,
        null,
      );

      expect(isValidLocationReport(report), isTrue);
    });

    test('rejects longitude values above 180 degrees', () {
      final report = FindMyLocationReport(
        48.137154,
        181.0,
        5,
        DateTime.utc(2026, 3, 11),
        null,
        null,
      );

      expect(isValidLocationReport(report), isFalse);
    });

    test('rejects latitude values above 90 degrees', () {
      final report = FindMyLocationReport(
        91.0,
        11.576124,
        5,
        DateTime.utc(2026, 3, 11),
        null,
        null,
      );

      expect(isValidLocationReport(report), isFalse);
    });
  });
}
