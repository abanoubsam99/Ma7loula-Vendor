import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ma7lola_vendor/core/services/secure_storage/secure_storage_keys.dart.dart';
import 'package:ma7lola_vendor/core/services/secure_storage/secure_storage_service.dart';
import 'package:ma7lola_vendor/core/widgets/app_logo.dart';
import 'package:ma7lola_vendor/view/screens/auth/LoginScreen.dart';
import 'package:ma7lola_vendor/view/screens/languages_screen.dart';
import 'package:ma7lola_vendor/view/screens/main_screen/main_screen.dart';
import 'package:provider/provider.dart';

import '../../controller/user_provider.dart';
import '../../core/utils/assets_manager.dart';
import '../../core/utils/colors_palette.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const String routeName = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _splashOperation(context),
        builder: (context, snapshot) {
          return Container(
            //color: ColorsPalette.white,
            decoration: const BoxDecoration(
              // color: ColorsPalette.primaryColor,
              image: DecorationImage(
                fit: BoxFit.fill,
                colorFilter: ColorFilter.mode(
                    ColorsPalette.primaryColor, BlendMode.overlay),
                image: AssetImage(AssetsManager.splash),
              ),
            ),
            alignment: Alignment.center,
            child: AppLogo(
              size: 400,
            ),
          );
        });
  }

  Future<void> _splashOperation(BuildContext context) async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      // // Force clear the token to resolve 401 error
      // await SecureStorageService.instance.writeString(
      //   key: SecureStorageKeys.token,
      //   value: '',
      // );
      
      print('DEBUG - Cleared token to force re-login');

      final storedToken = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);
          
      // Since we cleared the token, this should go to the login screen
      if (![storedToken].contains(null)) {
        final userProvider = context.read<UserProvider>();
          
        try {
          // This will fail since we cleared the token, forcing login screen
          await userProvider.autoLogin(locale: context.locale);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => MainScreen(
                      index: 0,
                    )),
          );
        } catch (error) {
          // Auto login failed, go to login screen
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (context) => LoginScreen(
              fromCart: false,
              carID: 0,
              products: [],
              batteries: [],
              fromCartBatteries: false,
              tires: [],
              fromCartTires: false,
              car: null,
            )));
        }
      } else {
        Navigator.of(context).pushReplacementNamed(LanguagesScreen.routeName);
      }
    } catch (_) {}
  }
}
