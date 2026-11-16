/// Core failure types for the What Should I Do? app.
///
/// All domain/data errors are mapped to a [Failure] subclass so that
/// the presentation layer never has to handle raw exceptions.
library;

// ignore_for_file: always_declare_return_types

/// Base sealed class for all application failures.
sealed class Failure {
  const Failure({
    required this.message,
    this.statusCode,
  });

  /// Human-readable description of the failure.
  final String message;

  /// Optional HTTP status code or application error code.
  final int? statusCode;

  /// Default user-friendly error message for network connectivity issues.
  static const String defaultNetworkErrorMessage =
      'Unable to connect to the server. Please check your internet connection or VPN.';

  static const List<String> _networkErrorMarkers = <String>[
    'socketexception',
    'failed host lookup',
    'clientexception',
    'xmlhttprequest error',
    'failed to fetch',
    'network is unreachable',
    'connection refused',
    'connection reset',
    'connection closed',
    'no address associated with hostname',
    'timeoutexception',
  ];

  /// Platform-agnostic connectivity check. Matches on the error text instead
  /// of `dart:io` types so it behaves the same on mobile, desktop and web.
  static bool isNetworkError(Object error) {
    final String errorStr = error.toString().toLowerCase();
    return _networkErrorMarkers.any(errorStr.contains);
  }

  /// Maps an arbitrary exception or error object to a clean, user-facing [Failure].
  ///
  /// Connectivity errors (socket drops, DNS failures, browser fetch errors)
  /// are mapped to [NetworkFailure] rather than surfacing raw traces.
  static Failure fromException(Object error, [int? statusCode]) {
    if (isNetworkError(error)) return const NetworkFailure();

    return ServerFailure(
      message: error.toString(),
      statusCode: statusCode,
    );
  }

  @override
  String toString() => '$runtimeType(message: $message, statusCode: $statusCode)';
}

/// Failure originating from a remote server error.
final class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.statusCode,
  });
}

/// Failure originating from network connectivity issues (offline, DNS, socket drop).
final class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = Failure.defaultNetworkErrorMessage,
    super.statusCode,
  });
}

/// Failure originating from an authentication/authorisation error.
final class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.statusCode,
  });
}

/// Failure originating from a local cache (e.g. SharedPreferences / Hive).
final class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.statusCode,
  });
}

/// Failure caused by invalid user input or business-rule violations.
final class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.statusCode,
  });
}
