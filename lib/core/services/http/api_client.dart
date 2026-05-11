import 'package:dio/dio.dart';

import 'interceptors/api_interceptor.dart';
 import 'package:dio/dio.dart';
 import 'dart:convert';

 import 'package:flutter/foundation.dart';
class ApiClient {
  // Singleton
  static ApiClient? _instance;
  static ApiClient get instance => _instance ??= ApiClient._init();

  ApiClient._init();

  // Dio Object & Configuration
  final BaseOptions _options = BaseOptions(
    baseUrl: 'https://api.ma7loula.com/api/v1/',
    validateStatus: (status) => status! < 500,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'App': 'bt-vendor',
    },
  );

  Dio? _dio;

  Dio get dio => _dio ??= Dio(_options)
    ..interceptors.addAll([
      ApiInterceptors(),
      CurlInterceptor(),
    ]);
}


class CurlInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) {
    final curl = _createCurl(options);

    debugPrint('╔═══════════════════════════════════════════');
    debugPrint('📌 CURL');
    debugPrint(curl);
    debugPrint('╚═══════════════════════════════════════════');

    super.onRequest(options, handler);
  }

  String _createCurl(RequestOptions options) {
    final buffer = StringBuffer();

    buffer.write('curl');

    // METHOD
    buffer.write(' -X ${options.method}');

    // HEADERS
    options.headers.forEach((key, value) {
      buffer.write(" -H '$key: $value'");
    });

    // DATA
    if (options.data != null) {
      final data = options.data is String
          ? options.data
          : jsonEncode(options.data);

      buffer.write(" -d '$data'");
    }

    // URL
    buffer.write(" '${options.uri}'");

    return buffer.toString();
  }
}