import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as t;
import 'package:ma7lola_vendor/core/services/http/api_endpoints.dart';
import 'package:ma7lola_vendor/model/add_battery_model.dart';
import 'package:ma7lola_vendor/model/car_model_model.dart';
import 'package:ma7lola_vendor/model/car_type_model.dart';
import 'package:ma7lola_vendor/model/cities_model.dart';
import 'package:ma7lola_vendor/model/states_model.dart';
import 'package:ma7lola_vendor/model/subcategory.dart';
import 'package:ma7lola_vendor/model/tires_brand_model.dart';
import 'package:ma7lola_vendor/model/tires_size_model.dart';
import 'package:ma7lola_vendor/model/tires_type_model.dart';
import 'package:ma7lola_vendor/model/winch/winch_previous_orders.dart';

import '../../../../../model/winch/order_details_model.dart' as winchOrder;
import '../../../../controller/SessionManager.dart';
import '../../../../controller/handleDioError.dart';
import '../../../../model/about_app.dart';
import '../../../../model/add_tire_model.dart';
import '../../../../model/address_model.dart';
import '../../../../model/addresses_model.dart';
import '../../../../model/batteries_products_model.dart';
import '../../../../model/car_parts_model.dart';
import '../../../../model/car_parts_order_model.dart';
import '../../../../model/cars_list_model.dart';
import '../../../../model/comments_model.dart';
import '../../../../model/emergency/emergency_offers_model.dart';
import '../../../../model/emergency/order_details.dart';
import '../../../../model/emergency/privous_orders.dart';
import '../../../../model/emergency/services_model.dart';
import '../../../../model/emergency/update_emergency_service.dart';
import '../../../../model/faq.dart';
import '../../../../model/image_model.dart';
import '../../../../model/my_orders_model.dart';
import '../../../../model/order_details_model.dart';
import '../../../../model/products_model.dart';
import '../../../../model/requirements_doc_model.dart';
import '../../../../model/slider_model.dart';
import '../../../../model/time_ava.dart';
import '../../../../model/voltages_model.dart';
import '../../../../model/winch/my_transactions_model.dart';
import '../../../../model/winch/my_withdrawal_requests_model.dart';
import '../../../../model/winch/sent_withdrawal_method_model.dart';
import '../../../../model/winch/update_location.dart';
import '../../../../model/winch/update_order_status.dart';
import '../../../../model/winch/winch_offers_model.dart';
import '../../../../model/winch/withdrawal_methods_model.dart';
import '../../../../model/years_model.dart';
import '../../../../view/screens/auth/choose_vendor_type.dart';
import '../../../generated/locale_keys.g.dart';
import '../../../utils/helpers.dart';
import '../../secure_storage/secure_storage_keys.dart.dart';
import '../../secure_storage/secure_storage_service.dart';
import '../api_client.dart';
import '../interceptors/api_interceptor.dart';
import 'exceptions/api_exception.dart';

