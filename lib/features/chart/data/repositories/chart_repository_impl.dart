import 'package:ticker/core/error/failure_mapper.dart';
import 'package:ticker/core/error/result.dart';
import 'package:ticker/features/chart/data/datasources/chart_remote_data_source.dart';
import 'package:ticker/features/chart/domain/entities/candle.dart';
import 'package:ticker/features/chart/domain/entities/chart_interval.dart';
import 'package:ticker/features/chart/domain/repositories/chart_repository.dart';

class ChartRepositoryImpl implements ChartRepository {
  final ChartRemoteDataSource _remote;

  ChartRepositoryImpl(this._remote);

  @override
  Future<Result<List<Candle>>> getCandles(
    String symbol,
    ChartInterval interval,
  ) async {
    try {
      final klines = await _remote.getKlines(
        symbol: symbol,
        interval: interval.apiValue,
      );
      return Success(klines.map((dto) => dto.toEntity()).toList());
    } on Object catch (e) {
      return Failure(failureFrom(e));
    }
  }
}
