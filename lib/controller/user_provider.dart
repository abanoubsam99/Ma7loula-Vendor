import 'dart:developer';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

import '../core/generated/locale_keys.g.dart';
import '../core/services/http/apis/user_api.dart';
import '../core/services/secure_storage/secure_storage_keys.dart.dart';
import '../core/services/secure_storage/secure_storage_service.dart';
import '../model/user.dart';

class UserProvider with ChangeNotifier {
  UserModel? user;

  bool get isLoggedIn {
    if (user == null) {
      return false;
    } else {
      if (user?.data?.user?.phone == null /*|| user!.addresses.isEmpty*/) {
        return false;
      } else {
        return true;
      }
    }
  }

  bool get hasSetTheName => user?.data?.user?.phone != null;

  Future<void> login(
      {required String phone,
      required String password,
      required Locale locale}) async {
    try {
      try {
        // Try with the current vendor type first
        user = await UserApi.login(phone: phone, password: password, locale: locale);
      } catch (error) {
        // If first attempt fails, try with all vendor types
        log('Initial login failed, trying all vendor types: ${error.toString()}');
        
        // Save the current vendor ID so we can restore it if all attempts fail
        final currentVendorId = await SecureStorageService.instance
            .readString(key: SecureStorageKeys.vendorID);
            
        // Try with each vendor type (1-4)
        for (int vendorId = 1; vendorId <= 4; vendorId++) {
          try {
            // Set the vendor ID temporarily
            await SecureStorageService.instance.writeString(
              key: SecureStorageKeys.vendorID,
              value: vendorId.toString(),
            );
            
            // Try login with this vendor type
            user = await UserApi.login(phone: phone, password: password, locale: locale);
            
            // If we get here, login succeeded
            log('Login succeeded with vendor type: $vendorId');
            break;
          } catch (e) {
            // This vendor type didn't work, continue to next
            log('Login failed with vendor type $vendorId: ${e.toString()}');
            
            // If this is the last vendor type and it failed, restore original vendor ID
            if (vendorId == 4) {
              if (currentVendorId != null) {
                await SecureStorageService.instance.writeString(
                  key: SecureStorageKeys.vendorID,
                  value: currentVendorId,
                );
              }
              // Re-throw the original error
              throw error;
            }
          }
        }
      }
      
      // If we get here, login succeeded with some vendor type
      final token = user?.data?.user?.authToken;
      await Future.wait([
        SecureStorageService.instance.writeString(
          key: SecureStorageKeys.token,
          value: token ?? '',
        ),
      ]);
      notifyListeners();
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  Future<void> register(
      {required String phone,
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
      required Locale locale}) async {
    try {
      user = await UserApi.register(
          phone: phone,
          password: password,
          name: name,
          mail: mail,
          passwordConfirmation: passwordConfirmation,
          otp: otp,
          companyLicenceNo: companyLicenceNo,
          companyLicenceImg: companyLicenceImg,
          companyLicenceExDate: companyLicenceExDate,
          companyName: companyName,
          taxiNo: taxiNo,
          long: long,
          lat: lat,
          locale: locale,
          idImg: idImg,
          address: address);
      // final token = user?.data?.user?.authToken;
      // await Future.wait([
      //   SecureStorageService.instance.writeString(
      //     key: SecureStorageKeys.token,
      //     value: token ?? '',
      //   ),
      // ]);


      final token = user?.data?.user?.authToken;

      if (token == null || token.isEmpty) {
        throw Exception("Login failed after registration");
      }

      await SecureStorageService.instance.writeString(
        key: SecureStorageKeys.token,
        value: token,
      );
      notifyListeners();
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  Future<void> registerWinch(
      {required String phone,
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
      int? vendorId}) async {
    try {
      user = await UserApi.registerWinch(
        phone: phone,
        password: password,
        name: name,
        mail: mail,
        passwordConfirmation: passwordConfirmation,
        otp: otp,
        carLicenceNo: carLicenceNo,
        carPlateNo: carPlateNo,
        carLicenceExDate: carLicenceExDate,
        criminalRecordImage: criminalRecordImage,
        carLicenceImage: carLicenceImage,
        idImg: idImg,
        driverLicenceImage: driverLicenceImage,
        driverLicenceExDate: driverLicenceExDate,
        locale: locale,
        vendorId: vendorId,
        companyCode: companyCode,
        carCode: carCode,
      );
      print('dkkdkd #$user');
      final token = user?.data?.user?.authToken;
      
      if (token == null || token.isEmpty) {
        throw Exception(user?.message ?? "Login failed after registration");
      }

      await Future.wait([
        SecureStorageService.instance.writeString(
          key: SecureStorageKeys.token,
          value: token,
        ),
      ]);
      notifyListeners();
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  Future<void> registerEmergency(
      {required String phone,
      required String password,
      required String name,
      required String mail,
      required String passwordConfirmation,
      required int otp,
      required String idImg,
      required String criminalRecordImage,
      required Locale locale,
      int? vendorId}) async {
    try {
      user = await UserApi.registerEmergency(
        phone: phone,
        password: password,
        name: name,
        mail: mail,
        passwordConfirmation: passwordConfirmation,
        otp: otp,
        criminalRecordImage: criminalRecordImage,
        idImg: idImg,
        locale: locale,
        vendorId: vendorId,
      );
      print('dkkdkd #$user');
      final token = user?.data?.user?.authToken;
      
      if (token == null || token.isEmpty) {
        throw Exception(user?.message ?? "Login failed after registration");
      }

      await Future.wait([
        SecureStorageService.instance.writeString(
          key: SecureStorageKeys.token,
          value: token,
        ),
      ]);
      notifyListeners();
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  Future<void> sentOtp(
      {required String phone,
      required String purpose,
      required Locale locale}) async {
    try {
      await UserApi.sentOtp(phone: phone, locale: locale, purpose: purpose);
      notifyListeners();
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  Future<void> updatePassword(
      {required String password,
      required String currentPassword,
      required String passwordConfirmation,
      required Locale locale}) async {
    try {
      await UserApi.updatePassword(
          currentPassword: currentPassword,
          password: password,
          passwordConfirmation: passwordConfirmation,
          locale: locale);
      notifyListeners();
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  Future<void> updateAddress(
      {required String address,
      required double lat,
      required double long,
      required Locale locale}) async {
    try {
      user = await UserApi.updateAddress(
        address: address,
        lat: lat, 
        lon: long,
        locale: locale
      );
      notifyListeners();
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  Future<void> updateProfile(
      {required String name,
      required String mail,
      required String phone,
      required String idImg,
      required String companyLicenceImg,
      required String companyLicenceNo,
      required String companyLicenceExDate,
      required String taxiNo,
      required String companyName,
      required String address,
      required double lat,
      required double long,
      required Locale locale}) async {
    try {
      final res = await UserApi.updateProfile(
          name: name,
          mail: mail,
          phone: phone,
          idImg: idImg,
          companyLicenceImg: companyLicenceImg,
          companyLicenceNo: companyLicenceNo,
          companyLicenceExDate: companyLicenceExDate,
          taxiNo: taxiNo,
          companyName: companyName,
          address: address,
          lat: lat,
          long: long,
          locale: locale);
      user = res;
      notifyListeners();
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  Future<void> updatePhone(
      {required String phone, required int otp, required Locale locale}) async {
    try {
      final res =
          await UserApi.updatePhone(otp: otp, phone: phone, locale: locale);
      user = res;
      notifyListeners();
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  Future<void> resetPassword(
      {required String? passwordConfirmation,
      required String? password,
      required String? phone,
      required int? otp,
      required Locale locale}) async {
    try {
      await UserApi.resetPassword(
          passwordConfirmation: passwordConfirmation,
          password: password,
          phone: phone,
          otp: otp,
          locale: locale);
      notifyListeners();
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  Future<void> verifyOtp(
      {required String phone,
      required String otp,
      required Locale locale}) async {
    try {
      await UserApi.verifyOtp(phone: phone, otp: otp, locale: locale);
      notifyListeners();
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  Future<String> setLang(int langID) async {
    try {
      final response = await UserApi.setLanguage(langID);

      notifyListeners();
      return response;
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  Future<void> autoLogin({required Locale locale}) async {
    try {
      final storedToken = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);

      if (storedToken != null) {
        try {
          // Try with current vendor type first
          final response = await UserApi.getUser(locale: locale);
          user = response;
        } catch (error) {
          // If first attempt fails, try with all vendor types
          log('Initial auto-login failed, trying all vendor types: ${error.toString()}');
          
          // Save the current vendor ID so we can restore it if all attempts fail
          final currentVendorId = await SecureStorageService.instance
              .readString(key: SecureStorageKeys.vendorID);
              
          // Try with each vendor type (1-4)
          bool loginSuccessful = false;
          for (int vendorId = 1; vendorId <= 4; vendorId++) {
            try {
              // Set the vendor ID temporarily
              await SecureStorageService.instance.writeString(
                key: SecureStorageKeys.vendorID,
                value: vendorId.toString(),
              );
              
              // Try login with this vendor type
              final response = await UserApi.getUser(locale: locale);
              user = response;
              
              // If we get here, login succeeded
              log('Auto-login succeeded with vendor type: $vendorId');
              loginSuccessful = true;
              break;
            } catch (e) {
              // This vendor type didn't work, continue to next
              log('Auto-login failed with vendor type $vendorId: ${e.toString()}');
            }
          }
          
          // If all vendor types failed, restore original vendor ID and throw the error
          if (!loginSuccessful) {
            if (currentVendorId != null) {
              await SecureStorageService.instance.writeString(
                key: SecureStorageKeys.vendorID,
                value: currentVendorId,
              );
            }
            throw error;
          }
        }
        
        notifyListeners();
      } else {
        throw LocaleKeys.genericErrorMessage.tr();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> logout(/*email, fcm*/) async {
    try {
      // await UserApi.logout(email, fcm);
      // await GoogleSignInApi.logout();
      await SecureStorageService.instance.deleteAllData();
      await SecureStorageService.instance.writeBool(
        key: SecureStorageKeys.hasViewedOnboarding,
        value: true,
      );
      //AuthServices().signOut();
      //GoogleSignIn().signOut();

      user = null;
      notifyListeners();
    } catch (error) {
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }
}

class ImageCompressor {
  static Future<File> compressImage(File file, {int quality = 60}) async {
    try {
      // التحقق من وجود الملف
      if (!await file.exists()) {
        throw Exception('الملف غير موجود');
      }

      // الحصول على حجم الملف الأصلي بالميجابايت
      final double originalSizeInMb = file.lengthSync() / (1024 * 1024);
      log('Original file size: ${originalSizeInMb.toStringAsFixed(2)} MB');

      // الحصول على مسار مؤقت للملف المضغوط
      final Directory tempDir = await getTemporaryDirectory();
      final String targetPath =
          '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // تحديد جودة الضغط بناءً على حجم الملف
      int compressionQuality = quality;
      if (originalSizeInMb > 5) {
        compressionQuality = 40;
      } else if (originalSizeInMb > 3) {
        compressionQuality = 50;
      }

      // ضغط الصورة
      var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: compressionQuality,
        rotate: 0,
        format: CompressFormat.jpeg,
        keepExif: false,
      );

      if (result == null) {
        throw Exception('فشل في ضغط الصورة');
      }

      final File compressedFile = File(result.path);
      final double compressedSizeInMb =
          compressedFile.lengthSync() / (1024 * 1024);
      log('Compressed file size: ${compressedSizeInMb.toStringAsFixed(2)} MB');

      // إذا كان الحجم لا يزال كبيراً، نحاول مرة أخرى بجودة أقل
      if (compressedSizeInMb > 2) {
        await compressedFile.delete();
        return compressImage(file, quality: compressionQuality - 20);
      }

      return compressedFile;
    } catch (e) {
      log('Error in image compression: $e');
      throw Exception('حدث خطأ أثناء معالجة الصورة');
    }
  }
}
