import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/constants/api_endpoints.dart';

class AuthUser {
  final String id;
  final String name;
  final String email;
  final String role; // 'student', 'mentor', 'college', 'recruiter', 'admin'
  final String? phone;
  final String token;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    required this.token,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json, String token, {String defaultRole = 'student'}) {
    final dataObj = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : <String, dynamic>{};
    final userObj = dataObj['student'] ??
        dataObj['college'] ??
        dataObj['admin'] ??
        dataObj['user'] ??
        dataObj['recruiter'] ??
        json['student'] ??
        json['college'] ??
        json['admin'] ??
        json['user'] ??
        json['recruiter'] ??
        (dataObj.isNotEmpty ? dataObj : json);

    return AuthUser(
      id: userObj['_id']?.toString() ?? userObj['id']?.toString() ?? 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: userObj['name']?.toString() ?? userObj['fullName']?.toString() ?? 'C2C User',
      email: userObj['email']?.toString() ?? '',
      role: userObj['role']?.toString().toLowerCase() ?? defaultRole.toLowerCase(),
      phone: userObj['phone']?.toString(),
      token: token,
    );
  }
}

/// Result of a credentials-based sign-in attempt.
///
/// Either [user] is present (full authentication), or [pendingTwoFactorToken]
/// is present — meaning the account has 2FA enabled and the caller must
/// complete a verification code step before authentication finishes.
class AuthLoginResult {
  final AuthUser? user;
  final String? pendingTwoFactorToken;

  const AuthLoginResult({this.user, this.pendingTwoFactorToken});
}

class AuthRepository {
  final DioClient _dioClient;
  final FlutterSecureStorage _storage;

