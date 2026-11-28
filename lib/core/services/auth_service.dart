import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/api_constants.dart';
import '../constants/storage_keys.dart';
import '../network/api_client.dart';
import '../../data/models/user_model.dart';

class AuthService {
  static const String _backupFileName = 'vika_auth_session.json';

  final _dio = ApiClient.instance;
  final _authBox = GetStorage(StorageKeys.authContainer);
  final _legacyBox = GetStorage();

  String? _cachedToken;
  String? _cachedRefreshToken;
  Map<String, dynamic>? _cachedUserMap;
  Future<void> _fileOpChain = Future.value();

  Future<void> init() async {
    final boxToken = _authBox.read<String>(StorageKeys.token);
    final boxRefresh = _authBox.read<String>(StorageKeys.refreshToken);
    final boxUser = _asStringMap(_authBox.read(StorageKeys.user));

    final legacyToken = _legacyBox.read<String>(StorageKeys.token);
    final legacyRefresh = _legacyBox.read<String>(StorageKeys.refreshToken);
    final legacyUser = _asStringMap(_legacyBox.read(StorageKeys.user));

    if (_hasText(boxToken) || _hasText(boxRefresh)) {
      _cachedToken = _hasText(boxToken) ? boxToken : legacyToken;
      _cachedRefreshToken = _hasText(boxRefresh) ? boxRefresh : legacyRefresh;
      _cachedUserMap = boxUser ?? legacyUser;
      if (_cachedUserMap == null) {
        final backup = await _readBackupFile();
        _cachedUserMap = _asStringMap(backup?['user']);
      }
      // Ensure redundant backup file exists for OEM battery-killed devices.
      await _writeBackupFile(
        token: _cachedToken,
        refreshToken: _cachedRefreshToken,
        user: _cachedUserMap,
      );
      return;
    }

    if (_hasText(legacyToken) || _hasText(legacyRefresh)) {
      await _persistSession(
        token: legacyToken,
        refreshToken: legacyRefresh,
        user: legacyUser,
      );
      return;
    }

    final backup = await _readBackupFile();
    if (backup != null) {
      final backupToken = backup['token']?.toString();
      final backupRefresh = backup['refreshToken']?.toString();
      final backupUser = _asStringMap(backup['user']);
      if (_hasText(backupToken) || _hasText(backupRefresh)) {
        await _persistSession(
          token: backupToken,
          refreshToken: backupRefresh,
          user: backupUser,
        );
      }
    }
  }

  String? get token =>
      _cachedToken ??
      _authBox.read<String>(StorageKeys.token) ??
      _legacyBox.read<String>(StorageKeys.token);

  String? get refreshToken =>
      _cachedRefreshToken ??
      _authBox.read<String>(StorageKeys.refreshToken) ??
      _legacyBox.read<String>(StorageKeys.refreshToken);

  bool get isLoggedIn => _hasText(token) || _hasText(refreshToken);

  UserModel? get currentUser {
    final raw =
        _cachedUserMap ??
        _asStringMap(_authBox.read(StorageKeys.user)) ??
        _asStringMap(_legacyBox.read(StorageKeys.user));
    if (raw == null) return null;
    try {
      return UserModel.fromJson(raw);
    } catch (_) {
      return null;
    }
  }

