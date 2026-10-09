import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ticker/core/presentation/app_colors.dart';
import 'package:ticker/core/presentation/error_view.dart';
import 'package:ticker/features/market/domain/entities/coin.dart';
import 'package:ticker/features/market/presentation/bloc/market_bloc.dart';
import 'package:ticker/features/market/presentation/widgets/coin_tile.dart';

class MarketPage extends StatelessWidget {
  const MarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Piyasa'),
        actions: const [_LiveIndicator(), SizedBox(width: 16)],
      ),
      body: BlocConsumer<MarketBloc, MarketState>(
        // Liste ekrandayken yenileme başarısız olursa listeyi silmek yerine
        // altta kısa bir uyarı göster.
        listenWhen: (previous, current) =>
            previous.status != MarketStatus.error &&
            current.status == MarketStatus.error &&
            current.coins.isNotEmpty,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(failureMessage(state.failure))),
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
              MarketStatus.error => ErrorView(
                message: failureMessage(state.failure),
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

class _LiveIndicator extends StatelessWidget {
  const _LiveIndicator();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MarketBloc, MarketState, bool>(
      selector: (state) => state.isLive,
      builder: (context, isLive) {
        return Tooltip(
          message: isLive ? 'Canlı' : 'Bağlantı yok',
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isLive ? upColor : Theme.of(context).colorScheme.outline,
            ),
          ),
        );
      },
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

        return InkWell(
          onTap: () => context.go('/chart/$symbol'),
          child: CoinTile(
            symbol: symbol,
            price: BlocSelector<MarketBloc, MarketState, double>(
              selector: (state) => _coin(state)?.price ?? 0,
              builder: (context, price) => CoinPrice(price: price),
            ),
            change: BlocSelector<MarketBloc, MarketState, double>(
              selector: (state) => _coin(state)?.changePercent ?? 0,
              builder: (context, change) => CoinChange(changePercent: change),
            ),
          ),
        );
      },
    );
  }
}
