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
  late final Future<void> _splashFuture;

  @override
  void initState() {
    super.initState();
    _splashFuture = _splashOperation();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _splashFuture,
      builder: (context, snapshot) {
        return Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fill,
              colorFilter: ColorFilter.mode(
                ColorsPalette.primaryColor,
                BlendMode.overlay,
              ),
              image: AssetImage(AssetsManager.splash),
            ),
          ),
          alignment: Alignment.center,
          child: const AppLogo(
            size: 400,
          ),
        );
      },
    );
  }

  Future<void> _splashOperation() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      final storedToken = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);

      if (!mounted) return;

      if (storedToken != null) {
        final userProvider = context.read<UserProvider>();
        try {
          await userProvider.autoLogin(locale: context.locale);
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainScreen(
                index: 0,
              ),
            ),
          );
        } catch (error) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(
                fromCart: false,
                carID: 0,
                products: [],
                batteries: [],
                fromCartBatteries: false,
                tires: [],
                fromCartTires: false,
                car: null,
              ),
            ),
          );
        }
      } else {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(LanguagesScreen.routeName);
      }
    } catch (_) {
      // Ignore splash errors; keep showing splash until user restarts.
    }
  }
}
