import 'package:ticker/core/error/failure_mapper.dart';
import 'package:ticker/core/error/result.dart';
import 'package:ticker/features/market/data/datasources/market_remote_data_source.dart';
import 'package:ticker/features/market/data/datasources/market_socket_data_source.dart';
import 'package:ticker/features/market/domain/entities/coin.dart';
import 'package:ticker/features/market/domain/repositories/market_repository.dart';

/// A [MarketRepository] backed by Binance's REST API.
///
/// This is where exceptions stop: whatever the data source throws is turned
/// into a [Failure], so callers only ever deal with a [Result].
class MarketRepositoryImpl implements MarketRepository {
  final MarketRemoteDataSource _remote;
  final MarketSocketDataSource _socket;
  final Duration Function(int attempt) _retryDelay;

  MarketRepositoryImpl(
    this._remote,
    this._socket, {
    Duration Function(int attempt) retryDelay = _backoff,
  }) : _retryDelay = retryDelay;

  // 1, 2, 4, 8, 16 saniye, sonra hep 30 saniye.
  static Duration _backoff(int attempt) =>
      Duration(seconds: attempt < 5 ? 1 << attempt : 30);

  @override
  Future<Result<List<Coin>>> getCoins() async {
    try {
      final tickers = await _remote.getTickers();
      return Success(tickers.map((dto) => dto.toEntity()).toList());
    } on Object catch (e) {
      return Failure(failureFrom(e));
    }
  }

  @override
  Stream<Result<List<Coin>>> watchCoins() async* {
    var attempt = 0;

    // Bağlantı koptuğunda ya da sunucu kapattığında yeniden bağlanır; stream
    // yalnızca dinleyen bırakınca biter.
    while (true) {
      try {
        await for (final tickers in _socket.watchTickers()) {
          attempt = 0;
          yield Success(tickers.map((dto) => dto.toEntity()).toList());
        }
      } on Object catch (e) {
        yield Failure(NetworkFailure(e.toString()));
      }

      await Future<void>.delayed(_retryDelay(attempt++));
    }
  }
}
