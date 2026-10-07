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
    on<MarketStarted>((event, emit) async {
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
      }
    });
  }
}

// Binance ~3000 parite döner. Fiyatları karşılaştırılabilir olsun diye yalnızca
// USDT paritelerini alıp 24 saatlik işlem tutarına (fiyat x hacim) göre
// büyükten küçüğe sıralıyoruz.
List<Coin> _topUsdtPairs(List<Coin> coins) {
  return coins.where((coin) => coin.symbol.endsWith('USDT')).toList()
    ..sort((a, b) => (b.price * b.volume).compareTo(a.price * a.volume));
}
