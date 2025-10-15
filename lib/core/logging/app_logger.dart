import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Centralised logging facade that enforces privacy requirements by
/// sanitising any string payloads before they reach the sink. In release
/// builds the logger is effectively silent.
class AppLogger {
  AppLogger._internal()
    : _logger = Logger(
        printer: PrettyPrinter(
          colors: true,
          printEmojis: false,
          methodCount: 0,
          errorMethodCount: 5,
        ),
      );

  static final AppLogger instance = AppLogger._internal();

  final Logger _logger;

  static const _ipv4Pattern = r'\b(?:\d{1,3}\.){3}\d{1,3}\b';
  static const _ipv6Pattern = r'\b(?:[0-9a-fA-F]{1,4}:){1,7}[0-9a-fA-F]{1,4}\b';
  static const _macPattern = r'\b(?:[0-9a-fA-F]{2}[:-]){5}[0-9a-fA-F]{2}\b';

  static final RegExp _ipv4Regex = RegExp(_ipv4Pattern);
  static final RegExp _ipv6Regex = RegExp(_ipv6Pattern);
  static final RegExp _macRegex = RegExp(_macPattern);

  /// Convenience getter so callers can `appLogger.debug(...)`.
  static AppLogger get log => instance;

  void debug(String message, {Map<String, Object?>? data}) {
    if (!kDebugMode) return;
    _logger.d(_buildMessage(message, data));
  }

  void info(String message, {Map<String, Object?>? data}) {
    if (!kDebugMode) return;
    _logger.i(_buildMessage(message, data));
  }

  void warn(String message, {Map<String, Object?>? data}) {
    if (!kDebugMode) return;
    _logger.w(_buildMessage(message, data));
  }

  void error(
    String message, {
    Map<String, Object?>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;
    _logger.e(
      _buildMessage(message, data),
      error: error,
      stackTrace: stackTrace,
    );
  }

  String _buildMessage(String message, Map<String, Object?>? data) {
    final buffer = StringBuffer(sanitize(message));
    if (data != null && data.isNotEmpty) {
      final sanitisedPayload = data.map(
        (key, value) => MapEntry(key, _sanitizeValue(value)),
      );
      buffer.write(' | data=$sanitisedPayload');
    }
    return buffer.toString();
  }

  Object? _sanitizeValue(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is num || value is bool) {
      return value;
    }
    if (value is String) {
      return sanitize(value);
    }
    if (value is Map<String, Object?>) {
      return value.map((key, nested) => MapEntry(key, _sanitizeValue(nested)));
    }
    if (value is Iterable) {
      return value.map(_sanitizeValue).toList(growable: false);
    }
    return sanitize(value.toString());
  }

  /// Public so tests can verify sanitisation behaviour.
  @visibleForTesting
  static String sanitize(String input) {
    return input
        .replaceAllMapped(_ipv4Regex, (_) => '***.***.***.***')
        .replaceAllMapped(_ipv6Regex, (_) => '****:****:****:****')
        .replaceAllMapped(_macRegex, (_) => 'XX:XX:XX:XX:XX:XX');
  }
}
