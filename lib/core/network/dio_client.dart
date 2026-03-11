import 'package:dio/dio.dart';
import 'api_endpoints.dart';

/// A wrapper around the [Dio] package to handle network requests.
///
/// It configures base options like timeouts and adds logging interceptors.
class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        contentType: 'application/json',
      ),
    );
    
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  /// Exposed [Dio] instance for advanced configurations.
  Dio get dio => _dio;

  /// Performs a GET request to the specified [path].
  ///
  /// [queryParameters] can be used to add URL parameters.
  /// [options] provides additional request configuration.
  /// [cancelToken] allows canceling the request.
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException {
      rethrow;
    }
  }
}
