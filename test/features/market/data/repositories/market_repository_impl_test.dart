import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ticker/core/error/result.dart';
import 'package:ticker/features/market/data/datasources/market_remote_data_source.dart';
import 'package:ticker/features/market/data/datasources/market_socket_data_source.dart';
import 'package:ticker/features/market/data/models/coin_dto.dart';
import 'package:ticker/features/market/data/repositories/market_repository_impl.dart';
import 'package:ticker/features/market/domain/entities/coin.dart';

// Bu kez sahtesini yaptığımız şey Dio değil, data source.
class _MockRemoteDataSource extends Mock implements MarketRemoteDataSource {}

class _MockSocketDataSource extends Mock implements MarketSocketDataSource {}

void main() {
  late _MockRemoteDataSource remote;
  late _MockSocketDataSource socket;
  late MarketRepositoryImpl repository;

  setUp(() {
    remote = _MockRemoteDataSource();
    socket = _MockSocketDataSource();
    repository = MarketRepositoryImpl(remote, socket);
  });

  group('MarketRepositoryImpl.getCoins', () {
    test('data source DTO dönerse Success içinde Coin listesi verir', () async {
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

    test('sunucu hata kodu dönerse ServerFailure verir', () async {
      // 1. Hazırla: cevabı (response) olan bir DioException
      when(() => remote.getTickers()).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          response: Response<dynamic>(
            requestOptions: RequestOptions(),
            statusCode: 500,
          ),
        ),
      );

      // 2. Çalıştır
      final result = await repository.getCoins();

      // 3. Doğrula
      expect(result, isA<Failure<List<Coin>>>());
      final failure = (result as Failure<List<Coin>>).failure;
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 500);
    });

    test('cevap parse edilemezse UnknownFailure verir', () async {
      // 1. Hazırla
      when(
        () => remote.getTickers(),
      ).thenThrow(const FormatException('bozuk veri'));

      // 2. Çalıştır
      final result = await repository.getCoins();

      // 3. Doğrula
      expect(result, isA<Failure<List<Coin>>>());
      expect(
        (result as Failure<List<Coin>>).failure,
        isA<UnknownFailure>(),
      );
    });
  });

  group('MarketRepositoryImpl.watchCoins', () {
    const dto = CoinDto(
      symbol: 'BTCUSDT',
      lastPrice: 110,
      priceChangePercent: 10,
      volume: 5,
    );
    const coin = Coin(
      symbol: 'BTCUSDT',
      price: 110,
      changePercent: 10,
      volume: 5,
    );

    test('soketten gelen her listeyi Success içinde Coin olarak yayınlar', () {
      // Stream.value: tek bir değer yayınlayıp kapanan hazır bir stream.
      when(() => socket.watchTickers()).thenAnswer(
        (_) => Stream.value(const [dto]),
      );

      expect(
        repository.watchCoins(),
        emitsInOrder([
          isA<Success<List<Coin>>>().having((s) => s.value, 'value', [coin]),
          emitsDone,
        ]),
      );
    });

    test('soket hata verirse Failure yayınlar ve stream biter', () {
      // Stream.error: hata fırlatan bir stream, kopan bağlantının taklidi.
      when(() => socket.watchTickers()).thenAnswer(
        (_) => Stream.error(Exception('bağlantı koptu')),
      );

      expect(
        repository.watchCoins(),
        emitsInOrder([
          isA<Failure<List<Coin>>>().having(
            (f) => f.failure,
            'failure',
            isA<NetworkFailure>(),
          ),
          emitsDone,
        ]),
      );
    });
  });
}
