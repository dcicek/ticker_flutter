part of 'market_bloc.dart';

sealed class MarketEvent extends Equatable {
  const MarketEvent();

  @override
  List<Object> get props => [];
}

final class MarketStarted extends MarketEvent {
  const MarketStarted();
}
