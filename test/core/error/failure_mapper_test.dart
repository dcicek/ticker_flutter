import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticker/core/error/failure_mapper.dart';
import 'package:ticker/core/error/result.dart';

void main() {
  group('failureFrom', () {
    test('cevabı olmayan DioException NetworkFailure olur', () {
      final failure = failureFrom(
        DioException(requestOptions: RequestOptions()),
      );

      expect(failure, isA<NetworkFailure>());
    });

    test('status code taşıyan DioException ServerFailure olur', () {
      final failure = failureFrom(
        DioException(
          requestOptions: RequestOptions(),
          response: Response<dynamic>(
            requestOptions: RequestOptions(),
            statusCode: 429,
          ),
        ),
      );

      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 429);
    });

    test('Dio dışındaki hatalar UnknownFailure olur', () {
      expect(
        failureFrom(const FormatException('bozuk')),
        isA<UnknownFailure>(),
      );
    });
  });
}
