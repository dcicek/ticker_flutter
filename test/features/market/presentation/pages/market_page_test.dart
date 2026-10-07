import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ticker/core/error/result.dart';
import 'package:ticker/features/market/domain/entities/coin.dart';
import 'package:ticker/features/market/presentation/bloc/market_bloc.dart';
import 'package:ticker/features/market/presentation/pages/market_page.dart';

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
  });
}