class MiscellaneousApi {
  static Future<List<ProductsModel>> getProducts(context) async {
    try {
      final response = await ApiClient.instance.dio.get(
        'api/products/',
        options: Options(headers: authHeader),
      );
      return List<ProductsModel>.from(
          response.data.map((post) => ProductsModel.fromJson(post)).toList());
    } catch (error) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return ChooseVendorType(
            isIntroScreen: true,
          );
        })),
      );
      return [];
    }
  }

  static Future<SliderModel> getSliders({required Locale locale}) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    try {
      final storedVendorId = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.vendorID);

      final id = int.tryParse(storedVendorId ?? '');

      final String api = (id == 2)
          ? slidersCarPartsEndPoint
          : (id == 3)
              ? slidersWinchEndPoint
              : (id == 4)
                  ? slidersEmergencyEndPoint
                  : slidersEndPoint;

      final response = await ApiClient.instance.dio.get(
        api,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      // Helpers.logDioResponse(response);

      return SliderModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<VoltagesModel> getVoltages(
      {required Locale locale, required int carID}) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    try {
      final response = await ApiClient.instance.dio.get(
        volatagesEndPoint,
        queryParameters: {
          'car_id': carID,
        },
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      // Helpers.logDioResponse(response);

      return VoltagesModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<TiresBrandsModel> getTiresBrands(
      {required Locale locale}) async {
    try {
      final response = await ApiClient.instance.dio.get(
        tiresBrandsEndPoint,
        options: Options(headers: {
          'lang': locale.languageCode,
        }),
      );

      // Helpers.logDioResponse(response);

      return TiresBrandsModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<TiresTypesModel> getTiresTypes(
      {required Locale locale,
      required int carID,
      required int brandID}) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    try {
      final response = await ApiClient.instance.dio.get(
        tiresTypesEndPoint,
        queryParameters: {
          'car_id': carID,
          'brand_id': brandID,
        },
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      // Helpers.logDioResponse(response);

      return TiresTypesModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<TiresSizesModel> getTiresSizes(
      {required Locale locale,
      required int carID,
      required String type,
      required int brandID}) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    try {
      final response = await ApiClient.instance.dio.get(
        tiresSizesEndPoint,
        queryParameters: {
          'car_id': carID,
          'brand_id': brandID,
          'type': type,
        },
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      // Helpers.logDioResponse(response);

      return TiresSizesModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<TiresBrandsModel> getBrands({required Locale locale}) async {
    try {
      final response = await ApiClient.instance.dio.get(
        brandsEndPoint,
        options: Options(headers: {
          'lang': locale.languageCode,
        }),
      );

      // Helpers.logDioResponse(response);

      return TiresBrandsModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<CarPartsModel> getCarParts({required Locale locale}) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    try {
      final response = await ApiClient.instance.dio.get(
        carPartsEndPoint,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      // Helpers.logDioResponse(response);

      return CarPartsModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<CarPartsSubCategory> getCarPartsSubCategory(
      {required Locale locale, required int categoryID}) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    try {
      final response = await ApiClient.instance.dio.get(
        carPartsEndPoint /*?category_id=$categoryID*/,
        queryParameters: {'category_id': categoryID},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'lang': locale.languageCode,
          },
        ),
      );

      // Helpers.logDioResponse(response);

      return CarPartsSubCategory.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<CarModelModel> getCarsModel(
      {required Locale locale, required int carBrandId}) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    try {
      final response = await ApiClient.instance.dio.get(
        carsModelEndPoint,
        queryParameters: {"car_brand_id": carBrandId},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      return CarModelModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<CarTypeModel> getCarsType({required Locale locale}) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    try {
      final response = await ApiClient.instance.dio.get(
        carsTypeEndPoint,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      return CarTypeModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<YearsModel> getYears(
      {required Locale locale,
      required int carTypeId,
      required int carModelId}) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    try {
      final response = await ApiClient.instance.dio.get(
        yearsCarsEndPoint,
        queryParameters: {
          "car_brand_id": carTypeId,
          "car_model_id": carModelId
        },
        options: Options(headers: {
          // 'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      // Helpers.logDioResponse(response);

      return YearsModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<CarsListModel> getCars(
      {required Locale locale,
      required int carTypeId,
      required int year,
      required int carModelId}) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    try {
      final response = await ApiClient.instance.dio.get(
        allCarsEndPoint,
        queryParameters: {
          "car_brand_id": carTypeId,
          "car_model_id": carModelId,
          "year": year
        },
        options: Options(headers: {
          // 'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      // Helpers.logDioResponse(response);

      return CarsListModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<AddressesModel> getAddresses({required Locale locale}) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    try {
      final response = await ApiClient.instance.dio.get(
        addressesEndPoint,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      // Helpers.logDioResponse(response);

      return AddressesModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<void> deleteAddress(
      {required int addressId, required Locale locale}) async {
    try {
      final token = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);
      await ApiClient.instance.dio.delete(deleteAddressEndPoint,
          data: {"id": addressId},
          options: Options(headers: {
            'lang': locale.languageCode,
            'Authorization': 'Bearer $token',
          }));
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

  static Future<StatesModel> getStates({required Locale locale}) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    try {
      final response = await ApiClient.instance.dio.get(
        statesEndPoint,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      // Helpers.logDioResponse(response);

      return StatesModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<CitiesModel> getCities(
      {required Locale locale, required int stateID}) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    try {
      final response = await ApiClient.instance.dio.get(
        citiesEndPoint,
        queryParameters: {'state_id': stateID},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      // Helpers.logDioResponse(response);

      return CitiesModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<AddressModel> addAddress({
    required Locale locale,
    required int stateID,
    required int cityID,
    required String? lat,
    required String? long,
    required String name,
    required String details,
    required bool isDefault,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    try {
      final response = await ApiClient.instance.dio.post(
        addAddressEndPoint,
        data: {
          "name": name,
          "state_id": stateID,
          "city_id": cityID,
          "lat": lat,
          "lon": long,
          "details": details,
          "is_default": isDefault
        },
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      // Helpers.logDioResponse(response);

      return AddressModel.fromJson(response.data);
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

  static Future<void> setAddressDefault({
    required Locale locale,
    required int addressID,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    try {
      await ApiClient.instance.dio.post(
        setAddressDefaultEndPoint,
        data: {"id": addressID},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      // Helpers.logDioResponse(response);
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

  static Future<CarPartsOrderModel> createCarPartsOrder({
    required Locale locale,
    required int addressID,
    required int carID,
    required String payment,
    required String deliveryType,
    required List<Map<String, dynamic>> products,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);

    final dateTime = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.dateTime);
    // DateTime newDateTime = DateTime.now().add(Duration(hours: 2, minutes: 30));

    // String time = t.DateFormat('yyyy-MM-dd HH:mm').format(newDateTime);

    try {
      final data = {
        "address_id": addressID,
        "user_car_id": carID,
        "payment_method": payment, //cash or visa
        "delivery_type": deliveryType, //fast or scheduled
        "delivery_time": (dateTime != null &&
                dateTime.isNotEmpty &&
                (!dateTime.contains('null')))
            ? dateTime.toString()
            : '',
        "products": products,
      };
      final response = await ApiClient.instance.dio.post(
        createCarPartsOrderEndPoint,
        data: data,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      // Helpers.logDioResponse(response);

      return CarPartsOrderModel.fromJson(response.data);
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

  static Future<CarPartsOrderModel> createBatteriesOrder({
    required Locale locale,
    required int addressID,
    required int carID,
    required String payment,
    required String deliveryType,
    required List<Map<String, dynamic>> products,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);

    final dateTime = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.dateTime);
    // DateTime newDateTime = DateTime.now().add(Duration(hours: 2, minutes: 30));

    // String time = t.DateFormat('yyyy-MM-dd HH:mm').format(newDateTime);

    try {
      final data = {
        "address_id": addressID,
        "user_car_id": carID,
        "payment_method": payment, //cash or visa
        "delivery_type": deliveryType, //fast or scheduled
        "delivery_time": (dateTime != null &&
                dateTime.isNotEmpty &&
                (!dateTime.contains('null')))
            ? dateTime.toString()
            : '',
        "products": products,
      };
      final response = await ApiClient.instance.dio.post(
        createBatteriesOrderEndPoint,
        data: data,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      // Helpers.logDioResponse(response);

      return CarPartsOrderModel.fromJson(response.data);
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

  static Future<CarPartsOrderModel> createTiresOrder({
    required Locale locale,
    required int addressID,
    required int carID,
    required String payment,
    required String deliveryType,
    required List<Map<String, dynamic>> products,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);

    final dateTime = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.dateTime);
    // DateTime newDateTime = DateTime.now().add(Duration(hours: 2, minutes: 30));
    //
    // String time = t.DateFormat('yyyy-MM-dd HH:mm').format(newDateTime);

    try {
      final data = {
        "address_id": addressID,
        "user_car_id": carID,
        "payment_method": payment, //cash or visa
        "delivery_type": deliveryType, //fast or scheduled
        "delivery_time": (dateTime != null &&
                dateTime.isNotEmpty &&
                (!dateTime.contains('null')))
            ? dateTime.toString()
            : '',
        "products": products,
      };
      final response = await ApiClient.instance.dio.post(
        createTiresOrderEndPoint,
        data: data,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      // Helpers.logDioResponse(response);

      return CarPartsOrderModel.fromJson(response.data);
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

  static Future<TimesAvai> getTiresTime({
    required Locale locale,
    required int cityID,
    required int stateID,
    required DateTime dateTime,
    required List<Map<String, dynamic>> products,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);

    // final dateTime = await SecureStorageService.instance
    //     .readString(key: SecureStorageKeys.dateTime);
    // DateTime newDateTime = DateTime.now().add(Duration(hours: 2, minutes: 30));
    //
    String time = t.DateFormat('yyyy-MM-dd').format(dateTime);

    try {
      final data = {
        "date": time,
        "city_id": cityID,
        "state_id": stateID,
        "products": products
      };
      final response = await ApiClient.instance.dio.post(
        tiresAvaTimeEndPoint,
        data: data,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      // Helpers.logDioResponse(response);

      return TimesAvai.fromJson(response.data);
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

  static Future<TimesAvai> getBatteriesTime({
    required Locale locale,
    required int cityID,
    required int stateID,
    required DateTime dateTime,
    required List<Map<String, dynamic>> products,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    String time = t.DateFormat('yyyy-MM-dd').format(dateTime);

    try {
      final data = {
        "date": time,
        "city_id": cityID,
        "state_id": stateID,
        "products": products
      };
      final response = await ApiClient.instance.dio.post(
        batteriesAvaTimeEndPoint,
        data: data,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      // Helpers.logDioResponse(response);

      return TimesAvai.fromJson(response.data);
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

  static Future<TimesAvai> getCarPartsTime({
    required Locale locale,
    required int cityID,
    required int stateID,
    required DateTime dateTime,
    required List<Map<String, dynamic>> products,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    String time = t.DateFormat('yyyy-MM-dd').format(dateTime);

    try {
      final data = {
        "date": time,
        "city_id": cityID,
        "state_id": stateID,
        "products": products
      };
      final response = await ApiClient.instance.dio.post(
        carPartsAvaTimeEndPoint,
        data: data,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      // Helpers.logDioResponse(response);

      return TimesAvai.fromJson(response.data);
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

  static Future<ProductsModel> getSearchProducts({
    required Locale locale,
    required int page,
    required int perPage,
    required String status,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);

    final storedVendorId = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.vendorID);

    final id = int.tryParse(storedVendorId ?? '');

    final String api = (id == 2)
        ? productsCarPartsEndPoint
        : (id == 3)
            ? productsWinchEndPoint
            : (id == 4)
                ? productsEmergencyEndPoint
                : productsEndPoint;

    try {
      final response = await ApiClient.instance.dio.get(
        '$api$status',
        queryParameters: {'page': page, 'perPage': perPage},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      return ProductsModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<BatteriesProductsModel> getSearchProductsBatteries({
    required Locale locale,
    required int page,
    required int perPage,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);

    final storedVendorId = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.vendorID);

    final id = int.tryParse(storedVendorId ?? '');

    final String api = (id == 2)
        ? batteriesProductsCarPartsEndPoint
        : (id == 3)
            ? batteriesProductsWinchEndPoint
            : (id == 4)
                ? batteriesProductsEmergencyEndPoint
                : batteriesProductsEndPoint;

    try {
      final response = await ApiClient.instance.dio.get(
        api,
        queryParameters: {'page': page, 'perPage': perPage},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      // Helpers.logDioResponse(response);

      return BatteriesProductsModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<BatteriesProductsModelLocal> getProductsBatteriesByID({
    required Locale locale,
    required int page,
    required int perPage,
    required int id,
  }) async {
    final storedVendorId = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.vendorID);

    final id = int.tryParse(storedVendorId ?? '');

    final String api = (id == 2)
        ? myOrdersBatteriesCarPartsEndPoint
        : (id == 3)
            ? myOrdersBatteriesWinchEndPoint
            : (id == 4)
                ? batteriesProductsByIdEmergencyEndPoint
                : batteriesProductsByIdEndPoint;

    try {
      final response = await ApiClient.instance.dio.post(
        api,
        queryParameters: {'page': page, 'perPage': perPage, "id": id},
        options: Options(headers: {
          'lang': locale.languageCode,
        }),
      );
      return BatteriesProductsModelLocal.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<OrderRateModel> cancelBatteryOrder({
    required Locale locale,
    required int id,
  }) async {
    try {
      final token = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);
      final response = await ApiClient.instance.dio.post(
        cancelBatteryOrderEndPoint,
        data: {"id": id, "status": "cancelled"},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );
      return OrderRateModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<OrderRateModel> cancelCarPartsOrder({
    required Locale locale,
    required int id,
  }) async {
    try {
      final token = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);
      final response = await ApiClient.instance.dio.post(
        cancelCarPartsOrderEndPoint,
        data: {"id": id, "status": "cancelled"},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );
      return OrderRateModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<OrderRateModel> cancelTiresOrder({
    required Locale locale,
    required int id,
  }) async {
    try {
      final token = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);
      final response = await ApiClient.instance.dio.post(
        cancelTiresOrderEndPoint,
        data: {"id": id, "status": "cancelled"},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );
      return OrderRateModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<OrderRateModel> getBatteryOrderDetails({
    required Locale locale,
    required int id,
  }) async {
    try {
      final token = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);
      final response = await ApiClient.instance.dio.get(
        detailsBatteryOrderEndPoint,
        queryParameters: {"id": id},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );
      return OrderRateModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<OrderRateModel> getCarPartsOrderDetails({
    required Locale locale,
    required int id,
  }) async {
    try {
      final token = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);

      final storedVendorId = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.vendorID);

      final vendorId = int.tryParse(storedVendorId ?? '');

      final String api = (vendorId == 1)
          ? detailsCarPartsOrderEndPoint
          : (vendorId == 2)
          ? detailsCarPartsOrderCarPartsEndPoint
          : (vendorId == 3)
          ? detailsCarPartsOrderWinchEndPoint
          : detailsCarPartsOrderEmergencyEndPoint;

      final response = await ApiClient.instance.dio.get(
        api,
        queryParameters: {"id": id}, // ✅ هنا order id صح
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      return OrderRateModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }
  // static Future<OrderRateModel> getCarPartsOrderDetails({required Locale locale, required int id,}) async {
  //   try {
  //     final token = await SecureStorageService.instance
  //         .readString(key: SecureStorageKeys.token);
  //
  //     final storedVendorId = await SecureStorageService.instance
  //         .readString(key: SecureStorageKeys.vendorID);
  //
  //     final id = int.tryParse(storedVendorId ?? '');
  //
  //     final String api = (id == 1)
  //         ? detailsCarPartsOrderEndPoint
  //         : (id == 2)
  //             ? detailsCarPartsOrderCarPartsEndPoint
  //             : (id == 3)
  //                 ? detailsCarPartsOrderWinchEndPoint
  //                 : detailsCarPartsOrderEmergencyEndPoint;
  //     final response = await ApiClient.instance.dio.get(
  //       api,
  //       queryParameters: {"id": id},
  //       options: Options(headers: {
  //         'Authorization': 'Bearer $token',
  //         'lang': locale.languageCode,
  //       }),
  //     );
  //     return OrderRateModel.fromJson(response.data);
  //   } on DioError catch (error) {
  //     Helpers.debugDioError(error);
  //     rethrow;
  //   } catch (error) {
  //     log(error.toString());
  //     throw LocaleKeys.genericErrorMessage.tr();
  //   }
  // }

  static Future<winchOrder.OrderRateModel> getWinchOrderDetails({
    required Locale locale,
    required int id,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);

    final storedVendorId = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.vendorID);

    final vendorId = int.tryParse(storedVendorId ?? '');
    log("Debug in getWinchOrderDetails vendorId= $vendorId");
    log("Debug in getWinchOrderDetails vendorId= ${SecureStorageKeys.vendorID}");
    final String api = (vendorId == 1)
        ? detailsCarPartsOrderEndPoint
        : (vendorId == 2)
            ? detailsCarPartsOrderCarPartsEndPoint
            : (vendorId == 3||vendorId == 61)
                ? detailsCarPartsOrderWinchEndPoint
                : detailsCarPartsOrderEmergencyEndPoint;

    try {
      final response = await ApiClient.instance.dio.get(
        api,
        queryParameters: {"id": id},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );
      return winchOrder.OrderRateModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<EmergencyOrderDetailsModel> getEmergencyOrderDetails({
    required Locale locale,
    required int id,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);

    try {
      final response = await ApiClient.instance.dio.get(
        detailsCarPartsOrderEmergencyEndPoint,
        queryParameters: {"id": id},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );
      return EmergencyOrderDetailsModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<OrderRateModel> getTiresOrderDetails({
    required Locale locale,
    required int id,
  }) async {
    try {
      final token = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);
      final response = await ApiClient.instance.dio.get(
        detailsTiresOrderEndPoint,
        queryParameters: {"id": id},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );
      return OrderRateModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<OrderRateModel> rateBatteryOrder({
    required Locale locale,
    required int id,
    required double productsRate,
    required double servicesRate,
    required String comment,
  }) async {
    try {
      final token = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);
      final response = await ApiClient.instance.dio.post(
        rateBatteryOrderEndPoint,
        data: {
          "order_id": id,
          "products_rate": productsRate,
          "services_rate": servicesRate,
          "worker_rate": 5,
          "comment": comment
        },
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );
      return OrderRateModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<OrderRateModel> rateTiresOrder({
    required Locale locale,
    required int id,
    required double productsRate,
    required double servicesRate,
    required String comment,
  }) async {
    try {
      final token = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);
      final response = await ApiClient.instance.dio.post(
        rateTiresOrderEndPoint,
        data: {
          "order_id": id,
          "products_rate": productsRate,
          "services_rate": servicesRate,
          "worker_rate": 5,
          "comment": comment
        },
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );
      return OrderRateModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<OrderRateModel> rateCarPartsOrder({
    required Locale locale,
    required int id,
    required double productsRate,
    required double servicesRate,
    required String comment,
  }) async {
    try {
      final token = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);
      final response = await ApiClient.instance.dio.post(
        rateCarPartsOrderEndPoint,
        data: {
          "order_id": id,
          "products_rate": productsRate,
          "services_rate": servicesRate,
          "worker_rate": 5,
          "comment": comment
        },
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );
      return OrderRateModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<AboutAppModel> getAboutApp({
    required Locale locale,
  }) async {
    try {
      final response = await ApiClient.instance.dio.get(
        aboutAppEndPoint,
        options: Options(headers: {
          'lang': locale.languageCode,
        }),
      );
      return AboutAppModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<AboutAppModel> getPrivacy({
    required Locale locale,
  }) async {
    try {
      final response = await ApiClient.instance.dio.get(
        privacyEndPoint,
        options: Options(headers: {
          'lang': locale.languageCode,
        }),
      );
      return AboutAppModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<AboutAppModel> getTerms({
    required Locale locale,
  }) async {
    try {
      final response = await ApiClient.instance.dio.get(
        termsEndPoint,
        options: Options(headers: {
          'lang': locale.languageCode,
        }),
      );
      return AboutAppModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<FAQModel> getFaq({
    required Locale locale,
  }) async {
    try {
      final response = await ApiClient.instance.dio.get(
        faqEndPoint,
        options: Options(headers: {
          'lang': locale.languageCode,
        }),
      );
      return FAQModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<RequirementsDoc> getRequirementsDoc({
    required Locale locale,
  }) async {
    final storedVendorId = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.vendorID);

    final id = int.tryParse(storedVendorId ?? '');

    final String api = (id == 1)
        ? registerRequirementsDocEndPoint
        : (id == 2)
            ? registerRequirementsDocCarPartsEndPoint
            : (id == 3)
                ? registerRequirementsDocWinchEndPoint
                : registerRequirementsDocEmergencyEndPoint;
    try {
      final response = await ApiClient.instance.dio.get(
        api,
        options: Options(headers: {
          'lang': locale.languageCode,
        }),
      );
      return RequirementsDoc.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<ProductsModel> getSearchProductsTires({
    required Locale locale,
    required int page,
    required int perPage,
    required String status,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);

    final storedVendorId = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.vendorID);

    final id = int.tryParse(storedVendorId ?? '');

    final String api = (id == 2)
        ? tiresProductsCarPartsEndPoint
        : (id == 3)
            ? tiresProductsWinchEndPoint
            : (id == 4)
                ? tiresProductsEmergencyEndPoint
                : tiresProductsEndPoint;

    try {
      final response = await ApiClient.instance.dio.get(
        '$api$status',
        queryParameters: {'page': page, 'perPage': perPage},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      // Helpers.logDioResponse(response);

      return ProductsModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<MyOrdersModel> getMyOrdersCarParts({
    required Locale locale,
    required int page,
    required int perPage,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);

    final storedVendorId = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.vendorID);

    final id = int.tryParse(storedVendorId ?? '');

    final String api = (id == 2)
        ? myOrdersCarPartsEndPoint
        : (id == 3)
            ? myOrdersWinchEndPoint
            : (id == 4)
                ? myOrdersEmergencyEndPoint
                : myOrdersEndPoint;

    try {
      final response = await ApiClient.instance.dio.get(
        api,
        queryParameters: {'page': page, 'perPage': perPage},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      // Helpers.logDioResponse(response);

      return MyOrdersModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<MyOrdersModel> getMyOrdersBatteries({
    required Locale locale,
    required String status,
    required int page,
    required int perPage,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);

    final storedVendorId = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.vendorID);

    final id = int.tryParse(storedVendorId ?? '');

    final String api = (id == 2)
        ? myOrdersBatteriesCarPartsEndPoint
        : (id == 3)
            ? myOrdersBatteriesWinchEndPoint
            : (id == 4)
                ? myOrdersBatteriesEmergencyEndPoint
                : myOrdersBatteriesEndPoint;

    try {
      print('getMyOrdersBatteries api $api$status');
      final response = await ApiClient.instance.dio.get('$api$status',

        queryParameters: {'page': page, 'perPage': perPage},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      print("getMyOrdersBatteries ${response.data}");

      return MyOrdersModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<WinchPreviousOrders> getMyOrdersWinch({
    required Locale locale,
    required int page,
    required int perPage,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);

    try {
      final response = await ApiClient.instance.dio.get(
        myOrdersBatteriesWinchEndPoint,
        queryParameters: {'page': page, 'perPage': perPage},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );
      print("getMyOrdersWinch ${response.data}");

      // Helpers.logDioResponse(response);

      return WinchPreviousOrders.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<EmergencyPreviousOrders> getMyOrdersEmergency({
    required Locale locale,
    required int page,
    required int perPage,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);

    try {
      final response = await ApiClient.instance.dio.get(
        myOrdersBatteriesEmergencyEndPoint,
        queryParameters: {'page': page, 'perPage': perPage},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );
      print("getMyOrdersEmergency ${response.data}");

      // Helpers.logDioResponse(response);

      return EmergencyPreviousOrders.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<MyOrdersModel> getMyOrdersTires({
    required Locale locale,
    required int page,
    required int perPage,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    try {
      final response = await ApiClient.instance.dio.get(
        myOrdersTiresEndPoint,
        queryParameters: {'page': page, 'perPage': perPage},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );
      print("getMyOrdersTires ${response.data}");

      // Helpers.logDioResponse(response);

      return MyOrdersModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  // static Future<ClientCarsListModel> getClientCars(
  //     {required Locale locale}) async {
  //   final token = await SecureStorageService.instance
  //       .readString(key: SecureStorageKeys.token);
  //   try {
  //     final response = await ApiClient.instance.dio.get(
  //       clientCarsEndPoint,
  //       options: Options(headers: {
  //         'Authorization': 'Bearer $token',
  //         'lang': locale.languageCode,
  //       }),
  //     );
  //
  //     // Helpers.logDioResponse(response);
  //
  //     return ClientCarsListModel.fromJson(response.data);
  //   } on DioError catch (error) {
  //     Helpers.debugDioError(error);
  //     rethrow;
  //   } catch (error) {
  //     log(error.toString());
  //     throw LocaleKeys.genericErrorMessage.tr();
  //   }
  // }

  static Future<List<CommentsModel>> getComments({required int id}) async {
    try {
      final response = await ApiClient.instance.dio.get(
        'posts/$id/comments',
      );

      return List<CommentsModel>.from(response.data
          .map((comment) => CommentsModel.fromJson(comment))
          .toList());
    } catch (error) {
      return [];
    }
  }

  static Future<ProductsModel> getPost({required int id}) async {
    try {
      final response = await ApiClient.instance.dio.get(
        'posts/$id',
      );

      return ProductsModel.fromJson(response.data);
    } catch (error) {
      rethrow;
    }
  }

  static Future<void> deletePost({required int id}) async {
    try {
      await ApiClient.instance.dio.delete(
        'api/products/?id=$id',
        options: Options(headers: authHeader),
      );
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<void> addProduct(
      {required double? price,
      required String? title,
      required String? image}) async {
    try {
      // final file = await h.MultipartFile.fromPath('image', image ?? '',
      //     contentType: MediaType('image', 'jpg'));
      await ApiClient.instance.dio.post('api/products/',
          options: Options(headers: authHeader),
          data: {
            "title": title ?? '',
            "price": price ?? 1,
            "image": image ?? ""
          });
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<ImageModel> uploadImage({
    required File? image,
    required Locale locale,
  }) async {
    try {
      if (image == null) {
        throw ApiException("No image selected");
      }

      final token = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);

      final file = await MultipartFile.fromFile(
        image.path,
        filename: image.path.split('/').last,
      );

      final formData = FormData.fromMap({
        'media[]': file
      });

      final response = await ApiClient.instance.dio.post(
        'media/upload',
        data: formData,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      return ImageModel.fromJson(response.data);
    } on DioException catch (error) {
      final message = handleDioError(error);
      throw ApiException(message);
    } catch (error) {
      throw ApiException("Unexpected error occurred");
    }
  }
  static Future<AddTireModel> addTire({
    required String description,
    required String sku,
    required String name,
    required String tireType,
    required int brandId,
    required int stock,
    required int price,
    required int priceBeforeDiscount,
    required int yearManufacture,
    required int length,
    required int width,
    required int height,
    required List<int> carIds,
    required List<String> images,
    required Locale locale,
  }) async {
    final data = {
      "name": name,
      "description": description,
      "sku": sku,
      "tire_type": tireType, //normal,flat
      "brand_id": brandId,
      "stock": stock,
      "price": price,
      "price_before_discount": priceBeforeDiscount,
      "year_of_manufacture": yearManufacture,
      "car_ids": carIds,
      "images": images,
      "default_image": images.isNotEmpty ? images.first : '',
      "height": height,
      "width": width,
      "length": length,
    };
    try {
      final token = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);

      final storedVendorId = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.vendorID);

      final id = int.tryParse(storedVendorId ?? '');

      final String api = (id == 2)
          ? addTireCarPartsEndPoint
          : (id == 3)
              ? addTireWinchEndPoint
              : (id == 4)
                  ? addTireEmergencyEndPoint
                  : addTireEndPoint;

      final response = await ApiClient.instance.dio.post(api,
          data: data,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'lang': locale.languageCode,
          }));

      return AddTireModel.fromJson(response.data);
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

  static Future<AddBatteryModel> addBattery({
    required String description,
    required String sku,
    required String name,
    required String tireType,
    required int brandId,
    required int stock,
    required int price,
    required int priceBeforeDiscount,
    required int yearManufacture,
    required List<int> carIds,
    required List<String> images,
    required String voltage,
    required Locale locale,
  }) async {
    final data = {
      "name": name,
      "description": description,
      "sku": sku,
      //"tire_type": tireType, //normal,flat
      "brand_id": brandId,
      "stock": stock,
      "price": price,
      "price_before_discount": priceBeforeDiscount,
      "year_of_manufacture": yearManufacture,
      "car_ids": carIds,
      "images": images,
      "default_image": images.isNotEmpty ? images.first : '',
      "voltage": voltage
    };
    try {
      final token = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);
      final response = await ApiClient.instance.dio.post(addBatteryEndPoint,
          data: data,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'lang': locale.languageCode,
          }));
      return AddBatteryModel.fromJson(response.data);
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

  static Future<AddBatteryModel> addCarParts({
    required String description,
    required String sku,
    required String name,
    required int categoryId,
    required int brandId,
    required int stock,
    required int price,
    required int priceBeforeDiscount,
    required List<int> carIds,
    required List<String> images,
    required String status,
    required Locale locale,
  }) async {
    final data = {
      "name": name,
      "description": description,
      "sku": sku,
      "brand_id": brandId,
      "category_id": categoryId,
      "stock": stock,
      "price": price,
      "price_before_discount": priceBeforeDiscount,
      "car_ids": carIds,
      "images": images,
      "default_image": images.isNotEmpty ? images.first : '',
      "status": status
    };
    try {
      final token = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);
      final response =
          await ApiClient.instance.dio.post(addBatteryCarPartsEndPoint,
              data: data,
              options: Options(headers: {
                'Authorization': 'Bearer $token',
                'lang': locale.languageCode,
              }));
      return AddBatteryModel.fromJson(response.data);
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

  // static Future<String> getImage({required File? imageName}) async {
  //   try {
  //     final i = await MultipartFile.fromFile('${imageName?.path}');
  //     // FormData file = FormData.fromMap({'file': i});
  //     final response = await ApiClient.instance.dio.get(
  //       'api/upload/${i.filename}',
  //       options: Options(headers: authHeader),
  //     );
  //     return response.data;
  //   } on DioError catch (error) {
  //     Helpers.debugDioError(error);
  //     rethrow;
  //   } catch (error) {
  //     log(error.toString());
  //     throw LocaleKeys.genericErrorMessage.tr();
  //   }
  // }

  static Future<void> editProduct(
      {required double? price,
      required String? title,
      required String? image,
      required int id}) async {
    try {
      // final file = await h.MultipartFile.fromPath('image', image ?? '',
      //     contentType: MediaType('image', 'jpg'));
      await ApiClient.instance.dio.put('api/products/?id=$id',
          options: Options(headers: authHeader),
          data: {
            "title": title ?? '',
            "price": price ?? 1,
            "image": image ?? ""
          });
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<MyTransactionsModel> getMyTransactions({
    required Locale locale,
    required int page,
    required int perPage,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    try {
      final response = await ApiClient.instance.dio.get(
        myTransactionEndPoint,
        queryParameters: {'page': page, 'perPage': perPage},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      return MyTransactionsModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<MyWithdrawalRequestsModel> getMyWithdrawalRequests({
    required Locale locale,
    required int page,
    required int perPage,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    try {
      final response = await ApiClient.instance.dio.get(
        myWithdrawalRequestsEndPoint,
        queryParameters: {'page': page, 'perPage': perPage},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      return MyWithdrawalRequestsModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<WithdrawalMethodsModel> getWithdrawalMethods({
    required Locale locale,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    try {
      final response = await ApiClient.instance.dio.get(
        withdrawalMethodsEndPoint,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      return WithdrawalMethodsModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<SentWithdrawalMethodModel> sentWithdrawalMethod({
    required Locale locale,
    required int amount,
    required String method,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    try {
      final response = await ApiClient.instance.dio.post(
        sentWithdrawalMethodEndPoint,
        data: {"amount": amount, "method": method},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      return SentWithdrawalMethodModel.fromJson(response.data);
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
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<WinchOffersModel> getWinchOffers({
    required Locale locale,
    required double lat,
    required double lon,
  }) async {

    /// prevent duplicate recursion
    if (_isGettingOffers) {
      return WinchOffersModel();
    }

    _isGettingOffers = true;

    try {

      final token = await SecureStorageService.instance.readString(key: SecureStorageKeys.token);

      /// stop after logout
      if (token == null || token.isEmpty) {
        return WinchOffersModel(
          message: 'Token not found',
          data: null,
        );
      }
      if (SessionManager.isLoggedOut) {
        return WinchOffersModel(
          message: 'Logged out',
          data: null,
        );
      }

      final response = await ApiClient.instance.dio.get(
        getWinchOffersEndPoint,
        cancelToken: SessionManager.cancelToken,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'lang': locale.languageCode,
          },

          validateStatus: (status) => true,
        ),
      );

      print("token============ $token");

      /// unauthorized
      if (response.statusCode == 401) {
        return WinchOffersModel(
          message: 'Unauthorized',
          data: null,
        );
      }

      /// safe fire-and-forget
      Future.microtask(() async {
        if (!_isUpdatingLocation) {
          await updateWinchLocation(
            locale: locale,
            lat: lat,
            lon: lon,
          );
        }
      });

      return WinchOffersModel.fromJson(response.data);

    } on DioError catch (error) {

      Helpers.debugDioError(error);

      return WinchOffersModel(
        message: 'Network error',
        data: null,
      );

    } catch (error) {

      log(error.toString());

      return WinchOffersModel(
        message: LocaleKeys.genericErrorMessage.tr(),
        data: null,
      );

    } finally {

      _isGettingOffers = false;

    }
  }

  static Future<EmergencyOffersModel> getEmergencyOffers({
    required Locale locale,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    try {
      final response = await ApiClient.instance.dio.get(
        getEmergencyOffersEndPoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'lang': locale.languageCode,
          },
          // Override validateStatus to prevent DioExceptions for server errors
          validateStatus: (status) => true,
        ),
      );

      // Handle error status codes
      if (response.statusCode != 200) {
        log('Emergency offers API error: ${response.statusCode} - ${response.statusMessage}');
        return EmergencyOffersModel(message: 'Error loading offers', data: null);
      }

      return EmergencyOffersModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      // Return an empty model instead of rethrowing
      return EmergencyOffersModel(message: 'Network error', data: null);
    } catch (error) {
      log('Unknown error in getEmergencyOffers: ${error.toString()}');
      // Return an empty model instead of throwing
      return EmergencyOffersModel(message: LocaleKeys.genericErrorMessage.tr(), data: null);
    }
  }

  static Future<UpdateLocationModel> sentWinchOffer({
    required Locale locale,
    required int orderId,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    try {
      final response = await ApiClient.instance.dio.post(
        sentOfferEndPoint,
        data: {'order_id': orderId},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      return UpdateLocationModel.fromJson(response.data);
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

  static Future<UpdateLocationModel> sentEmergencyOffer({
    required Locale locale,
    required int orderId,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    try {
      final response = await ApiClient.instance.dio.post(
        sentOfferEmergencyEndPoint,
        data: {'order_id': orderId},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      return UpdateLocationModel.fromJson(response.data);
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

  static Future<UpdateOrderStatus> updateOrderStatusWinch({
    required Locale locale,
    required int orderId,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    try {
      final response = await ApiClient.instance.dio.post(
        updateOrderStatusEndPoint,
        data: {"id": orderId, "status": "completed"},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );
      print("Api= ${updateOrderStatusEndPoint}");
      print("orderId= ${orderId}");
      print("status= completed");
      print("token= ${token}");
      print("data= ${response.data}");
      print("response= ${UpdateOrderStatus.fromJson(response.data)}");
      return UpdateOrderStatus.fromJson(response.data);
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

  static Future<UpdateOrderStatus> updateCarPartsOrderStatus({
    required Locale locale,
    required int orderId,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    try {
      final response = await ApiClient.instance.dio.post(
        updateCarPartsOrderStatusEndPoint,
        data: {"id": orderId, "status": "completed"},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );
      print("Api= ${updateCarPartsOrderStatusEndPoint}");
      print("orderId= ${orderId}");
      print("status= completed");
      print("token= ${token}");
      print("data= ${response.data}");
      print("response= ${UpdateOrderStatus.fromJson(response.data)}");
      return UpdateOrderStatus.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);

      if (error.response!.statusCode == 422 || error.response!.statusCode == 400) {
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

  static Future<UpdateOrderStatus> carPartsSubmitPriceOffer({
    required Locale locale,
    required int orderId,
    required num offered_total,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);

    try {
      final response = await ApiClient.instance.dio.post(
        carPartsSubmitPriceOfferEndPoint,
        data: {
          "order_vendor_id": orderId,
          "offered_total": offered_total,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'lang': locale.languageCode,
          },
        ),
      );

      print("Api= $carPartsSubmitPriceOfferEndPoint");
      print("orderId= $orderId");
      print("offered_total= $offered_total");
      print("token= $token");
      print("data= ${response.data}");

      return UpdateOrderStatus.fromJson(response.data);

    } on DioException catch (error) {

      Helpers.debugDioError(error);

      final statusCode = error.response?.statusCode;

      if (statusCode == 422 || statusCode == 400) {
        final errorMsg =
            error.response?.data['message']?.toString() ??
                'Unknown error';

        throw ApiException(errorMsg);
      }

      throw ApiException(
        error.response?.data['message']?.toString() ??
            error.message ??
            'Something went wrong',
      );

    } on ApiException {
      rethrow;

    } catch (error, stackTrace) {

      log(error.toString());
      log(stackTrace.toString());

      throw ApiException(error.toString());
    }
  }

  static Future<UpdateOrderStatus> updateOrderStatusEmergency({
    required Locale locale,
    required int orderId,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    try {
      final response = await ApiClient.instance.dio.post(
        updateEmergencyOrderStatusEndPoint,
        data: {"id": orderId, "status": "completed"},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      return UpdateOrderStatus.fromJson(response.data);
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
  static bool _isUpdatingLocation = false;
  static bool _isGettingOffers = false;
  static Future<UpdateLocationModel> updateWinchLocation({
    required Locale locale,
    required double lat,
    required double lon,
  }) async {

    /// prevent duplicate recursion
    if (_isUpdatingLocation) {
      return UpdateLocationModel();
    }

    _isUpdatingLocation = true;

    try {

      final token = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);

      /// stop after logout
      if (token == null || token.isEmpty) {
        return UpdateLocationModel(
          message: 'Token not found',
        );
      }

      final response = await ApiClient.instance.dio.post(
        updateLocationEndPoint,
        data: {
          "lat": lat,
          "lon": lon,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'lang': locale.languageCode,
          },

          validateStatus: (status) => true,
        ),
      );

      print("Api == $updateLocationEndPoint");
      print("lat == $lat");
      print("lon == $lon");

      /// unauthorized
      if (response.statusCode == 401) {
        return UpdateLocationModel(
          message: 'Unauthorized',
        );
      }

      /// safe fire-and-forget
      Future.microtask(() async {
        if (!_isGettingOffers) {
          await getWinchOffers(
            locale: locale,
            lat: lat,
            lon: lon,
          );
        }
      });

      return UpdateLocationModel.fromJson(response.data);

    } on DioError catch (error) {

      Helpers.debugDioError(error);

      return UpdateLocationModel(
        message: 'Network error',
      );

    } catch (error) {

      log(error.toString());

      return UpdateLocationModel(
        message: LocaleKeys.genericErrorMessage.tr(),
      );

    } finally {

      _isUpdatingLocation = false;

    }
  }

  static Future<UpdateLocationModel> updateEmergencyLocation({
    required Locale locale,
    required double lat,
    required double lon,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    try {
      final response = await ApiClient.instance.dio.post(
        updateLocationEmergencyEndPoint,
        data: {"lat": lat, "lon": lon},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );
      getEmergencyOffers(locale: locale);
      return UpdateLocationModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);
      rethrow;
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<UpdateLocationModel> rejectWinchOffer({
    required Locale locale,
    required int orderId,
  }) async {
    try {
      final token = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);
      final data = {
        "order_id": orderId,
      };

      final response = await ApiClient.instance.dio.post(
        rejectOfferEndPoint,
        data: data,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      return UpdateLocationModel.fromJson(response.data);
    } catch (error) {
      rethrow;
    }
  }

  static Future<UpdateLocationModel> rejectEmergencyOffer({
    required Locale locale,
    required int orderId,
  }) async {
    try {
      final token = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);
      final data = {
        "order_id": orderId,
      };

      final response = await ApiClient.instance.dio.post(
        rejectOfferEmergencyEndPoint,
        data: data,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      return UpdateLocationModel.fromJson(response.data);
    } catch (error) {
      rethrow;
    }
  }

  static Future<EmergencyServicesModel> listServicesEmergency({
    required Locale locale,
  }) async {
    try {
      final token = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);

      final response = await ApiClient.instance.dio.get(
        listServicesEmergencyEndPoint,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      log(';kejrnjjkj ${response.data}');
      return EmergencyServicesModel.fromJson(response.data);
    } catch (error) {
      rethrow;
    }
  }

  static Future<UpdateServiceEmergencyModel> updateServiceEmergency({
    required Locale locale,
    required int orderId,
    required List<Map<String, int>> services,
  }) async {
    try {
      final token = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);
      final data = {
        "order_id": orderId,
        "services": services,
      };

      final response = await ApiClient.instance.dio.post(
        updateServiceEmergencyEndPoint,
        data: data,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      return UpdateServiceEmergencyModel.fromJson(response.data);
    } catch (error) {
      rethrow;
    }
  }
}

class ServicesIDs {
  int? id;

  ServicesIDs({this.id});

  ServicesIDs.fromJson(Map<String, dynamic> json) {
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    return data;
  }
}
