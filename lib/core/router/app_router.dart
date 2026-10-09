import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ticker/core/di/injection.dart';
import 'package:ticker/features/chart/presentation/bloc/chart_bloc.dart';
import 'package:ticker/features/chart/presentation/pages/chart_page.dart';
import 'package:ticker/features/market/presentation/bloc/market_bloc.dart';
import 'package:ticker/features/market/presentation/pages/market_page.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<MarketBloc>()..add(const MarketStarted()),
        child: const MarketPage(),
      ),
      routes: [
        // Alt rota: grafik açıkken liste sayfası ve canlı bağlantısı altta
        // yaşamaya devam eder.
        GoRoute(
          path: 'chart/:symbol',
          builder: (context, state) {
            final symbol = state.pathParameters['symbol']!;
            return BlocProvider(
              create: (_) => getIt<ChartBloc>()..add(ChartStarted(symbol)),
              child: const ChartPage(),
            );
          },
        ),
      ],
    ),
  ],
);
