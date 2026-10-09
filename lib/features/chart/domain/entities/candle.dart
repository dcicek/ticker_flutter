import 'package:equatable/equatable.dart';

final class Candle extends Equatable {
  final DateTime openTime;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  const Candle({
    required this.openTime,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  @override
  List<Object?> get props => [openTime, open, high, low, close, volume];
}
