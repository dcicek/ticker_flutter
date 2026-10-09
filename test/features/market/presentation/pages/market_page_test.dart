import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ticker/core/error/result.dart';
import 'package:ticker/features/market/domain/entities/coin.dart';
import 'package:ticker/features/market/presentation/bloc/market_bloc.dart';
import 'package:ticker/features/market/presentation/pages/market_page.dart';
import 'package:ticker/features/market/presentation/widgets/coin_tile.dart';

// Sahte bloc: gerçek bloc'u ve repository'yi çalıştırmadan ekrana istediğimiz
// state'i veriyoruz.
class _MockMarketBloc extends MockBloc<MarketEvent, MarketState>
    implements MarketBloc {}

void main() {
  late _MockMarketBloc bloc;

  setUp(() {
    bloc = _MockMarketBloc();
  });

  // Ekranı sahte bloc ile ayağa kaldırır.
  Future<void> pumpPage(WidgetTester tester, MarketState state) async {
    when(() => bloc.state).thenReturn(state);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<MarketBloc>.value(
          value: bloc,
          child: const MarketPage(),
        ),
      ),
    );
  }

  group('MarketPage', () {
    testWidgets('loading iken ve liste boşken spinner gösterir', (
      tester,
    ) async {
      await pumpPage(tester, const MarketState(status: MarketStatus.loading));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('loaded iken coin satırını gösterir', (tester) async {
      await pumpPage(
        tester,
        const MarketState(
          status: MarketStatus.loaded,
          coins: [
            Coin(
              symbol: 'BTCUSDT',
              price: 67000.10,
              changePercent: -2.35,
              volume: 1,
            ),
          ],
        ),
      );

      expect(find.textContaining('BTC'), findsOneWidget);
      expect(find.text('67,000.10'), findsOneWidget);
      expect(find.text('-2.35%'), findsOneWidget);
    });

    testWidgets('error iken mesaj gösterir, butona basınca yeniden dener', (
      tester,
    ) async {
      await pumpPage(
        tester,
        const MarketState(
          status: MarketStatus.error,
          failure: NetworkFailure(),
        ),
      );

      expect(find.text('İnternet bağlantısı kurulamadı.'), findsOneWidget);

      await tester.tap(find.text('Tekrar dene'));

      verify(() => bloc.add(const MarketStarted())).called(1);
    });

    testWidgets('canlı değilken gösterge "Bağlantı yok" der', (tester) async {
      await pumpPage(tester, const MarketState(status: MarketStatus.loaded));

      expect(find.byTooltip('Bağlantı yok'), findsOneWidget);
    });

    testWidgets('canlıyken gösterge "Canlı" der', (tester) async {
      await pumpPage(
        tester,
        const MarketState(status: MarketStatus.loaded, isLive: true),
      );

      expect(find.byTooltip('Canlı'), findsOneWidget);
    });

    testWidgets('canlı güncelleme gelince yalnızca değişen fiyat ve yüzde '
        'yeniden kurulur', (tester) async {
      const btc = Coin(
        symbol: 'BTCUSDT',
        price: 100,
        changePercent: 1,
        volume: 1,
      );
      const eth = Coin(
        symbol: 'ETHUSDT',
        price: 10,
        changePercent: 2,
        volume: 1,
      );
      const ethUpdated = Coin(
        symbol: 'ETHUSDT',
        price: 12,
        changePercent: 20,
        volume: 1,
      );
      const before = MarketState(
        status: MarketStatus.loaded,
        coins: [btc, eth],
      );
      const after = MarketState(
        status: MarketStatus.loaded,
        coins: [btc, ethUpdated],
      );

      // whenListen: sahte bloc'a "önce before state'indesin, sonra after
      // yayınla" diyoruz; soketten güncelleme gelmesinin taklidi.
      whenListen(bloc, Stream.value(after), initialState: before);
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MarketBloc>.value(
            value: bloc,
            child: const MarketPage(),
          ),
        ),
      );

      // İlk çizimdeki widget nesnelerini sakla. Bir widget yeniden build
      // edilmediyse sonradan bulduğumuz nesne bunlarla birebir aynıdır.
      final tilesBefore = tester.widgetList(find.byType(CoinTile)).toList();
      final pricesBefore = tester.widgetList(find.byType(CoinPrice)).toList();

      await tester.pump(); // after state'i işlensin

      final tilesAfter = tester.widgetList(find.byType(CoinTile)).toList();
      final pricesAfter = tester.widgetList(find.byType(CoinPrice)).toList();

      // ETH'nin yeni fiyatı ekranda
      expect(find.text('12.00'), findsOneWidget);
      expect(find.text('10.00'), findsNothing);
      expect(find.text('+20.00%'), findsOneWidget);

      // Avatar ve ad kısmı iki satırda da yeniden kurulmadı
      expect(identical(tilesAfter[0], tilesBefore[0]), isTrue);
      expect(identical(tilesAfter[1], tilesBefore[1]), isTrue);

      // BTC'nin fiyatı yeniden kurulmadı, ETH'ninki kuruldu
      expect(identical(pricesAfter[0], pricesBefore[0]), isTrue);
      expect(identical(pricesAfter[1], pricesBefore[1]), isFalse);
    });
  });
}
