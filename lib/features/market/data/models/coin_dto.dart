import 'package:ticker/features/market/domain/entities/coin.dart';

/// One item of Binance's `GET /api/v3/ticker/24hr` response.
///
/// Field names mirror the API; [toEntity] maps them to the domain's [Coin].
final class CoinDto {
  final String symbol;
  final double lastPrice;
  final double priceChangePercent;
  final double volume;

  const CoinDto({
    required this.symbol,
    required this.lastPrice,
    required this.priceChangePercent,
    required this.volume,
  });

  factory CoinDto.fromJson(Map<String, dynamic> json) {
    return CoinDto(
      symbol: json['symbol'] as String,
      lastPrice: double.parse(json['lastPrice'] as String),
      priceChangePercent: double.parse(json['priceChangePercent'] as String),
      volume: double.parse(json['volume'] as String),
    );
  }

  // WebSocket `!miniTicker@arr` elemanı: s=symbol, c=son fiyat, o=24 saat
  // önceki fiyat, v=hacim. Yüzde değişim gelmediği için burada hesaplanıyor.
  factory CoinDto.fromMiniTicker(Map<String, dynamic> json) {
    final close = double.parse(json['c'] as String);
    final open = double.parse(json['o'] as String);

    return CoinDto(
      symbol: json['s'] as String,
      lastPrice: close,
      priceChangePercent: open == 0 ? 0 : (close - open) / open * 100,
      volume: double.parse(json['v'] as String),
    );
  }

  Coin toEntity() {
    return Coin(
      symbol: symbol,
      price: lastPrice,
      changePercent: priceChangePercent,
      volume: volume,
    );
  }
}
