/// The outcome of an operation that can fail.
///
/// Because the class is sealed, a `switch` over a [Result] must handle both
/// [Success] and [Failure]; forgetting one is a compile-time error.
sealed class Result<T> {
  const Result();
}

/// A successful [Result] carrying the produced [value].
final class Success<T> extends Result<T> {
  /// Creates a successful result holding [value].
  const Success(this.value);

  /// The value produced by the operation.
  final T value;
}

/// A failed [Result] carrying the [failure] that explains why.
final class Failure<T> extends Result<T> {
  /// Creates a failed result holding [failure].
  const Failure(this.failure);

  /// What went wrong.
  final AppFailure failure;
}

/// Everything that can go wrong in the app, as seen by the upper layers.
///
/// The data layer translates low-level exceptions (Dio, socket, parsing) into
/// one of these, so blocs and widgets never depend on `dio` types.
sealed class AppFailure {
  const AppFailure([this.message]);

  /// Optional technical detail, intended for logs rather than the UI.
  final String? message;
}

/// The server could not be reached: no connection, timeout, DNS error.
final class NetworkFailure extends AppFailure {
  /// Creates a network failure with an optional [message].
  const NetworkFailure([super.message]);
}

/// The server answered with an error status.
final class ServerFailure extends AppFailure {
  /// Creates a server failure for [statusCode] with an optional [message].
  const ServerFailure({this.statusCode, String? message}) : super(message);

  /// The HTTP status code, when one was received.
  final int? statusCode;
}

/// Anything that does not fit the other cases, such as a malformed response.
final class UnknownFailure extends AppFailure {
  /// Creates an unknown failure with an optional [message].
  const UnknownFailure([super.message]);
}