  AuthRepository({DioClient? dioClient, FlutterSecureStorage? storage})
      : _dioClient = dioClient ?? DioClient(),
        _storage = storage ?? const FlutterSecureStorage();

  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
  }) async {
    final cleanRole = role.trim().toLowerCase();
    final domainHost = email.contains('@') ? email.split('@')[1] : 'college.edu';

    try {
      String endpoint = ApiEndpoints.register;
      final payload = <String, dynamic>{
        'name': name.trim(),
        'fullName': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      };

      if (cleanRole == 'admin') {
        endpoint = ApiEndpoints.adminRegister;
        payload['role'] = 'admin';
      } else if (cleanRole == 'college') {
        endpoint = ApiEndpoints.collegeRegister;
        payload['address'] = 'Main Campus';
        payload['website'] = 'https://$domainHost';
        payload['university'] = name.trim();
      } else {
        // Backend /auth/register requires role to be 'student' or omitted
        payload['role'] = 'student';
      }

      final response = await _dioClient.instance.post(
        endpoint,
        data: payload,
      );

      final data = response.data is Map<String, dynamic> ? response.data as Map<String, dynamic> : <String, dynamic>{};
      final dataMap = data['data'] is Map<String, dynamic> ? data['data'] as Map<String, dynamic> : <String, dynamic>{};
      
      String? token = data['token']?.toString() ?? dataMap['token']?.toString();

      // Backend admin/college register endpoints create the document but do not return a JWT token.
      // Perform automatic seamless login to fetch a real, valid JWT token!
      if (token == null || token.isEmpty || cleanRole == 'admin' || cleanRole == 'college') {
        final loginResult = await login(
          email: email,
          password: password,
          role: cleanRole,
        );
        if (loginResult.user != null) {
          return loginResult.user!;
        }
      }

      final authUser = AuthUser.fromJson(data, token ?? '', defaultRole: cleanRole);
      await _persistUser(authUser);
      return authUser;
    } on DioException catch (dioErr) {
      final errorMsg = _extractErrorMessage(dioErr);
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<AuthLoginResult> login({
    required String email,
    required String password,
    String? role,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    // If a specific role is explicitly provided and not 'auto', perform targeted login
    if (role != null && role.isNotEmpty && role.toLowerCase() != 'auto') {
      return _loginTargeted(
        email: cleanEmail,
        password: password,
        role: role.toLowerCase(),
      );
    }

    // Smart Auto-Detection Waterfall Login (Zero Backend Changes)
    // Step 1: Attempt Student / General Auth Endpoint (/auth/login)
    try {
      return await _loginTargeted(
        email: cleanEmail,
        password: password,
        role: 'student',
      );
    } on DioException catch (dioErr) {
      if (_isNetworkConnectionError(dioErr)) {
        throw Exception(_extractErrorMessage(dioErr));
      }
      // If 400/401/404, credentials were not found in student collection, proceed to college check
    } catch (_) {}

    // Step 2: Attempt College Auth Endpoint (/college/login)
    try {
      return await _loginTargeted(
        email: cleanEmail,
        password: password,
        role: 'college',
      );
    } on DioException catch (dioErr) {
      if (_isNetworkConnectionError(dioErr)) {
        throw Exception(_extractErrorMessage(dioErr));
      }
      // If 400/401/404, credentials were not found in college collection, proceed to admin check
    } catch (_) {}

    // Step 3: Attempt Admin Auth Endpoint (/admin/login)
    try {
      return await _loginTargeted(
        email: cleanEmail,
        password: password,
        role: 'admin',
      );
    } on DioException catch (dioErr) {
      if (_isNetworkConnectionError(dioErr)) {
        throw Exception(_extractErrorMessage(dioErr));
      }
    } catch (_) {}

    // If none of the module endpoints matched
    throw Exception('Invalid email or password. Please check your credentials or register for an account.');
  }

  bool _isNetworkConnectionError(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout;
  }

  Future<AuthLoginResult> _loginTargeted({
    required String email,
    required String password,
    required String role,
  }) async {
    final cleanRole = role.trim().toLowerCase();
    String endpoint = ApiEndpoints.login;
    final payload = <String, dynamic>{
      'email': email,
      'password': password,
    };

    if (cleanRole == 'admin') {
      endpoint = ApiEndpoints.adminLogin;
      payload['role'] = 'admin';
    } else if (cleanRole == 'college') {
      endpoint = ApiEndpoints.collegeLogin;
    } else {
      payload['role'] = 'student';
    }

    final response = await _dioClient.instance.post(
      endpoint,
      data: payload,
    );

    final data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : <String, dynamic>{};
    final dataMap = data['data'] is Map<String, dynamic>
        ? data['data'] as Map<String, dynamic>
        : <String, dynamic>{};

    // Account has two-factor authentication enabled
    if (dataMap['twoFactorRequired'] == true || data['twoFactorRequired'] == true) {
      final pendingToken = (dataMap['pendingToken'] ?? data['pendingToken'])?.toString();
      if (pendingToken != null && pendingToken.isNotEmpty) {
        return AuthLoginResult(pendingTwoFactorToken: pendingToken);
      }
    }

    final token = data['token']?.toString() ?? dataMap['token']?.toString() ?? '';
    final authUser = AuthUser.fromJson(data, token, defaultRole: cleanRole);
    await _persistUser(authUser);
    return AuthLoginResult(user: authUser);
  }

  /// Completes a two-factor-authenticated sign-in using an existing login
  /// session (see [login]) plus the current 6-digit authenticator code.
  Future<AuthUser> completeTwoFactor({
    required String pendingToken,
    required String code,
    String role = 'student',
  }) async {
    try {
      final response = await _dioClient.instance.post(
        ApiEndpoints.login2faVerify,
        data: {
          'pendingToken': pendingToken,
          'code': code.trim(),
        },
      );

      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final token = data['token']?.toString() ?? data['data']?['token']?.toString() ?? 'token_${DateTime.now().millisecondsSinceEpoch}';
      final authUser = AuthUser.fromJson(data, token, defaultRole: role);
      await _persistUser(authUser);
      return authUser;
    } on DioException catch (dioErr) {
      throw Exception(_extractErrorMessage(dioErr));
    } catch (e) {
      throw Exception('Two-factor verification failed: ${e.toString()}');
    }
  }

  /// Reactivates a deactivated account and signs the student straight in.
  Future<AuthUser> reactivateAccount({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.instance.post(
        ApiEndpoints.loginReactivate,
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );

      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final token = data['token']?.toString() ?? data['data']?['token']?.toString() ?? 'token_${DateTime.now().millisecondsSinceEpoch}';
      final authUser = AuthUser.fromJson(data, token);
      await _persistUser(authUser);
      return authUser;
    } on DioException catch (dioErr) {
      throw Exception(_extractErrorMessage(dioErr));
    } catch (e) {
      throw Exception('Account reactivation failed: ${e.toString()}');
    }
  }

  Future<AuthUser?> getStoredUser() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null || token.isEmpty) return null;

      final id = await _storage.read(key: 'user_id') ?? 'usr_stored';
      final name = await _storage.read(key: 'user_name') ?? 'C2C User';
      final email = await _storage.read(key: 'user_email') ?? '';
      final role = await _storage.read(key: 'user_role') ?? 'student';
      final phone = await _storage.read(key: 'user_phone');

      return AuthUser(
        id: id,
        name: name,
        email: email,
        role: role,
        phone: phone,
        token: token,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _storage.delete(key: 'jwt_token');
      await _storage.delete(key: 'user_id');
      await _storage.delete(key: 'user_name');
      await _storage.delete(key: 'user_email');
      await _storage.delete(key: 'user_role');
      await _storage.delete(key: 'user_phone');
    } catch (e) {
      debugPrint('Logout storage clearance notice: $e');
    }
  }

  Future<void> _persistUser(AuthUser user) async {
    await _storage.write(key: 'jwt_token', value: user.token);
    await _storage.write(key: 'user_id', value: user.id);
    await _storage.write(key: 'user_name', value: user.name);
    await _storage.write(key: 'user_email', value: user.email);
    await _storage.write(key: 'user_role', value: user.role);
    if (user.phone != null) {
      await _storage.write(key: 'user_phone', value: user.phone);
    }
  }

  String _extractErrorMessage(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.unknown) {
      return 'Unable to connect to backend server (${ApiEndpoints.baseUrl}). Please verify that your Node.js backend server is running.';
    }

    if (err.response?.data != null && err.response?.data is Map) {
      final map = err.response?.data as Map;
      if (map.containsKey('message') && map['message'] != null) {
        return map['message'].toString();
      }
      if (map.containsKey('error') && map['error'] != null) {
        return map['error'].toString();
      }
    }
    
    switch (err.response?.statusCode) {
      case 400:
        return 'Invalid details provided. Please check your inputs.';
      case 401:
        return 'Invalid email address or password.';
      case 404:
        return 'Authentication service endpoint not found.';
      case 409:
        return 'An account with this email address already exists.';
      case 500:
        return 'Server error encountered. Please try again later.';
      default:
        return 'Network request failed. Code: ${err.response?.statusCode ?? "Unknown"}';
    }
  }
}
