import 'package:flutter/material.dart';
import 'package:ticker/core/error/result.dart';

String failureMessage(AppFailure? failure) {
  return switch (failure) {
    NetworkFailure() => 'İnternet bağlantısı kurulamadı.',
    ServerFailure(:final statusCode) =>
      'Sunucu hata verdi (${statusCode ?? '?'}).',
    UnknownFailure() || null => 'Beklenmeyen bir hata oluştu.',
  };
}

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorView({required this.message, required this.onRetry, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Tekrar dene'),
            ),
          ],
        ),
      ),
    );
  }
}
