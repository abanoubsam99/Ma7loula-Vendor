import 'package:dio/dio.dart';

class SessionManager {

  static bool isLoggedOut = false;

  static CancelToken cancelToken = CancelToken();

  static void resetSession() {

    isLoggedOut = false;

    cancelToken = CancelToken();
  }

  static void logout() {

    isLoggedOut = true;

    cancelToken.cancel("User logged out");

    cancelToken = CancelToken();
  }
}