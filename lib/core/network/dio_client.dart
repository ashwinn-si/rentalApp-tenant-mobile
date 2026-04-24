import 'dart:developer' as developer;

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
    Object? data,
    Map<String, dynamic>? queryParams,
  }) async {
    developer.log(
        '[DioClient.request] START - method=$method, path=$path, hasFromJson=${fromJson != null}, queryParams=$queryParams, dataType=${data.runtimeType}');

    try {
      developer.log('[DioClient.request] Making HTTP request...');
      final response = await _dio.request<dynamic>(
        path,
        options: Options(method: method),
        data: data,
        queryParameters: queryParams,
      );

      final responseContentType =
          response.headers.value(Headers.contentTypeHeader);
      developer.log(
          '[DioClient.request] Response received - statusCode=${response.statusCode}, contentType=$responseContentType, dataType=${response.data.runtimeType}');

      if (kDebugMode) {
        debugPrint(
          '[API] $method $path -> ${response.statusCode}\nresponse: ${response.data}',
        );
      }

      final statusCode = response.statusCode;
      final isSuccess = statusCode != null &&
          (statusCode >= 200 && statusCode < 300 || statusCode == 304);

      developer.log(
          '[DioClient.request] Status check - statusCode=$statusCode, isSuccess=$isSuccess');
      if (kDebugMode) {
        debugPrint(
            '[DioClient] Status check - statusCode=$statusCode, isSuccess=$isSuccess, responseData=${response.data}');
      }

      if (!isSuccess) {
        final responseData = response.data;
        final message = (responseData is Map<String, dynamic> &&
                responseData['message'] != null)
            ? responseData['message'].toString()
            : 'Request failed (status: $statusCode)';

        developer.log(
            '[DioClient.request] FAILED - statusCode=$statusCode, message=$message');
        if (kDebugMode) {
          debugPrint('[DioClient] Returning failure - message=$message');
        }
        return ApiResponse.failure(message, statusCode);
      }

      developer.log('[DioClient.request] Parsing response with fromJson...');
      try {
        final parsed =
            fromJson != null ? fromJson(response.data) : response.data as T;
        developer.log(
            '[DioClient.request] SUCCESS - parsed type=${parsed.runtimeType}');
        return ApiResponse.success(parsed, statusCode);
      } catch (parseError, parseStack) {
        developer
            .log('[DioClient.request] PARSE ERROR - $parseError\n$parseStack');
        return ApiResponse.failure(
            'Failed to parse response: $parseError', statusCode);
      }
    } on DioException catch (e) {
      developer.log(
          '[DioClient.request] DioException - type=${e.type}, statusCode=${e.response?.statusCode}, message=${e.message}');
      final message = (e.response?.data is Map<String, dynamic> &&
              e.response?.data['message'] != null)
          ? e.response!.data['message'].toString()
          : (e.message ?? 'Request failed');
      developer
          .log('[DioClient.request] DioException returning failure - $message');
      return ApiResponse.failure(message, e.response?.statusCode);
    } catch (e, stack) {
      developer.log('[DioClient.request] GENERIC EXCEPTION - $e\n$stack');
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
    Object? data,
  }) {
    return request<T>(
      method: 'POST',
      path: path,
      fromJson: fromJson,
      data: data,
    );
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    T Function(dynamic json)? fromJson,
    Object? data,
  }) {
    return request<T>(
      method: 'PUT',
      path: path,
      fromJson: fromJson,
      data: data,
    );
  }
}
