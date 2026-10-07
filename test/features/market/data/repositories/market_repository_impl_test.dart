import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ticker/core/error/result.dart';
import 'package:ticker/features/market/data/datasources/market_remote_data_source.dart';
import 'package:ticker/features/market/data/models/coin_dto.dart';
import 'package:ticker/features/market/data/repositories/market_repository_impl.dart';
import 'package:ticker/features/market/domain/entities/coin.dart';

// Bu kez sahtesini yaptığımız şey Dio değil, data source.
class _MockRemoteDataSource extends Mock implements MarketRemoteDataSource {}

void main() {
  late _MockRemoteDataSource remote;
  late MarketRepositoryImpl repository;

  setUp(() {
    remote = _MockRemoteDataSource();
    repository = MarketRepositoryImpl(remote);
  });

  group('MarketRepositoryImpl.getCoins', () {
    test("data source DTO dönerse Success içinde Coin listesi verir", () async {
      // 1. Hazırla
      when(() => remote.getTickers()).thenAnswer(
        (_) async => const [
          CoinDto(
            symbol: 'BTCUSDT',
            lastPrice: 67000.10,
            priceChangePercent: 2.35,
            volume: 12345.678,
          ),
        ],
      );

      // 2. Çalıştır
      final result = await repository.getCoins();

      // 3. Doğrula
      expect(result, isA<Success<List<Coin>>>());
      expect(
        (result as Success<List<Coin>>).value,
        const [
          Coin(
            symbol: 'BTCUSDT',
            price: 67000.10,
            changePercent: 2.35,
            volume: 12345.678,
          ),
        ],
      );
    });

    test('bağlantı kurulamazsa NetworkFailure verir', () async {
      // 1. Hazırla: cevap (response) olmayan bir DioException
      when(() => remote.getTickers()).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.connectionError,
        ),
      );

      // 2. Çalıştır
      final result = await repository.getCoins();

      // 3. Doğrula
      expect(result, isA<Failure<List<Coin>>>());
      expect(
        (result as Failure<List<Coin>>).failure,
        isA<NetworkFailure>(),
      );
    });
  });
}
