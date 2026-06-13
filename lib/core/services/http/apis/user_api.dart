import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ma7lola_vendor/model/otp_model.dart';
import 'package:ma7lola_vendor/model/user.dart';

import '../../../../controller/SessionManager.dart';
import '../../../generated/locale_keys.g.dart';
import '../../../utils/helpers.dart';
import '../../secure_storage/secure_storage_keys.dart.dart';
import '../../secure_storage/secure_storage_service.dart';
import '../api_client.dart';
import '../api_endpoints.dart';
import '../interceptors/api_interceptor.dart';
import 'exceptions/api_exception.dart';

class UserApi {
  /// تحديث الـ FCM token على السيرفر للمستخدم الحالي (عند تجديد الـ token
  /// أو عند بدء التشغيل). لا يُرسَل إلا إذا كان المستخدم مسجّل دخول.
  /// ⚠️ راجِع مسار updateFcmTokenEndPoint مع الـ backend.
  static Future<void> updateFcmToken({required String token}) async {
    final authToken = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    if (authToken == null || authToken.isEmpty) return;

    await ApiClient.instance.dio.post(
      updateFcmTokenEndPoint,
      data: {
        "fcm_token": token,
        "platform": Platform.isAndroid ? "Android" : "IOS",
      },
      options: Options(headers: {
        'Authorization': 'Bearer $authToken',
      }),
    );
    log("FCM token updated on server");
  }

  static Future<UserModel> login({
    required String? phone,
    required String? password,
    required Locale locale,
  }) async {

    final storedVendorId = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.vendorID);

    final fcmToken = await FirebaseMessaging.instance.getToken();

    final id = int.tryParse(storedVendorId ?? '');

    final String api = (id == 1)
        ? loginEndPoint
        : (id == 2)
        ? loginCarPartsEndPoint
        : (id == 3)
        ? loginWinchEndPoint
        : loginEmergencyEndPoint;

