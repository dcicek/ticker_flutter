import 'package:dio/dio.dart';
import 'package:ticker/core/error/result.dart';

// Status code varsa sunucu cevap vermiştir; yoksa sunucuya hiç ulaşılamamıştır.
// Dio dışındaki hatalar (FormatException, TypeError) bozuk veri demektir.
AppFailure failureFrom(Object error) {
  if (error is DioException) {
    final statusCode = error.response?.statusCode;
    return statusCode != null
        ? ServerFailure(statusCode: statusCode, message: error.message)
        : NetworkFailure(error.message);
  }
  return UnknownFailure(error.toString());
}
