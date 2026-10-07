import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ticker/core/error/result.dart';
import 'package:ticker/features/market/domain/entities/coin.dart';
import 'package:ticker/features/market/domain/repositories/market_repository.dart';
import 'package:ticker/features/market/presentation/bloc/market_bloc.dart';

class _MockMarketRepository extends Mock implements MarketRepository {}

void main() {
  const coins = [
    Coin(symbol: 'BTCUSDT', price: 67000.10, changePercent: 2.35, volume: 1),
  ];

  late _MockMarketRepository repository;

  setUp(() {
    repository = _MockMarketRepository();
  });

  group('MarketBloc', () {
    test('başlangıç state initial ve boş liste', () {
      expect(MarketBloc(repository).state, const MarketState());
    });

    blocTest<MarketBloc, MarketState>(
      'MarketStarted gelince ve repository başarılıysa loading, loaded verir',
      // 1. Hazırla
      setUp: () {
        when(
          () => repository.getCoins(),
        ).thenAnswer((_) async => const Success(coins));
      },
      build: () => MarketBloc(repository),
      // 2. Çalıştır
      act: (bloc) => bloc.add(const MarketStarted()),
      // 3. Doğrula: emit edilen state'ler, sırasıyla
      expect: () => const [
        MarketState(status: MarketStatus.loading),
        MarketState(status: MarketStatus.loaded, coins: coins),
      ],
    );

    blocTest<MarketBloc, MarketState>(
      'MarketStarted gelince ve repository hata verirse loading, error verir',
      // 1. Hazırla
      setUp: () {
        when(
          () => repository.getCoins(),
        ).thenAnswer((_) async => const Failure(NetworkFailure()));
      },
      build: () => MarketBloc(repository),
      // 2. Çalıştır
      act: (bloc) => bloc.add(const MarketStarted()),
      // 3. Doğrula
      expect: () => const [
        MarketState(status: MarketStatus.loading),
        MarketState(status: MarketStatus.error, failure: NetworkFailure()),
      ],
    );
  });
}
