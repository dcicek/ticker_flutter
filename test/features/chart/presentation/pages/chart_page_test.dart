import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ticker/core/error/result.dart';
import 'package:ticker/features/chart/domain/entities/candle.dart';
import 'package:ticker/features/chart/presentation/bloc/chart_bloc.dart';
import 'package:ticker/features/chart/presentation/pages/chart_page.dart';
import 'package:ticker/features/chart/presentation/widgets/candle_chart_painter.dart';

class _MockChartBloc extends MockBloc<ChartEvent, ChartState>
    implements ChartBloc {}

void main() {
  late _MockChartBloc bloc;

  setUp(() {
    bloc = _MockChartBloc();
  });

  Future<void> pumpPage(WidgetTester tester, ChartState state) async {
    when(() => bloc.state).thenReturn(state);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ChartBloc>.value(
          value: bloc,
          child: const ChartPage(),
        ),
      ),
    );
  }

  group('ChartPage', () {
    testWidgets('loaded iken başlık, son fiyat, değişim ve grafik görünür', (
      tester,
    ) async {
      await pumpPage(
        tester,
        ChartState(
          status: ChartStatus.loaded,
          symbol: 'BTCUSDT',
          candles: [
            Candle(
              openTime: DateTime.utc(2026),
              open: 100,
              high: 130,
              low: 90,
              close: 120,
              volume: 1,
            ),
          ],
        ),
      );

      expect(find.text('BTCUSDT'), findsOneWidget);
      expect(find.text('120.00'), findsOneWidget);
      // (120 - 100) / 100 = %20
      expect(find.text('+20.00%'), findsOneWidget);
      // Ekranda painter'ı CandleChartPainter olan bir CustomPaint var mı?
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint && widget.painter is CandleChartPainter,
        ),
        findsOneWidget,
      );
    });

    testWidgets('error iken butona basınca aynı sembolle yeniden dener', (
      tester,
    ) async {
      await pumpPage(
        tester,
        const ChartState(
          status: ChartStatus.error,
          symbol: 'BTCUSDT',
          failure: NetworkFailure(),
        ),
      );

      await tester.tap(find.text('Tekrar dene'));

      verify(() => bloc.add(const ChartStarted('BTCUSDT'))).called(1);
    });
  });
}
