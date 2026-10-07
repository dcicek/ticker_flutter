import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:ticker/features/market/data/datasources/market_remote_data_source.dart';
import 'package:ticker/features/market/data/repositories/market_repository_impl.dart';
import 'package:ticker/features/market/domain/repositories/market_repository.dart';
import 'package:ticker/features/market/presentation/bloc/market_bloc.dart';

final GetIt getIt = GetIt.instance;

// Uygulamadaki gerçek nesnelerin kurulduğu tek yer. Sınıflar bağımlılıklarını
// constructor'dan alıyor; getIt yalnızca burada ve widget ağacının tepesinde
// kullanılıyor, bu yüzden testler getIt'e hiç dokunmuyor.
void configureDependencies() {
  getIt
    ..registerLazySingleton<Dio>(
      () => Dio(
        BaseOptions(
          baseUrl: 'https://api.binance.com',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ),
      ),
    )
    ..registerLazySingleton(() => MarketRemoteDataSource(getIt()))
    ..registerLazySingleton<MarketRepository>(
      () => MarketRepositoryImpl(getIt()),
    )
    // Bloc her ekran için yeniden oluşturulur, o yüzden factory.
    ..registerFactory(() => MarketBloc(getIt()));
}
