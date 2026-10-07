import 'package:flutter_test/flutter_test.dart';
import 'package:ticker/core/error/result.dart';

void main() {
  group('Result', () {
    test('Success, switch içinde value değerini verir', () {
      // 1. Hazırla
      const Result<int> result = Success(42);

      // 2. Çalıştır
      final output = switch (result) {
        Success(:final value) => 'değer: $value',
        Failure() => 'hata',
      };

      // 3. Doğrula
      expect(output, 'değer: 42');
    });
  });
}
