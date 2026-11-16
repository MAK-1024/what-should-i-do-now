import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wsidappp/core/errors/failure.dart';

/// Centralized mapper that converts Supabase, HTTP, and connectivity errors
/// into clean, user-friendly [Failure] domain objects. Free of `dart:io` so
/// it runs on every platform, including the web.
Failure handleSupabaseError(Object error) {
  if (Failure.isNetworkError(error)) return const NetworkFailure();

  if (error is AuthException) {
    return AuthFailure(message: error.message);
  }

  if (error is PostgrestException) {
    return ServerFailure(
      message: error.message,
      statusCode: int.tryParse(error.code ?? ''),
    );
  }

  return Failure.fromException(error);
}
