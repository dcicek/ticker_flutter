import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ticker/core/error/result.dart';
import 'package:ticker/features/chart/domain/entities/candle.dart';
import 'package:ticker/features/chart/domain/entities/chart_interval.dart';
import 'package:ticker/features/chart/domain/repositories/chart_repository.dart';
import 'package:ticker/features/chart/presentation/bloc/chart_bloc.dart';

class _MockChartRepository extends Mock implements ChartRepository {}

void main() {
  final candles = [
    Candle(
      openTime: DateTime.utc(2026),
      open: 100,
      high: 120,
      low: 90,
      close: 110,
      volume: 5,
    ),
  ];

  late _MockChartRepository repository;

  setUp(() {
    repository = _MockChartRepository();
  });

  group('ChartBloc', () {
    blocTest<ChartBloc, ChartState>(
      'ChartStarted gelince varsayılan 1 saatlik aralıkla mumları yükler',
      setUp: () {
        when(
          () => repository.getCandles('BTCUSDT', ChartInterval.h1),
        ).thenAnswer((_) async => Success(candles));
      },
      build: () => ChartBloc(repository),
      act: (bloc) => bloc.add(const ChartStarted('BTCUSDT')),
      expect: () => [
        const ChartState(status: ChartStatus.loading, symbol: 'BTCUSDT'),
        ChartState(
          status: ChartStatus.loaded,
          symbol: 'BTCUSDT',
          candles: candles,
        ),
      ],
    );

    blocTest<ChartBloc, ChartState>(
      'repository hata verirse error state verir, sembol korunur',
      setUp: () {
        when(
          () => repository.getCandles('BTCUSDT', ChartInterval.h1),
        ).thenAnswer((_) async => const Failure(NetworkFailure()));
      },
      build: () => ChartBloc(repository),
      act: (bloc) => bloc.add(const ChartStarted('BTCUSDT')),
      expect: () => const [
        ChartState(status: ChartStatus.loading, symbol: 'BTCUSDT'),
        ChartState(
          status: ChartStatus.error,
          symbol: 'BTCUSDT',
          failure: NetworkFailure(),
        ),
      ],
    );
  });
}
