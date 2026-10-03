import 'package:dio/dio.dart';

/// Thin HTTPS-only wrapper around Dio.
///
/// Security notes:
///  * The base URL must be https:// (a plain http:// URL is rejected at startup).
///  * Redirects are capped, and Android's network security config also blocks
///    cleartext traffic, so a redirect can never downgrade to http.
///  * Server responses are type-checked before use.
class ApiClient {
  ApiClient({String? baseUrl})
      : _dio = Dio(BaseOptions(
          baseUrl: _validated(baseUrl ??
              const String.fromEnvironment('API_BASE_URL',
                  defaultValue: 'https://sarmaxstreams.vercel.app')),
          connectTimeout: const Duration(seconds: 12),
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
          maxRedirects: 3,
          headers: const {'Accept': 'application/json'},
        ));

  final Dio _dio;

  static String _validated(String url) {
    final trimmed = url.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      throw ArgumentError('API_BASE_URL must be a valid https:// URL');
    }
    return trimmed.replaceFirst(RegExp(r'/+$'), '');
  }

  String get baseUrl => _dio.options.baseUrl;

  Map<String, dynamic> _asMap(Object? data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const FormatException('Unexpected server response');
  }

  Future<Map<String, dynamic>> postJson(
      String path, Map<String, dynamic> body) async {
    final response = await _dio.post(path,
        data: body, options: Options(contentType: 'application/json'));
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> getJson(String path,
      [Map<String, dynamic>? query]) async {
    final response = await _dio.get(path, queryParameters: query);
    return _asMap(response.data);
  }

  String absolute(String path) => baseUrl + path;
}
