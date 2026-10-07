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

  Coin toEntity() {
    return Coin(
      symbol: symbol,
      price: lastPrice,
      changePercent: priceChangePercent,
      volume: volume,
    );
  }
}
