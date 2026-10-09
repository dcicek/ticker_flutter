part of 'chart_bloc.dart';

sealed class ChartEvent extends Equatable {
  const ChartEvent();

  @override
  List<Object> get props => [];
}

final class ChartStarted extends ChartEvent {
  final String symbol;

  const ChartStarted(this.symbol);

  @override
  List<Object> get props => [symbol];
}
