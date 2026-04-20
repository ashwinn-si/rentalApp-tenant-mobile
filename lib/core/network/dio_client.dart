import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../storage/secure_storage.dart';
import 'api_response.dart';
import '../constants/constants.dart';

const String _apiUrlFromEnv = String.fromEnvironment('API_URL');

String _resolveBaseUrl() {
  if (_apiUrlFromEnv.isEmpty) {
    return baseURL;
  }

  final normalized = _apiUrlFromEnv.endsWith('/')
      ? _apiUrlFromEnv.substring(0, _apiUrlFromEnv.length - 1)
      : _apiUrlFromEnv;

  if (normalized.endsWith('/api')) {
    return normalized;
  }

  return '$normalized/api';
}

class DioClient {
  DioClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _resolveBaseUrl(),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        validateStatus: (_) => true,
        headers: <String, dynamic>{'Content-Type': 'application/json'},
      ),
    )..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final storedToken = await SecureStorageService.getToken();
            final token = (_sessionToken?.isNotEmpty ?? false)
                ? _sessionToken
                : storedToken?.trim();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            handler.next(options);
          },
        ),
      );
  }

  static final DioClient instance = DioClient._();

  String? _sessionToken;

  void setSessionToken(String? token) {
    _sessionToken = token?.trim();
  }

  late final Dio _dio;

  Future<ApiResponse<T>> request<T>({
    required String method,
    required String path,
    T Function(dynamic json)? fromJson,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final response = await _dio.request<dynamic>(
        path,
        options: Options(method: method),
        data: data,
        queryParameters: queryParams,
      );

      if (kDebugMode) {
        debugPrint(
          '[API] $method $path -> ${response.statusCode}\nresponse: ${response.data}',
        );
      }

      final statusCode = response.statusCode;
      final isSuccess =
          statusCode != null && statusCode >= 200 && statusCode < 300;
      if (!isSuccess) {
        final responseData = response.data;
        final message = (responseData is Map<String, dynamic> &&
                responseData['message'] != null)
            ? responseData['message'].toString()
            : 'Request failed';
        return ApiResponse.failure(message, statusCode);
      }

      final parsed =
          fromJson != null ? fromJson(response.data) : response.data as T;
      return ApiResponse.success(parsed, statusCode);
    } on DioException catch (e) {
      final message = (e.response?.data is Map<String, dynamic> &&
              e.response?.data['message'] != null)
          ? e.response!.data['message'].toString()
          : (e.message ?? 'Request failed');
      return ApiResponse.failure(message, e.response?.statusCode);
    } catch (e) {
      return ApiResponse.failure(e.toString());
    }
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    T Function(dynamic json)? fromJson,
    Map<String, dynamic>? queryParams,
  }) {
    return request<T>(
      method: 'GET',
      path: path,
      fromJson: fromJson,
      queryParams: queryParams,
    );
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    T Function(dynamic json)? fromJson,
    Map<String, dynamic>? data,
  }) {
    return request<T>(
      method: 'POST',
      path: path,
      fromJson: fromJson,
      data: data,
    );
  }
}
