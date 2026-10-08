import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ticker/core/error/result.dart';
import 'package:ticker/features/market/domain/entities/coin.dart';
import 'package:ticker/features/market/presentation/bloc/market_bloc.dart';
import 'package:ticker/features/market/presentation/widgets/coin_tile.dart';

class MarketPage extends StatelessWidget {
  const MarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Piyasa')),
      body: BlocConsumer<MarketBloc, MarketState>(
        // Liste ekrandayken yenileme başarısız olursa listeyi silmek yerine
        // altta kısa bir uyarı göster.
        listenWhen: (previous, current) =>
            current.status == MarketStatus.error && current.coins.isNotEmpty,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(_failureMessage(state.failure))),
            );
        },
        // Fiyat güncellemeleri liste iskeletini yeniden kurmasın; fiyatı her
        // satır kendi BlocSelector'ı ile dinliyor.
        buildWhen: (previous, current) =>
            previous.status != current.status ||
            previous.coins.length != current.coins.length,
        builder: (context, state) {
          if (state.coins.isEmpty) {
            return switch (state.status) {
              MarketStatus.initial || MarketStatus.loading => const Center(
                child: CircularProgressIndicator(),
              ),
              MarketStatus.error => _ErrorView(
                message: _failureMessage(state.failure),
                onRetry: () =>
                    context.read<MarketBloc>().add(const MarketStarted()),
              ),
              MarketStatus.loaded => const Center(
                child: Text('Gösterilecek coin yok'),
              ),
            };
          }

          return RefreshIndicator(
            onRefresh: () async {
              final bloc = context.read<MarketBloc>()
                ..add(const MarketStarted());
              // Göstergeyi yükleme bitene kadar ekranda tut.
              await bloc.stream.firstWhere(
                (s) => s.status != MarketStatus.loading,
              );
            },
            child: ListView.builder(
              itemCount: state.coins.length,
              itemExtent: CoinTile.height,
              itemBuilder: (context, index) => _CoinRow(index: index),
            ),
          );
        },
      ),
    );
  }
}

class _CoinRow extends StatelessWidget {
  final int index;

  const _CoinRow({required this.index});

  Coin? _coin(MarketState state) =>
      index < state.coins.length ? state.coins[index] : null;

  @override
  Widget build(BuildContext context) {
    // Üç ayrı seçici: ad yalnızca sembol, fiyat yalnızca fiyat, değişim
    // yalnızca yüzde değişince yeniden kurulur.
    return BlocSelector<MarketBloc, MarketState, String?>(
      selector: (state) => _coin(state)?.symbol,
      builder: (context, symbol) {
        if (symbol == null) return const SizedBox.shrink();

        return CoinTile(
          symbol: symbol,
          price: BlocSelector<MarketBloc, MarketState, double>(
            selector: (state) => _coin(state)?.price ?? 0,
            builder: (context, price) => CoinPrice(price: price),
          ),
          change: BlocSelector<MarketBloc, MarketState, double>(
            selector: (state) => _coin(state)?.changePercent ?? 0,
            builder: (context, change) => CoinChange(changePercent: change),
          ),
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Tekrar dene'),
            ),
          ],
        ),
      ),
    );
  }
}

String _failureMessage(AppFailure? failure) {
  return switch (failure) {
    NetworkFailure() => 'İnternet bağlantısı kurulamadı.',
    ServerFailure(:final statusCode) =>
      'Sunucu hata verdi (${statusCode ?? '?'}).',
    UnknownFailure() || null => 'Beklenmeyen bir hata oluştu.',
  };
}
