import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:get_storage/get_storage.dart';
import '../constants/api_constants.dart';
import '../constants/storage_keys.dart';
import '../services/auth_service.dart';
import '../services/lock_service.dart';

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
  final _legacyBox = GetStorage();
  final _authBox = GetStorage(StorageKeys.authContainer);

  static final Dio _refreshDio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'x-app-source': 'goldvikaone',
        'x-platform': 'GoldVikaone Mobile App',
      },
    ),
  );

  static Completer<String?>? _refreshCompleter;
  static bool _isLoggingOut = false;

  String? _readCurrentToken() {
    if (Get.isRegistered<AuthService>()) {
      final t = Get.find<AuthService>().token;
      if (t != null && t.isNotEmpty) return t;
    }
    return _authBox.read<String>(StorageKeys.token) ??
        _legacyBox.read<String>(StorageKeys.token);
  }

  String? _readRefreshToken() {
    if (Get.isRegistered<AuthService>()) {
      final rt = Get.find<AuthService>().refreshToken;
      if (rt != null && rt.isNotEmpty) return rt;
    }
    return _authBox.read<String>(StorageKeys.refreshToken) ??
        _legacyBox.read<String>(StorageKeys.refreshToken);
  }

  bool _isPublicAuthPath(String path) {
    return path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/verify-credentials') ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/reset-password') ||
        path.contains('/auth/forgot-password') ||
        path.contains('/otp/');
  }

  Future<String?> _performTokenRefresh() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    final completer = Completer<String?>();
    _refreshCompleter = completer;

    try {
      final rt = _readRefreshToken();
      if (rt == null || rt.isEmpty) {
        completer.complete(null);
        return null;
      }

      final res = await _refreshDio.post(
        ApiConstants.refresh,
        data: {'refreshToken': rt},
      );

      final data = res.data;
      if (res.statusCode == 200 &&
          data is Map &&
          data['success'] == true &&
          data['token'] is String &&
          (data['token'] as String).trim().isNotEmpty) {
        final newToken = (data['token'] as String).trim();
        if (Get.isRegistered<AuthService>()) {
          await Get.find<AuthService>().saveRefreshedSession(data);
        } else {
          await _authBox.write(StorageKeys.token, newToken);
          if (data['refreshToken'] is String) {
            await _authBox.write(StorageKeys.refreshToken, data['refreshToken']);
          }
          await _authBox.save();
        }
        completer.complete(newToken);
        return newToken;
      }

      completer.complete(null);
      return null;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      // Only force logout when refresh token itself is explicitly rejected (401/403).
      // Transient network timeouts or 5xx errors must NOT log the user out!
      if (status == 401 || status == 403) {
        await _forceLogout();
      }
      completer.complete(null);
      return null;
    } catch (_) {
      completer.complete(null);
      return null;
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<void> _forceLogout() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;
    try {
      if (Get.isRegistered<AuthService>()) {
        await Get.find<AuthService>().logout();
      } else {
        await _authBox.remove(StorageKeys.token);
        await _authBox.remove(StorageKeys.refreshToken);
        await _authBox.remove(StorageKeys.user);
        await _authBox.save();
        await _legacyBox.remove(StorageKeys.token);
        await _legacyBox.remove(StorageKeys.refreshToken);
        await _legacyBox.remove(StorageKeys.user);
      }
      if (Get.isRegistered<LockService>()) {
        LockService.to.disableLock();
      }
      if (Get.key.currentContext != null && Get.currentRoute != '/login') {
        Get.offAllNamed('/login');
      }
    } finally {
      _isLoggingOut = false;
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _readCurrentToken();
    options.headers['x-app-source'] = 'goldvikaone';
    options.headers['x-platform'] = 'GoldVikaone Mobile App';
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final reqOptions = err.requestOptions;

    if (statusCode != 401 ||
        _isPublicAuthPath(reqOptions.path) ||
        reqOptions.extra['_retried'] == true ||
        reqOptions.headers['Authorization'] == null) {
      handler.next(err);
      return;
    }

    // Extract Bearer token used by this failed request to avoid logging out a newer login
    final sentAuth = reqOptions.headers['Authorization']?.toString() ?? '';
    final sentToken = sentAuth.startsWith('Bearer ') ? sentAuth.substring(7).trim() : '';

    final refreshedToken = await _performTokenRefresh();
    if (refreshedToken != null && refreshedToken.isNotEmpty) {
      try {
        final retryOptions = reqOptions.copyWith(
          headers: {
            ...reqOptions.headers,
            'Authorization': 'Bearer $refreshedToken',
          },
          extra: {
            ...reqOptions.extra,
            '_retried': true,
          },
        );
        final retryResponse = await ApiClient.instance.fetch(retryOptions);
        handler.resolve(retryResponse);
        return;
      } on DioException catch (retryErr) {
        handler.next(retryErr);
        return;
      }
    }

    // No refresh token was present (legacy session) AND the failing token matches our active token:
    final rt = _readRefreshToken();
    final activeTok = _readCurrentToken();
    if ((rt == null || rt.isEmpty) &&
        activeTok != null &&
        activeTok.isNotEmpty &&
        sentToken == activeTok) {
      await _forceLogout();
    }

    handler.next(err);
  }
}