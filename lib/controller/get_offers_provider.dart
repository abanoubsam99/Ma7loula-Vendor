import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../core/services/http/apis/miscellaneous_api.dart';
import '../core/services/secure_storage/secure_storage_keys.dart.dart';
import '../core/services/secure_storage/secure_storage_service.dart';
import '../model/winch/winch_offers_model.dart';

class GetWinchOffersProvider extends ChangeNotifier {
  Timer? timer;
  Timer? timerEm;
  late WinchOffersModel listRequests=WinchOffersModel();

  void closeTimer() {
    timer?.cancel();
    timerEm?.cancel();
    timer = null;
    timerEm = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void startTimerRequestLiveTutors({
    required Locale locale,
    required double lat,
    required double lon,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    final vendorId = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.vendorID);
        
    print('DEBUG - Starting timer to check winch requests with token: ${token != null ? "Valid" : "NULL"} and vendor ID: $vendorId');
    
    if (token == null) {
      print('DEBUG - Cannot start winch request timer: token is null');
      return;
    }

    closeTimer();
    print('DEBUG - Setting up timer for winch requests check every 4 seconds');
    
    timerEm = Timer.periodic(const Duration(seconds: 4), (_) async {
      print('DEBUG - Timer triggered: checking for pending winch requests');
      await getPendingRequest(locale: locale,lat:lat,lon: lon);
    });
  }

  void startTimerLiveLocation({
    required Locale locale,
    required double lat,
    required double lon,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    if (token == null) return;
    closeTimer();
    timer = Timer.periodic(const Duration(seconds: 4), (_) async {
      await getLocation(locale: locale, lat: lat, lon: lon);
    });
  }

  Future getLocation({
    required Locale locale,
    required double lat,
    required double lon,
  }) async {
    try {
      final offers = await MiscellaneousApi.updateWinchLocation(
          locale: locale, lat: lat, lon: lon);
      notifyListeners();
      return offers;
    } catch (error) {
      notifyListeners();
    }
  }

  Future<WinchOffersModel> getPendingRequest({
    required Locale locale,
    required double lat,
    required double lon,
  }) async {
    try {
      final vendorId = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.vendorID);
      print('DEBUG - Checking for winch offers with vendor ID: $vendorId');
      
      final offers = await MiscellaneousApi.getWinchOffers(locale: locale,lat:lat,lon:lon);
      print('DEBUG - Winch offers API response received: ${offers.message}');
      print('DEBUG - Offers data: ${offers.data?.requests != null && offers.data!.requests!.isNotEmpty ? "Has ${offers.data!.requests!.length} pending requests" : "No pending requests"}');
      print('DEBUG - Accepted offer: ${offers.data?.acceptedOffer != null ? "Has accepted offer" : "No accepted offer"}');
      
      listRequests = offers;
      notifyListeners();
      return offers;
    } catch (error) {
      print('DEBUG - Error getting winch offers: $error');
      notifyListeners();
      return listRequests;
    }
  }

  /* void startTimerEmergency({
    required Locale locale,
    required int orderId,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    if (token == null) return;

    closeTimer();

    timerEm = Timer.periodic(const Duration(seconds: 4), (_) async {
      */ /* final offers =*/ /*
      await getPendingEmergency(locale: locale, orderId: orderId);

      // if (offers?.isEmpty ?? true) {
      //   closeTimer();
      // }
    });
  }*/

  /*Future<List<Wokers>?> getPendingEmergency({
    required Locale locale,
    required int orderId,
  }) async {
    try {
      final offers = await MiscellaneousApi.getEmergencyOffers(
          locale: locale, orderId: orderId);

      listEmergency = offers.data?.wokers ?? [];
      notifyListeners();
      return listEmergency;
    } catch (error) {
      listEmergency = [];
      notifyListeners();
      return listEmergency;
    }
  }*/
}
