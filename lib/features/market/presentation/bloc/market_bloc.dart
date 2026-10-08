import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ticker/core/error/result.dart';
import 'package:ticker/features/market/domain/entities/coin.dart';
import 'package:ticker/features/market/domain/repositories/market_repository.dart';

part 'market_event.dart';
part 'market_state.dart';

class MarketBloc extends Bloc<MarketEvent, MarketState> {
  final MarketRepository _repository;

  MarketBloc(this._repository) : super(const MarketState()) {
    // restartable: yeni bir MarketStarted gelirse çalışan handler iptal edilir,
    // böylece yenilemede eski soket aboneliği kapanır ve tek bağlantı kalır.
    on<MarketStarted>(_onStarted, transformer: restartable());
  }

  Future<void> _onStarted(
    MarketStarted event,
    Emitter<MarketState> emit,
  ) async {
    emit(state.copyWith(status: MarketStatus.loading));

    final result = await _repository.getCoins();
    switch (result) {
      case Success(:final value):
        emit(
          state.copyWith(
            status: MarketStatus.loaded,
            coins: _topUsdtPairs(value),
          ),
        );
      case Failure(:final failure):
        emit(state.copyWith(status: MarketStatus.error, failure: failure));
        return;
    }

    await emit.forEach(
      _repository.watchCoins(),
      onData: (update) => switch (update) {
        Success(:final value) => state.copyWith(
          status: MarketStatus.loaded,
          coins: _applyUpdates(state.coins, value),
        ),
        Failure(:final failure) => state.copyWith(
          status: MarketStatus.error,
          failure: failure,
        ),
      },
    );
  }
}

List<Coin> _topUsdtPairs(List<Coin> coins) {
  return coins.where((coin) => coin.symbol.endsWith('USDT')).toList()
    ..sort((a, b) => (b.price * b.volume).compareTo(a.price * a.volume));
}

// Soket yalnızca değişen pariteleri gönderir. Listedeki sıra korunur; her
// saniye yeniden sıralamak satırların ekranda zıplamasına yol açardı.
List<Coin> _applyUpdates(List<Coin> current, List<Coin> updates) {
  final bySymbol = {for (final coin in updates) coin.symbol: coin};
  return [for (final coin in current) bySymbol[coin.symbol] ?? coin];
}