  Future<UserModel> login(String email, String password) async {
    final res = await _dio.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    await _saveAuth(res.data);
    return UserModel.fromJson(res.data['user']);
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String otpRecordId,
    String? phone,
    String? referralCode,
  }) async {
    final res = await _dio.post(
      ApiConstants.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'otpRecordId': otpRecordId,
        if (referralCode != null && referralCode.isNotEmpty) 'referralCode': referralCode,
      },
    );
    await _saveAuth(res.data);
    return UserModel.fromJson(res.data['user']);
  }

  Future<UserModel> registerWithOtp({
    required String name,
    required String phone,
    required String otpRecordId,
    String? email,
    String? referralCode,
  }) async {
    final res = await _dio.post(
      '/auth/register-phone',
      data: {
        'name': name,
        'phone': phone,
        'otpRecordId': otpRecordId,
        if (email != null && email.isNotEmpty) 'email': email,
        if (referralCode != null && referralCode.isNotEmpty) 'referralCode': referralCode,
      },
    );
    await _saveAuth(res.data);
    return UserModel.fromJson(res.data['user']);
  }

  Future<UserModel> loginWithOtp({
    required String phone,
    required String otpRecordId,
    String? email,
  }) async {
    final res = await _dio.post(
      '/auth/login-phone',
      data: {
        'phone': phone,
        'otpRecordId': otpRecordId,
        'email': ?email,
      },
    );
    await _saveAuth(res.data);
    return UserModel.fromJson(res.data['user']);
  }

  Future<UserModel> updateProfile({
    String? name,
    String? email,
  }) async {
    final res = await _dio.patch(
      '/auth/update-profile',
      data: {
        'name': ?name,
        'email': ?email,
      },
    );
    await _saveAuth(res.data);
    return UserModel.fromJson(res.data['user']);
  }

  Future<UserModel> refreshUser() async {
    final res = await _dio.get('/auth/me');
    if (res.data is Map && res.data['success'] == true) {
      await _saveAuth(res.data);
    }
    return currentUser!;
  }

  Future<void> saveRefreshedSession(Map data) async {
    await _saveAuth(data);
  }

  Future<void> logout() async {
    _cachedToken = null;
    _cachedRefreshToken = null;
    _cachedUserMap = null;

    await _authBox.remove(StorageKeys.token);
    await _authBox.remove(StorageKeys.refreshToken);
    await _authBox.remove(StorageKeys.user);
    await _authBox.save();

    await _legacyBox.remove(StorageKeys.token);
    await _legacyBox.remove(StorageKeys.refreshToken);
    await _legacyBox.remove(StorageKeys.user);
    await _legacyBox.save();

    await _deleteBackupFile();
  }

  Future<bool> resetPassword({
    required String phone,
    required String otpRecordId,
    required String newPassword,
    String? email,
  }) async {
    final res = await _dio.post(
      '/auth/reset-password',
      data: {
        'phone': phone,
        'otpRecordId': otpRecordId,
        'newPassword': newPassword,
        'email': ?email,
      },
    );
    return res.data['success'] == true;
  }

  Future<Map<String, dynamic>> initiateForgotPassword({
    required String email,
  }) async {
    final res = await _dio.post(
      '/auth/forgot-password/initiate',
      data: {'email': email},
    );
    return Map<String, dynamic>.from(res.data);
  }

  Future<void> _saveAuth(dynamic data) async {
    if (data is! Map) return;
    final rawToken = data['token']?.toString();
    final rawRefresh = data['refreshToken']?.toString();
    final rawUser = _asStringMap(data['user']);
    await _persistSession(
      token: _hasText(rawToken) ? rawToken : null,
      refreshToken: _hasText(rawRefresh) ? rawRefresh : null,
      user: rawUser,
    );
  }

  Future<void> _persistSession({
    String? token,
    String? refreshToken,
    Map<String, dynamic>? user,
  }) async {
    if (_hasText(token)) {
      _cachedToken = token;
      await _authBox.write(StorageKeys.token, token);
      await _legacyBox.write(StorageKeys.token, token);
    }
    if (_hasText(refreshToken)) {
      _cachedRefreshToken = refreshToken;
      await _authBox.write(StorageKeys.refreshToken, refreshToken);
      await _legacyBox.write(StorageKeys.refreshToken, refreshToken);
    }
    if (user != null) {
      final cleanUser = Map<String, dynamic>.from(user);
      _cachedUserMap = cleanUser;
      await _authBox.write(StorageKeys.user, cleanUser);
      await _legacyBox.write(StorageKeys.user, cleanUser);
    }

    await _authBox.save();
    await _legacyBox.save();
    await _writeBackupFile(
      token: _cachedToken,
      refreshToken: _cachedRefreshToken,
      user: _cachedUserMap,
    );
  }

  Future<T> _enqueueFileOp<T>(Future<T> Function() op) {
    final next = _fileOpChain.then((_) => op(), onError: (_) => op());
    _fileOpChain = next.then((_) {}, onError: (_) {});
    return next;
  }

  Future<File> _getBackupFile() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}${Platform.pathSeparator}$_backupFileName');
  }

  Future<void> _writeBackupFile({
    String? token,
    String? refreshToken,
    Map<String, dynamic>? user,
  }) {
    return _enqueueFileOp(() async {
      try {
        final file = await _getBackupFile();
        final tmpFile = File('${file.path}.tmp');
        final payload = <String, dynamic>{
          if (_hasText(token)) 'token': token,
          if (_hasText(refreshToken)) 'refreshToken': refreshToken,
          'user': ?user,
        };
        await tmpFile.writeAsString(jsonEncode(payload), flush: true);
        try {
          await tmpFile.rename(file.path);
        } on FileSystemException {
          if (await file.exists()) {
            await file.delete();
          }
          await tmpFile.rename(file.path);
        }
      } catch (e) {
        debugPrint('AuthService backup write error: $e');
      }
    });
  }

  Future<Map<String, dynamic>?> _readBackupFile() {
    return _enqueueFileOp(() async {
      try {
        final file = await _getBackupFile();
        if (!await file.exists()) return null;
        final raw = await file.readAsString();
        if (raw.trim().isEmpty) return null;
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (e) {
        debugPrint('AuthService backup read error: $e');
      }
      return null;
    });
  }

  Future<void> _deleteBackupFile() {
    return _enqueueFileOp(() async {
      try {
        final file = await _getBackupFile();
        if (await file.exists()) {
          await file.delete();
        }
        final tmpFile = File('${file.path}.tmp');
        if (await tmpFile.exists()) {
          await tmpFile.delete();
        }
      } catch (e) {
        debugPrint('AuthService backup delete error: $e');
      }
    });
  }

  bool _hasText(String? value) => value != null && value.isNotEmpty;

  Map<String, dynamic>? _asStringMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  Future<UserModel> uploadProfilePicture(File imageFile) async {
    final fileName = imageFile.path.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      ),
    });

    final res = await _dio.post(
      '/users/profile-picture',
      data: formData,
    );

    if (res.data['success'] == true && res.data['user'] != null) {
      final updatedMap = Map<String, dynamic>.from(res.data['user']);
      await _persistSession(token: token, refreshToken: refreshToken, user: updatedMap);
      return UserModel.fromJson(updatedMap);
    } else {
      throw Exception(res.data['message'] ?? 'Failed to upload profile picture');
    }
  }

  Future<UserModel> removeProfilePicture() async {
    final res = await _dio.delete('/users/profile-picture');
    if (res.data['success'] == true && res.data['user'] != null) {
      final updatedMap = Map<String, dynamic>.from(res.data['user']);
      await _persistSession(token: token, refreshToken: refreshToken, user: updatedMap);
      return UserModel.fromJson(updatedMap);
    } else {
      throw Exception(res.data['message'] ?? 'Failed to remove profile picture');
    }
  }
}
