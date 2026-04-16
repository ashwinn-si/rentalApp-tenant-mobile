import 'package:dio/dio.dart';

import '../storage/secure_storage.dart';
import 'api_response.dart';
import '../constants/constants.dart';

const String _apiUrlFromEnv = String.fromEnvironment('API_URL');

class DioClient {
  DioClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _apiUrlFromEnv.isNotEmpty ? _apiUrlFromEnv : baseURL,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
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
      final parsed =
          fromJson != null ? fromJson(response.data) : response.data as T;
      return ApiResponse.success(parsed, response.statusCode);
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
