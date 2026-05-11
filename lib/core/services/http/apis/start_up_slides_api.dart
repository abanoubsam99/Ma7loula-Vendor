import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../model/start_up_slides.dart';
import '../../../generated/locale_keys.g.dart';
import '../../secure_storage/secure_storage_keys.dart.dart';
import '../../secure_storage/secure_storage_service.dart';
import '../api_client.dart';
import '../api_endpoints.dart';

class StartUpSlidesApi {
  static Future<SliderData> getStartUpSlides({required Locale locale}) async {
    final storedVendorId = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.vendorID);

    final id = int.tryParse(storedVendorId ?? '');

    final String api = (id == 1)
        ? startUpSlidesEndPoint
        : (id == 2)
            ? startUpSlidesCarPartsEndPoint
            : (id == 3)
                ? startUpSlidesWinchEndPoint
                : startUpSlidesEmergencyEndPoint;

    try {
      final response = await ApiClient.instance.dio.get(
        api,
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'lang': locale.languageCode,
          'App': 'client'
        }),
      );

      return SliderData.fromJson(response.data);
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }
}
