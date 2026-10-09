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
    // Testler yeniden bağlanmayı beklerken gerçekten saniyelerce durmasın.
    repository = MarketRepositoryImpl(
      remote,
      socket,
      retryDelay: (_) => Duration.zero,
    );
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

    Matcher isSuccessWith(List<Coin> coins) =>
        isA<Success<List<Coin>>>().having((s) => s.value, 'value', coins);
    final isNetworkFailure = isA<Failure<List<Coin>>>().having(
      (f) => f.failure,
      'failure',
      isA<NetworkFailure>(),
    );

    test('soketten gelen her listeyi Success içinde Coin olarak yayınlar', () {
      // Stream.value: tek bir değer yayınlayıp kapanan hazır bir stream.
      when(() => socket.watchTickers()).thenAnswer(
        (_) => Stream.value(const [dto]),
      );

      expect(repository.watchCoins(), emits(isSuccessWith([coin])));
    });

    test('soket hata verirse Failure yayınlar, sonra yeniden bağlanır', () {
      // İlk bağlantı kopuyor, ikincisi veri gönderiyor.
      var calls = 0;
      when(() => socket.watchTickers()).thenAnswer((_) {
        calls++;
        return calls == 1
            ? Stream.error(Exception('bağlantı koptu'))
            : Stream.value(const [dto]);
      });

      expect(
        repository.watchCoins(),
        emitsInOrder([
          isNetworkFailure,
          isSuccessWith([coin]),
        ]),
      );
    });

    test('sunucu bağlantıyı hatasız kapatırsa da yeniden bağlanır', () async {
      when(() => socket.watchTickers()).thenAnswer(
        (_) => Stream.value(const [dto]),
      );

      // İki değer alabilmek için iki ayrı bağlantı gerekir.
      await repository.watchCoins().take(2).toList();

      verify(() => socket.watchTickers()).called(2);
    });

    test(
      'art arda hatalarda bekleme artar, başarıdan sonra sıfırlanır',
      () async {
        final attempts = <int>[];
        repository = MarketRepositoryImpl(
          remote,
          socket,
          retryDelay: (attempt) {
            attempts.add(attempt);
            return Duration.zero;
          },
        );

        // hata, hata, başarı, hata
        var calls = 0;
        when(() => socket.watchTickers()).thenAnswer((_) {
          calls++;
          return calls == 3
              ? Stream.value(const [dto])
              : Stream.error(Exception('bağlantı koptu'));
        });

        await repository.watchCoins().take(4).toList();

        expect(attempts, [0, 1, 0]);
      },
    );
  });
}
