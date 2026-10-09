import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ticker/core/error/result.dart';
import 'package:ticker/features/chart/data/datasources/chart_remote_data_source.dart';
import 'package:ticker/features/chart/data/models/candle_dto.dart';
import 'package:ticker/features/chart/data/repositories/chart_repository_impl.dart';
import 'package:ticker/features/chart/domain/entities/candle.dart';
import 'package:ticker/features/chart/domain/entities/chart_interval.dart';

class _MockRemoteDataSource extends Mock implements ChartRemoteDataSource {}

void main() {
  late _MockRemoteDataSource remote;
  late ChartRepositoryImpl repository;

  setUp(() {
    remote = _MockRemoteDataSource();
    repository = ChartRepositoryImpl(remote);
  });

  group('ChartRepositoryImpl.getCandles', () {
    test(
      "aralığı API değerine çevirip DTO'ları Candle olarak döner",
      () async {
        when(
          () => remote.getKlines(symbol: 'BTCUSDT', interval: '4h'),
        ).thenAnswer(
          (_) async => const [
            CandleDto(
              openTime: 0,
              open: 100,
              high: 120,
              low: 90,
              close: 110,
              volume: 5,
            ),
          ],
        );

        final result = await repository.getCandles('BTCUSDT', ChartInterval.h4);

        expect(result, isA<Success<List<Candle>>>());
        final candle = (result as Success<List<Candle>>).value.single;
        expect(candle.close, 110);
        expect(candle.openTime, DateTime.utc(1970));
      },
    );

    test('data source hata fırlatırsa Failure döner', () async {
      when(
        () => remote.getKlines(symbol: 'BTCUSDT', interval: '1h'),
      ).thenThrow(DioException(requestOptions: RequestOptions()));

      final result = await repository.getCandles('BTCUSDT', ChartInterval.h1);

      expect(result, isA<Failure<List<Candle>>>());
      expect(
        (result as Failure<List<Candle>>).failure,
        isA<NetworkFailure>(),
      );
    });
  });
}
