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
    debugPrint('📌 CURL REQUEST');
    debugPrint(curl);
    debugPrint('╚═══════════════════════════════════════════');

    super.onRequest(options, handler);
  }

  @override
  void onResponse(
      Response response,
      ResponseInterceptorHandler handler,
      ) {
    debugPrint('╔═══════════════════════════════════════════');
    debugPrint('✅ API RESPONSE');
    debugPrint('URL: ${response.requestOptions.uri}');
    debugPrint('STATUS CODE: ${response.statusCode}');

    try {
      const encoder = JsonEncoder.withIndent('  ');
      final prettyJson = encoder.convert(response.data);
      debugPrint(prettyJson);
    } catch (e) {
      debugPrint(response.data.toString());
    }

    debugPrint('╚═══════════════════════════════════════════');

    super.onResponse(response, handler);
  }

  @override
  void onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) {
    debugPrint('╔═══════════════════════════════════════════');
    debugPrint('❌ API ERROR');
    debugPrint('URL: ${err.requestOptions.uri}');
    debugPrint('STATUS CODE: ${err.response?.statusCode}');
    debugPrint('MESSAGE: ${err.message}');

    if (err.response?.data != null) {
      try {
        const encoder = JsonEncoder.withIndent('  ');
        final prettyJson = encoder.convert(err.response?.data);
        debugPrint(prettyJson);
      } catch (e) {
        debugPrint(err.response?.data.toString());
      }
    }

    debugPrint('╚═══════════════════════════════════════════');

    super.onError(err, handler);
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
      String dataStr = "";
      if (options.data is String) {
        dataStr = options.data;
      } else if (options.data is FormData) {
        dataStr = "FormData(...)";
      } else {
        try {
          dataStr = jsonEncode(options.data);
        } catch (e) {
          dataStr = options.data.toString();
        }
      }

      buffer.write(" -d '$dataStr'");
    }

    // URL
    buffer.write(" '${options.uri}'");

    return buffer.toString();
  }
}