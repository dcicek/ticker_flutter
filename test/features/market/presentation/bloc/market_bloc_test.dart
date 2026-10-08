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
    // Varsayılan: canlı akış hiçbir şey göndermeden kapanır. Canlı fiyatı
    // test eden testler bunu kendi stream'iyle ezer.
    when(
      () => repository.watchCoins(),
    ).thenAnswer((_) => const Stream.empty());
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

    blocTest<MarketBloc, MarketState>(
      'yalnızca USDT paritelerini işlem tutarına göre sıralı verir',
      setUp: () {
        when(() => repository.getCoins()).thenAnswer(
          (_) async => const Success([
            // tutar: 2 x 10 = 20
            Coin(symbol: 'AUSDT', price: 2, changePercent: 0, volume: 10),
            // USDT paritesi değil, elenmeli
            Coin(symbol: 'ETHBTC', price: 1, changePercent: 0, volume: 999),
            // tutar: 5 x 100 = 500
            Coin(symbol: 'BUSDT', price: 5, changePercent: 0, volume: 100),
          ]),
        );
      },
      build: () => MarketBloc(repository),
      act: (bloc) => bloc.add(const MarketStarted()),
      skip: 1, // loading state'ini atla
      verify: (bloc) {
        expect(bloc.state.coins.map((coin) => coin.symbol), [
          'BUSDT',
          'AUSDT',
        ]);
      },
    );
  });

  group('MarketBloc canlı fiyat', () {
    const initial = [
      // tutar: 100 x 10 = 1000, listede ilk sırada
      Coin(symbol: 'BTCUSDT', price: 100, changePercent: 1, volume: 10),
      // tutar: 10 x 10 = 100
      Coin(symbol: 'ETHUSDT', price: 10, changePercent: 2, volume: 10),
    ];
    const ethUpdate = Coin(
      symbol: 'ETHUSDT',
      price: 12,
      changePercent: 20,
      volume: 10,
    );

    setUp(() {
      when(
        () => repository.getCoins(),
      ).thenAnswer((_) async => const Success(initial));
    });

    blocTest<MarketBloc, MarketState>(
      'güncelleme gelen coin değişir, diğerleri ve sıra aynı kalır',
      setUp: () {
        when(() => repository.watchCoins()).thenAnswer(
          (_) => Stream.value(
            const Success([
              ethUpdate,
              // Listede olmayan parite yok sayılmalı
              Coin(symbol: 'XRPBTC', price: 1, changePercent: 0, volume: 1),
            ]),
          ),
        );
      },
      build: () => MarketBloc(repository),
      act: (bloc) => bloc.add(const MarketStarted()),
      expect: () => const [
        MarketState(status: MarketStatus.loading),
        MarketState(status: MarketStatus.loaded, coins: initial),
        MarketState(
          status: MarketStatus.loaded,
          coins: [
            Coin(symbol: 'BTCUSDT', price: 100, changePercent: 1, volume: 10),
            ethUpdate,
          ],
        ),
      ],
    );

    blocTest<MarketBloc, MarketState>(
      'canlı akış hata verirse liste korunur, status error olur',
      setUp: () {
        when(() => repository.watchCoins()).thenAnswer(
          (_) => Stream.value(const Failure(NetworkFailure())),
        );
      },
      build: () => MarketBloc(repository),
      act: (bloc) => bloc.add(const MarketStarted()),
      skip: 2, // loading ve ilk loaded
      expect: () => const [
        MarketState(
          status: MarketStatus.error,
          coins: initial,
          failure: NetworkFailure(),
        ),
      ],
    );

    blocTest<MarketBloc, MarketState>(
      'ilk yükleme başarısızsa canlı akışa hiç bağlanmaz',
      setUp: () {
        when(
          () => repository.getCoins(),
        ).thenAnswer((_) async => const Failure(NetworkFailure()));
      },
      build: () => MarketBloc(repository),
      act: (bloc) => bloc.add(const MarketStarted()),
      verify: (_) {
        verifyNever(() => repository.watchCoins());
      },
    );
  });
}
