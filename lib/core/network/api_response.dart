class ApiResponse<T> {
  final T? data;
  final String? error;
  final int? statusCode;

  const ApiResponse({this.data, this.error, this.statusCode});

  bool get isSuccess => data != null && error == null;

  factory ApiResponse.success(T data, [int? statusCode]) {
    return ApiResponse(data: data, statusCode: statusCode);
  }

  factory ApiResponse.failure(String error, [int? statusCode]) {
    return ApiResponse(error: error, statusCode: statusCode);
  }
}
