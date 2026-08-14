import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_endpoints.dart';
import 'api_interceptors.dart';

class DioClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        contentType: Headers.jsonContentType,
        headers: const {
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': '69420',
        },
      ),
    );

    _dio.interceptors.add(AuthInterceptor(_storage));
    _dio.interceptors.add(
      LogInterceptor(
        requestHeader: false,
        responseHeader: false,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  Dio get instance => _dio;
}
