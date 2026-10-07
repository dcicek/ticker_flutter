import 'package:ticker/core/error/result.dart';
import 'package:ticker/features/market/domain/entities/coin.dart';

abstract interface class MarketRepository {
  Future<Result<List<Coin>>> getCoins();
}
