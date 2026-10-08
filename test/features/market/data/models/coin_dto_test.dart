import 'package:flutter_test/flutter_test.dart';
import 'package:ticker/features/market/data/models/coin_dto.dart';
import 'package:ticker/features/market/domain/entities/coin.dart';

void main() {
  const json = <String, dynamic>{
    'symbol': 'BTCUSDT',
    'lastPrice': '67000.10',
    'priceChangePercent': '2.35',
    'volume': '12345.678',
  };

  group('CoinDto', () {
    test("fromJson string sayıları double'a çevirir", () {
      final dto = CoinDto.fromJson(json);

      expect(dto.symbol, 'BTCUSDT');
      expect(dto.lastPrice, 67000.10);
      expect(dto.priceChangePercent, 2.35);
      expect(dto.volume, 12345.678);
    });

    test("toEntity doğru Coin'i üretir", () {
      final coin = CoinDto.fromJson(json).toEntity();

      expect(
        coin,
        const Coin(
          symbol: 'BTCUSDT',
          price: 67000.10,
          changePercent: 2.35,
          volume: 12345.678,
        ),
      );
    });

    test('fromMiniTicker yüzde değişimi açılış ve son fiyattan hesaplar', () {
      const miniTicker = <String, dynamic>{
        's': 'BTCUSDT',
        'c': '110.00',
        'o': '100.00',
        'v': '5',
      };

      final dto = CoinDto.fromMiniTicker(miniTicker);

      expect(dto.symbol, 'BTCUSDT');
      expect(dto.lastPrice, 110);
      expect(dto.volume, 5);
      // (110 - 100) / 100 * 100 = 10. Bölme sonucu küsuratlı çıkabildiği için
      // tam eşitlik yerine "10'a çok yakın mı" diye bakıyoruz.
      expect(dto.priceChangePercent, closeTo(10, 0.0001));
    });

    test('fromMiniTicker açılış fiyatı 0 ise yüzdeyi 0 verir', () {
      const miniTicker = <String, dynamic>{
        's': 'NEWUSDT',
        'c': '1.50',
        'o': '0',
        'v': '0',
      };

      final dto = CoinDto.fromMiniTicker(miniTicker);

      expect(dto.priceChangePercent, 0);
    });
  });
}
