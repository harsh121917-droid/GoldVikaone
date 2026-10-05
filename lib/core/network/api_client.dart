import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:get_storage/get_storage.dart';
import '../constants/api_constants.dart';
import '../constants/storage_keys.dart';

class ApiClient {
  ApiClient._();
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'x-app-source': 'goldvikaone',
        'x-platform': 'GoldVikaone Mobile App',
      },
    ),
  )..interceptors.add(_AuthInterceptor());
  static Dio get instance => _dio;

  /// Formats any error (including DioException) into a clean, human-readable message.
  /// Never leaks technical jargon like "DioException [bad response]" or raw status traces.
  static String formatError(dynamic error, {String fallback = 'Something went wrong. Please try again.'}) {
    if (error == null) return fallback;

    if (error is Map) {
      final msg = _extractFromMap(error);
      if (msg != null && msg.isNotEmpty) return _sanitizeMessage(msg);
      return fallback;
    }

    if (error is DioException) {
      // 1. Try to extract message from response data
      final response = error.response;
      if (response != null && response.data != null) {
        dynamic data = response.data;
        if (data is String) {
          final trimmed = data.trim();
          if ((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
              (trimmed.startsWith('[') && trimmed.endsWith(']'))) {
            try {
              data = jsonDecode(trimmed);
            } catch (_) {}
          }
        }

        if (data is Map) {
          final msg = _extractFromMap(data);
          if (msg != null && msg.isNotEmpty) return _sanitizeMessage(msg);
        } else if (data is String && data.isNotEmpty) {
          if (!data.contains('<html') && !data.contains('<!DOCTYPE') && data.length < 300) {
            final cleaned = _sanitizeMessage(data);
            if (cleaned.isNotEmpty) return cleaned;
          }
        }
      }

      // 2. Check HTTP status code
      final code = error.response?.statusCode;
      if (code != null) {
        switch (code) {
          case 400:
            return 'Invalid request details. Please check your information and try again.';
          case 401:
            return 'Your session has expired. Please log in again.';
          case 403:
            return 'You do not have permission to perform this action.';
          case 404:
            return 'The requested fund or exchange service was not found.';
          case 409:
            return 'Request conflict. This operation may already be in progress.';
          case 422:
            return 'Unable to process request. Please verify the submitted details.';
          case 500:
            return 'Exchange service encountered an error. Please try again later.';
          case 502:
          case 503:
          case 504:
            return 'Exchange server is temporarily unavailable. Please try again shortly.';
        }
      }

      // 3. Check DioExceptionType
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Connection timed out. Please check your internet connection.';
        case DioExceptionType.sendTimeout:
          return 'Request timed out while sending data. Please check your network.';
        case DioExceptionType.receiveTimeout:
          return 'Server took too long to respond. Please try again.';
        case DioExceptionType.connectionError:
          return 'Unable to connect to server. Please check your internet connection.';
        case DioExceptionType.badCertificate:
          return 'Secure connection error. Please try again later.';
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        default:
          break;
      }
    }

    // 4. General exception/string cleanup
    final raw = error.toString().trim();
    final lower = raw.toLowerCase();

    if (lower.contains('socketexception') ||
        lower.contains('failed host lookup') ||
        lower.contains('network is unreachable') ||
        lower.contains('connection refused') ||
        lower.contains('connection closed')) {
      return 'No internet connection. Please check your network settings.';
    }
    if (lower.contains('timeoutexception')) {
      return 'Connection timed out. Please try again.';
    }

    final cleaned = _sanitizeMessage(raw);
    if (cleaned.isEmpty ||
        cleaned.toLowerCase().contains('dioexception') ||
        cleaned.toLowerCase().contains('the request returned an invalid status code') ||
        cleaned.toLowerCase().contains('instance of') ||
        cleaned == 'null') {
      return fallback;
    }

    return cleaned;
  }

  static String? _extractFromMap(Map data) {
    // 1. Direct message
    if (data['message'] != null && data['message'].toString().trim().isNotEmpty) {
      return data['message'].toString().trim();
    }
    // 2. data.exchangeMessage or data.message or data.error
    if (data['data'] is Map) {
      final inner = data['data'] as Map;
      if (inner['exchangeMessage'] != null && inner['exchangeMessage'].toString().trim().isNotEmpty) {
        return inner['exchangeMessage'].toString().trim();
      }
      if (inner['message'] != null && inner['message'].toString().trim().isNotEmpty) {
        return inner['message'].toString().trim();
      }
      if (inner['error'] != null && inner['error'].toString().trim().isNotEmpty) {
        return inner['error'].toString().trim();
      }
    }
    // 3. error field
    if (data['error'] != null) {
      if (data['error'] is String && data['error'].toString().trim().isNotEmpty) {
        return data['error'].toString().trim();
      }
      if (data['error'] is Map) {
        final errMap = data['error'] as Map;
        if (errMap['message'] != null && errMap['message'].toString().trim().isNotEmpty) {
          return errMap['message'].toString().trim();
        }
      }
    }
    // 4. msg
    if (data['msg'] != null && data['msg'].toString().trim().isNotEmpty) {
      return data['msg'].toString().trim();
    }
    // 5. detail
    if (data['detail'] != null && data['detail'].toString().trim().isNotEmpty) {
      return data['detail'].toString().trim();
    }
    // 6. errors
    if (data['errors'] != null) {
      if (data['errors'] is List && (data['errors'] as List).isNotEmpty) {
        return (data['errors'] as List).first.toString().trim();
      }
      if (data['errors'] is Map && (data['errors'] as Map).isNotEmpty) {
        return (data['errors'] as Map).values.first.toString().trim();
      }
    }
    return null;
  }

  static String _sanitizeMessage(String raw) {
    var s = raw;
    s = s.replaceAll(RegExp(r'^DioException\s*\[.*?\]:\s*', caseSensitive: false), '');
    s = s.replaceAll(RegExp(r'^DioException:\s*', caseSensitive: false), '');
    s = s.replaceAll(RegExp(r'^Exception:\s*', caseSensitive: false), '');
    s = s.replaceAll(RegExp(r'^Error:\s*', caseSensitive: false), '');
    s = s.trim();

    if (s.toLowerCase().startsWith('the request returned an invalid status code')) {
      return '';
    }
    if (s.toLowerCase().contains('dioexception')) {
      return '';
    }
    return s;
  }
}

class _AuthInterceptor extends Interceptor {
  final _box = GetStorage();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _box.read<String>(StorageKeys.token);
    options.headers['x-app-source'] = 'goldvikaone';
    options.headers['x-platform'] = 'GoldVikaone Mobile App';
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      GetStorage().remove(StorageKeys.token);
      GetStorage().remove(StorageKeys.user);
      Get.offAllNamed('/login');
    }
    handler.next(err);
  }
}