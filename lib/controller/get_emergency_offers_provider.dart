import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../core/services/http/apis/miscellaneous_api.dart';
import '../core/services/secure_storage/secure_storage_keys.dart.dart';
import '../core/services/secure_storage/secure_storage_service.dart';
import '../model/emergency/emergency_offers_model.dart';

class GetEmergencyOffersProvider extends ChangeNotifier {
  Timer? timer;
  Timer? timerEm;
  late EmergencyOffersModel listRequests;

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
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    if (token == null) return;

    closeTimer();

    timerEm = Timer.periodic(const Duration(seconds: 4), (_) async {
      await getPendingRequest(locale: locale);
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
      final offers = await MiscellaneousApi.updateEmergencyLocation(
          locale: locale, lat: lat, lon: lon);

      notifyListeners();
      return offers;
    } catch (error) {
      notifyListeners();
    }
  }

  Future<EmergencyOffersModel> getPendingRequest({
    required Locale locale,
  }) async {
    try {
      final offers = await MiscellaneousApi.getEmergencyOffers(locale: locale);
      listRequests = offers;
      notifyListeners();
      return offers;
    } catch (error) {
      notifyListeners();
      return listRequests;
    }
  }
}
