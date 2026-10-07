import 'package:equatable/equatable.dart';

/// A tradable pair and its 24-hour market summary.
///
/// Extends [Equatable] so two coins with the same field values compare equal,
/// which is what lets bloc tests compare an expected state with the actual one.
final class Coin extends Equatable {
  /// Creates a coin with its latest market figures.
  const Coin({
    required this.symbol,
    required this.price,
    required this.changePercent,
    required this.volume,
  });

  /// The pair's ticker symbol, such as `BTCUSDT`.
  final String symbol;

  /// The last traded price.
  final double price;

  /// The price change over the last 24 hours, in percent.
  final double changePercent;

  /// The volume traded over the last 24 hours.
  final double volume;

  @override
  List<Object?> get props => [symbol, price, changePercent, volume];
}
