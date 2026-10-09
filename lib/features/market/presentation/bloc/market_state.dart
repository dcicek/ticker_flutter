part of 'market_bloc.dart';

enum MarketStatus { initial, loading, loaded, error }

final class MarketState extends Equatable {
  final MarketStatus status;
  final List<Coin> coins;
  final AppFailure? failure;
  final bool isLive;

  const MarketState({
    this.status = MarketStatus.initial,
    this.coins = const [],
    this.failure,
    this.isLive = false,
  });

  MarketState copyWith({
    MarketStatus? status,
    List<Coin>? coins,
    AppFailure? failure,
    bool? isLive,
  }) {
    return MarketState(
      status: status ?? this.status,
      coins: coins ?? this.coins,
      failure: failure,
      isLive: isLive ?? this.isLive,
    );
  }

  @override
  List<Object?> get props => [status, coins, failure, isLive];
}
