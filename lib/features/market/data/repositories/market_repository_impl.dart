import 'package:dio/dio.dart';
import 'package:ticker/core/error/result.dart';
import 'package:ticker/features/market/data/datasources/market_remote_data_source.dart';
import 'package:ticker/features/market/domain/entities/coin.dart';
import 'package:ticker/features/market/domain/repositories/market_repository.dart';

/// A [MarketRepository] backed by Binance's REST API.
///
/// This is where exceptions stop: whatever the data source throws is turned
/// into a [Failure], so callers only ever deal with a [Result].
class MarketRepositoryImpl implements MarketRepository {
  /// Creates a repository that reads from [_remote].
  MarketRepositoryImpl(this._remote);

  final MarketRemoteDataSource _remote;

  @override
  Future<Result<List<Coin>>> getCoins() async {
    try {
      final tickers = await _remote.getTickers();
      return Success(tickers.map((dto) => dto.toEntity()).toList());
    } on DioException catch (e) {
      // A status code means the server answered; without one we never
      // reached it.
      final statusCode = e.response?.statusCode;
      if (statusCode != null) {
        return Failure(
          ServerFailure(statusCode: statusCode, message: e.message),
        );
      }
      return Failure(NetworkFailure(e.message));
    } on Object catch (e) {
      // Parsing problems: FormatException from double.parse, TypeError from
      // a bad cast.
      return Failure(UnknownFailure(e.toString()));
    }
  }
}
