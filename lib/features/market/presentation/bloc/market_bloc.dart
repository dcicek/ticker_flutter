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
          emit(state.copyWith(status: MarketStatus.loaded, coins: value));
        case Failure(:final failure):
          emit(state.copyWith(status: MarketStatus.error, failure: failure));
      }
    });
  }
}
