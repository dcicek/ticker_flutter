import 'package:flutter_test/flutter_test.dart';
import 'package:ticker/features/chart/data/models/candle_dto.dart';
import 'package:ticker/features/chart/domain/entities/candle.dart';

void main() {
  // Binance'in gönderdiği şekil: her mum bir dizi, sayılar string.
  const body =
      '[[1700000000000,"100.0","120.0","90.0","110.0","5.5",1700003599999],'
      '[1700003600000,"110.0","115.0","105.0","108.0","3.0",1700007199999]]';

  group('CandleDto', () {
    test('fromJson dizideki sıraya göre alanları doldurur', () {
      final dto = CandleDto.fromJson(const [
        1700000000000,
        '100.0',
        '120.0',
        '90.0',
        '110.0',
        '5.5',
      ]);

      expect(dto.openTime, 1700000000000);
      expect(dto.open, 100);
      expect(dto.high, 120);
      expect(dto.low, 90);
      expect(dto.close, 110);
      expect(dto.volume, 5.5);
    });

    test('toEntity milisaniyeyi UTC tarihe çevirir', () {
      const dto = CandleDto(
        openTime: 1700000000000,
        open: 100,
        high: 120,
        low: 90,
        close: 110,
        volume: 5.5,
      );

      expect(
        dto.toEntity(),
        Candle(
          openTime: DateTime.utc(2023, 11, 14, 22, 13, 20),
          open: 100,
          high: 120,
          low: 90,
          close: 110,
          volume: 5.5,
        ),
      );
    });
  });

  group('parseKlines', () {
    test('ham metni CandleDto listesine çevirir', () {
      final candles = parseKlines(body);

      expect(candles.length, 2);
      expect(candles[0].close, 110);
      expect(candles[1].openTime, 1700003600000);
    });

    test('bozuk metinde FormatException fırlatır', () {
      expect(() => parseKlines('bu json değil'), throwsFormatException);
    });
  });
}