    try {

      final response = await ApiClient.instance.dio.post(
        api,
        data: {
          "phone": phone,
          "password": password,
          "fcm_token": fcmToken,
          "platform": Platform.isAndroid ? "Android" : "IOS",
        },
        options: Options(headers: {
          'lang': locale.languageCode,
        }),
      );

      log("Login ${response.data}");

      final userModel = UserModel.fromJson(response.data);

      /// لو مفيش user يبقى اللوجين فشل
      if (userModel.data?.user == null) {
        throw ApiException(
          userModel.message ??
              LocaleKeys.genericErrorMessage.tr(),
        );
      }

      /// أو لو التوكن فاضي
      if ((userModel.data?.user?.authToken ?? '').isEmpty) {
        throw ApiException(
          userModel.message ??
              LocaleKeys.genericErrorMessage.tr(),
        );
      }
      SessionManager.resetSession();

      return userModel;

    } on DioError catch (error) {

      Helpers.debugDioError(error);

      if (error.response?.statusCode == 422 ||
          error.response?.statusCode == 400) {

        final errorMsg =
            error.response?.data['message'] as String? ??
                LocaleKeys.genericErrorMessage.tr();

        throw ApiException(errorMsg);

      } else {
        rethrow;
      }

    } on ApiException {
      rethrow;
    } catch (error) {
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<UserModel> register({
    required String phone,
    required String password,
    required String name,
    required String mail,
    required String passwordConfirmation,
    required int otp,
    required String idImg,
    required String companyLicenceImg,
    required String companyLicenceNo,
    required String companyLicenceExDate,
    required String taxiNo,
    required String companyName,
    required String address,
    required double lat,
    required double long,
    required Locale locale,
  }) async {
    final storedVendorId = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.vendorID);

    final id = int.tryParse(storedVendorId ?? '');

    final String api = (id == 1)
        ? registerEndPoint
        : (id == 2)
            ? registerCarPartsEndPoint
            : (id == 3)
                ? registerWinchEndPoint
                : registerEmergencyEndPoint;

    try {
      final response = await ApiClient.instance.dio.post(api,
          data: {
            "name": name,
            "email": mail,
            "phone": phone,
            "password": password,
            "password_confirmation": passwordConfirmation,
            "otp": otp,
            "id_image": idImg,
            "company_licence_image": companyLicenceImg,
            "company_licence_no": companyLicenceNo,
            "company_name": companyName,
            "company_licence_expire_date":
                companyLicenceExDate /*"2026-08-01"*/,
            "tax_no": taxiNo,
            "lat": lat,
            "lon": long,
            "address": address
          },
          options: Options(headers: {
            'lang': locale.languageCode,
          }));
      final data = response.data;

      if (data is Map && data['success'] == false) {
        throw ApiException(data['message'] ?? 'Registration failed');
      }

      final model = UserModel.fromJson(data);

      final token = model.data?.user?.authToken;

      if (token == null || token.isEmpty) {
        throw ApiException("Invalid token received");
      }

      return model;
    } on DioError catch (error) {
      Helpers.debugDioError(error);

      if (error.response!.statusCode == 422 ||
          error.response!.statusCode == 400) {
        final errorMsg = error.response!.data['message'] as String;
        throw ApiException(errorMsg);
      } else {
        rethrow;
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (error) {
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<UserModel> registerWinch({
    required String phone,
    required String password,
    required String name,
    required String mail,
    required String passwordConfirmation,
    required int otp,
    required String idImg,
    required String criminalRecordImage,
    required String carLicenceImage,
    required String driverLicenceImage,
    required String driverLicenceExDate,
    required String carLicenceExDate,
    required String carLicenceNo,
    required String carPlateNo,
    required Locale locale,
    // Add new parameters
    String? companyCode,
    String? carCode,
    int? vendorId,
  }) async {
    try {
      final response = await ApiClient.instance.dio.post(registerWinchEndPoint,
          data: {
            "name": name,
            "email": mail,
            "phone": phone,
            "password": password,
            "password_confirmation": passwordConfirmation,
            "otp": otp,
            "id_image": idImg,
            "criminal_record_image": criminalRecordImage,
            "driver_licence_image": driverLicenceImage,
            "driver_licence_no": "123",
            "driver_licence_expire_date": driverLicenceExDate,
            "car_licence_image": carLicenceImage,
            "car_licence_expire_date": carLicenceExDate,
            "car_licence_no": carLicenceNo,
            "car_plate_no": carPlateNo,
            "vendor_id": vendorId ?? 61, // Use the vendor ID provided (3 for Winch by default)
            "company_code": companyCode ?? "", // Include company code
            "car_code": carCode ?? "", // Include car code
          },
          options: Options(headers: {
            'lang': locale.languageCode,
          }));

      final data = response.data;
      if (data is Map && data['success'] == false) {
        throw ApiException(data['message'] ?? 'Registration failed');
      }

      final model = UserModel.fromJson(data);
      final token = model.data?.user?.authToken;

      if (token == null || token.isEmpty) {
        throw ApiException(model.message ?? "Invalid token received");
      }

      return model;
    } on DioError catch (error) {
      Helpers.debugDioError(error);

      if (error.response!.statusCode == 422 ||
          error.response!.statusCode == 400) {
        final errorMsg = error.response!.data['message'] as String;
        throw ApiException(errorMsg);
      } else {
        rethrow;
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (error) {
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<UserModel> registerEmergency({
    required String phone,
    required String password,
    required String name,
    required String mail,
    required String passwordConfirmation,
    required int otp,
    required String idImg,
    required String criminalRecordImage,
    required Locale locale,
    int? vendorId,
  }) async {
    try {
      final response =
          await ApiClient.instance.dio.post(registerEmergencyEndPoint,
              data: {
                "name": name,
                "email": mail,
                "phone": phone,
                "password": password,
                "password_confirmation": passwordConfirmation,
                "otp": otp,
                "id_image": idImg,
                "criminal_record_image": criminalRecordImage,
                "vendor_id": vendorId ?? 62, // Use the vendor ID provided (62 for Emergency by default)
              },
              options: Options(headers: {
                'lang': locale.languageCode,
              }));

      final data = response.data;
      if (data is Map && data['success'] == false) {
        throw ApiException(data['message'] ?? 'Registration failed');
      }

      final model = UserModel.fromJson(data);
      final token = model.data?.user?.authToken;

      if (token == null || token.isEmpty) {
        throw ApiException(model.message ?? "Invalid token received");
      }

      return model;
    } on DioError catch (error) {
      Helpers.debugDioError(error);

      if (error.response!.statusCode == 422 ||
          error.response!.statusCode == 400) {
        final errorMsg = error.response!.data['message'] as String;
        throw ApiException(errorMsg);
      } else {
        rethrow;
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (error) {
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<OtpModel> sentOtp(
      {required String? phone,
      required Locale locale,
      required String purpose}) async {
    try {
      final response = await ApiClient.instance.dio.post(otpEndPoint,
          data: {"phone": phone, "purpose": purpose},
          options: Options(headers: {
            'lang': locale.languageCode,
          }));

      return OtpModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);

      if (error.response!.statusCode == 422 ||
          error.response!.statusCode == 400) {
        final errorMsg = error.response!.data['message'] as String;
        throw ApiException(errorMsg);
      } else {
        Helpers.debugDioError(error as DioError);
        log(error.toString());
        var tagsJson = jsonDecode(error.response!.data['message'].toString());
        throw tagsJson;
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (error) {
      Helpers.debugDioError(error as DioError);
      log(error.toString());
      var tagsJson = jsonDecode(error.response!.data['message'].toString());
      throw tagsJson;
    }
  }

  static Future<UserModel> updateAddress(
      {required String address,
      required double lat,
      required double lon,
      required Locale locale}) async {
    try {
      final token = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);
      
      final response = await ApiClient.instance.dio.post(updateAddressEndPoint,
          data: {
            "address": address,
            "lat": lat,
            "lon": lon
          },
          options: Options(headers: {
            'lang': locale.languageCode,
            'Authorization': 'Bearer $token',
          }));

      return UserModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);

      if (error.response!.statusCode == 422 ||
          error.response!.statusCode == 400) {
        final errorMsg = error.response!.data['message'] as String;
        throw ApiException(errorMsg);
      } else {
        Helpers.debugDioError(error as DioError);
        log(error.toString());
        var tagsJson = jsonDecode(error.response!.data['message'].toString());
        throw tagsJson;
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (error) {
      Helpers.debugDioError(error as DioError);
      log(error.toString());
      var tagsJson = jsonDecode(error.response!.data['message'].toString());
      throw tagsJson;
    }
  }

  static Future<OtpModel> updatePassword(
      {required String? currentPassword,
      required String? password,
      required String? passwordConfirmation,
      required Locale locale}) async {
    try {
      final token = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);
      final response = await ApiClient.instance.dio.post(updatePasswordEndPoint,
          data: {
            "current_password": currentPassword,
            "password": password,
            "password_confirmation": passwordConfirmation
          },
          options: Options(headers: {
            'lang': locale.languageCode,
            'Authorization': 'Bearer $token',
          }));

      return OtpModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);

      if (error.response!.statusCode == 422 ||
          error.response!.statusCode == 400) {
        final errorMsg = error.response!.data['message'] as String;
        throw ApiException(errorMsg);
      } else {
        Helpers.debugDioError(error as DioError);
        log(error.toString());
        var tagsJson = jsonDecode(error.response!.data['message'].toString());
        throw tagsJson;
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (error) {
      Helpers.debugDioError(error as DioError);
      log(error.toString());
      var tagsJson = jsonDecode(error.response!.data['message'].toString());
      throw tagsJson;
    }
  }

  static Future<UserModel> updateProfile(
      {required String? name,
      required String? mail,
      required String? phone,
      required String? idImg,
      required String? companyLicenceImg,
      required String? companyLicenceNo,
      required String? companyLicenceExDate,
      required String? taxiNo,
      required String? companyName,
      required String? address,
      required double? lat,
      required double? long,
      required Locale locale}) async {
    try {
      final token = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);
      final response = await ApiClient.instance.dio.post(updateProfileEndPoint,
          data: {
            "name": name,
            "email": mail,
            "phone": phone,
            "id_image": idImg,
            "company_licence_image": companyLicenceImg,
            "company_licence_no": companyLicenceNo,
            "company_name": companyName,
            "company_licence_expire_date":
                companyLicenceExDate /*"2026-08-01"*/,
            "tax_no": taxiNo,
            "lat": lat,
            "lon": long,
            "address": address
          },
          options: Options(headers: {
            'lang': locale.languageCode,
            'Authorization': 'Bearer $token',
          }));

      return UserModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);

      if (error.response!.statusCode == 422 ||
          error.response!.statusCode == 400) {
        final errorMsg = error.response!.data['message'] as String;
        throw ApiException(errorMsg);
      } else {
        Helpers.debugDioError(error as DioError);
        log(error.toString());
        var tagsJson = jsonDecode(error.response!.data['message'].toString());
        throw tagsJson;
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (error) {
      Helpers.debugDioError(error as DioError);
      log(error.toString());
      var tagsJson = jsonDecode(error.response!.data['message'].toString());
      throw tagsJson;
    }
  }

  static Future<UserModel> updatePhone(
      {required String? phone,
      required int? otp,
      required Locale locale}) async {
    try {
      final token = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);
      final response = await ApiClient.instance.dio.post(updatePhoneEndPoint,
          data: {"phone": phone, "otp": otp},
          options: Options(headers: {
            'lang': locale.languageCode,
            'Authorization': 'Bearer $token',
          }));

      return UserModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);

      if (error.response!.statusCode == 422 ||
          error.response!.statusCode == 400) {
        final errorMsg = error.response!.data['message'] as String;
        throw ApiException(errorMsg);
      } else {
        Helpers.debugDioError(error as DioError);
        log(error.toString());
        var tagsJson = jsonDecode(error.response!.data['message'].toString());
        throw tagsJson;
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (error) {
      Helpers.debugDioError(error as DioError);
      log(error.toString());
      var tagsJson = jsonDecode(error.response!.data['message'].toString());
      throw tagsJson;
    }
  }

  static Future<OtpModel> resetPassword(
      {required String? passwordConfirmation,
      required String? password,
      required String? phone,
      required int? otp,
      required Locale locale}) async {
    try {
      final token = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);
      final response = await ApiClient.instance.dio.post(resetPasswordEndPoint,
          data: {
            "phone": phone,
            "password": password,
            "password_confirmation": passwordConfirmation,
            "otp": otp
          },
          options: Options(headers: {
            'lang': locale.languageCode,
            'Authorization': 'Bearer $token',
          }));

      return OtpModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);

      if (error.response!.statusCode == 422 ||
          error.response!.statusCode == 400) {
        final errorMsg = error.response!.data['message'] as String;
        throw ApiException(errorMsg);
      } else {
        Helpers.debugDioError(error as DioError);
        log(error.toString());
        var tagsJson = jsonDecode(error.response!.data['message'].toString());
        throw tagsJson;
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (error) {
      Helpers.debugDioError(error as DioError);
      log(error.toString());
      var tagsJson = jsonDecode(error.response!.data['message'].toString());
      throw tagsJson;
    }
  }

  static Future<void> verifyOtp(
      {required String? phone,
      required String? otp,
      required Locale locale}) async {
    try {
      /*final response =*/ await ApiClient.instance.dio.post(verifyOtpEndPoint,
          data: {"phone": phone, "otp": otp},
          options: Options(headers: {
            'lang': locale.languageCode,
          }));

      // return OtpModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);

      if (error.response!.statusCode == 422 ||
          error.response!.statusCode == 400) {
        final errorMsg = error.response!.data['message'] as String;
        throw ApiException(errorMsg);
      } else {
        Helpers.debugDioError(error as DioError);
        log(error.toString());
        var tagsJson = jsonDecode(error.response!.data['message'].toString());
        throw tagsJson;
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (error) {
      Helpers.debugDioError(error as DioError);
      log(error.toString());
      var tagsJson = jsonDecode(error.response!.data['message'].toString());
      throw tagsJson;
    }
  }

  static Future<String> setLanguage(int langID) async {
    try {
      final response = await ApiClient.instance.dio.post(
        '/$langID',
        options: Options(headers: authHeader),
      );

      return response.data;
    } on DioError catch (error) {
      Helpers.debugDioError(error);

      if (error.response!.statusCode == 422) {
        final errors = error.response!.data['error'] as List;
        throw ApiException(errors.join('\n'));
      } else {
        rethrow;
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (error) {
      rethrow;
    }
  }

  static Future<UserModel> getUser({required Locale locale}) async {
    try {
      final token = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);
      final storedVendorId = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.vendorID);

      print('DEBUG - Token: ${token != null ? "Token exists" : "Token is NULL"}');
      print('DEBUG - Token: $token');
      print('DEBUG - Vendor ID from storage: $storedVendorId');
      
      final id = int.tryParse(storedVendorId ?? '');
      print('DEBUG - Parsed Vendor ID: $id');

      final String api = (id == 1)
        ? getProfileEndPoint
        : (id == 2)
            ? getProfileCarPartsEndPoint
            : (id == 3 || id == 61)
                ? getProfileWinchEndPoint
                : (id == 4 || id == 62)
                    ? getProfileEmergencyEndPoint
                    : getProfileEndPoint;
      print('DEBUG - Selected API endpoint: $api');

      final response = await ApiClient.instance.dio.get(api,
          options: Options(headers: {
            'lang': locale.languageCode,
            'Authorization': 'Bearer $token',
          }));

      return UserModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);

      if (error.response!.statusCode == 422 ||
          error.response!.statusCode == 400) {
        final errorMsg = error.response!.data['message'] as String;
        throw ApiException(errorMsg);
      } else {
        Helpers.debugDioError(error as DioError);
        log(error.toString());
        var tagsJson = jsonDecode(error.response!.data['message'].toString());
        throw tagsJson;
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (error) {
      Helpers.debugDioError(error as DioError);
      log(error.toString());
      var tagsJson = jsonDecode(error.response!.data['message'].toString());
      throw tagsJson;
    }
  }
}
