import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ticker/core/presentation/app_colors.dart';
import 'package:ticker/core/presentation/error_view.dart';
import 'package:ticker/core/utils/price_format.dart';
import 'package:ticker/features/chart/domain/entities/candle.dart';
import 'package:ticker/features/chart/presentation/bloc/chart_bloc.dart';
import 'package:ticker/features/chart/presentation/widgets/candle_chart_painter.dart';

class ChartPage extends StatelessWidget {
  const ChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocSelector<ChartBloc, ChartState, String>(
          selector: (state) => state.symbol,
          builder: (context, symbol) => Text(symbol),
        ),
      ),
      body: BlocBuilder<ChartBloc, ChartState>(
        builder: (context, state) {
          return switch (state.status) {
            ChartStatus.initial || ChartStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            ChartStatus.error => ErrorView(
              message: failureMessage(state.failure),
              onRetry: () =>
                  context.read<ChartBloc>().add(ChartStarted(state.symbol)),
            ),
            ChartStatus.loaded => _ChartBody(candles: state.candles),
          };
        },
      ),
    );
  }
}

class _ChartBody extends StatelessWidget {
  final List<Candle> candles;

  const _ChartBody({required this.candles});

  @override
  Widget build(BuildContext context) {
    if (candles.isEmpty) {
      return const Center(child: Text('Gösterilecek mum yok'));
    }

    final theme = Theme.of(context);
    final first = candles.first;
    final last = candles.last;
    final change = first.open == 0
        ? 0.0
        : (last.close - first.open) / first.open * 100;
    final changeColor = change >= 0 ? upColor : downColor;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatPrice(last.close),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%',
            style: theme.textTheme.titleMedium?.copyWith(color: changeColor),
          ),
          const SizedBox(height: 24),
          Expanded(
            // RepaintBoundary: grafik yeniden çizilirken sayfanın geri kalanı,
            // sayfa değişirken de grafik yeniden çizilmez.
            child: RepaintBoundary(
              child: CustomPaint(
                size: Size.infinite,
                painter: CandleChartPainter(
                  candles: candles,
                  upColor: upColor,
                  downColor: downColor,
                  gridColor: theme.dividerTheme.color ?? theme.dividerColor,
                  labelStyle: theme.textTheme.labelSmall!.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
