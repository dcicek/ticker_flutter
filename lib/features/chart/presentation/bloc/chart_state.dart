part of 'chart_bloc.dart';

enum ChartStatus { initial, loading, loaded, error }

final class ChartState extends Equatable {
  final ChartStatus status;
  final String symbol;
  final ChartInterval interval;
  final List<Candle> candles;
  final AppFailure? failure;

  const ChartState({
    this.status = ChartStatus.initial,
    this.symbol = '',
    this.interval = ChartInterval.h1,
    this.candles = const [],
    this.failure,
  });

  ChartState copyWith({
    ChartStatus? status,
    String? symbol,
    ChartInterval? interval,
    List<Candle>? candles,
    AppFailure? failure,
  }) {
    return ChartState(
      status: status ?? this.status,
      symbol: symbol ?? this.symbol,
      interval: interval ?? this.interval,
      candles: candles ?? this.candles,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, symbol, interval, candles, failure];
}
