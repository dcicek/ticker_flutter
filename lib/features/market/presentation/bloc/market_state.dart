part of 'market_bloc.dart';

enum MarketStatus { initial, loading, loaded, error }

final class MarketState extends Equatable {
  final MarketStatus status;
  final List<Coin> coins;
  final AppFailure? failure;

  const MarketState({
    this.status = MarketStatus.initial,
    this.coins = const [],
    this.failure,
  });

  MarketState copyWith({
    MarketStatus? status,
    List<Coin>? coins,
    AppFailure? failure,
  }) {
    return MarketState(
      status: status ?? this.status,
      coins: coins ?? this.coins,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, coins, failure];
}
