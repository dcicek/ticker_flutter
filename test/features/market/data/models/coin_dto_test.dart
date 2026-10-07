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
  });
}
