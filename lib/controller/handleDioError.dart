import 'package:dio/dio.dart';

String handleDioError(DioException error) {
  if (error.response != null) {
    final data = error.response?.data;

    if (data is Map && data['message'] != null) {
      return data['message'];
    }

    switch (error.response?.statusCode) {
      case 400:
        return "Bad request";
      case 401:
        return "Unauthorized";
      case 403:
        return "Forbidden";
      case 500:
        return "Server error";
    }
  }

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
      return "Connection timeout";
    case DioExceptionType.receiveTimeout:
      return "Server not responding";
    case DioExceptionType.connectionError:
      return "No internet connection";
    default:
      return "Something went wrong";
  }
}