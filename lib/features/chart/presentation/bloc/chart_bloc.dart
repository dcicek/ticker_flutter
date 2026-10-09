import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ticker/core/error/result.dart';
import 'package:ticker/features/chart/domain/entities/candle.dart';
import 'package:ticker/features/chart/domain/entities/chart_interval.dart';
import 'package:ticker/features/chart/domain/repositories/chart_repository.dart';

part 'chart_event.dart';
part 'chart_state.dart';

class ChartBloc extends Bloc<ChartEvent, ChartState> {
  final ChartRepository _repository;

  ChartBloc(this._repository) : super(const ChartState()) {
    on<ChartStarted>(
      (event, emit) =>
          _load(emit, symbol: event.symbol, interval: state.interval),
      transformer: restartable(),
    );
  }

  Future<void> _load(
    Emitter<ChartState> emit, {
    required String symbol,
    required ChartInterval interval,
  }) async {
    emit(
      state.copyWith(
        status: ChartStatus.loading,
        symbol: symbol,
        interval: interval,
      ),
    );

    final result = await _repository.getCandles(symbol, interval);
    switch (result) {
      case Success(:final value):
        emit(state.copyWith(status: ChartStatus.loaded, candles: value));
      case Failure(:final failure):
        emit(state.copyWith(status: ChartStatus.error, failure: failure));
    }
  }
}
