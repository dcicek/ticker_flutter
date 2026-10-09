import 'package:ticker/core/error/result.dart';
import 'package:ticker/features/chart/domain/entities/candle.dart';
import 'package:ticker/features/chart/domain/entities/chart_interval.dart';

abstract interface class ChartRepository {
  Future<Result<List<Candle>>> getCandles(
    String symbol,
    ChartInterval interval,
  );
}
