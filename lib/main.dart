import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/localization/l10n.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'controller/car_provider.dart';
import 'controller/get_emergency_offers_provider.dart';
import 'controller/get_offers_provider.dart';
import 'controller/products_provider.dart';
import 'controller/start_up_slides_provider.dart';
import 'controller/user_provider.dart';
import 'core/generated/locale_keys.g.dart';
import 'core/utils/app_config.dart';
import 'core/utils/assets_manager.dart';
import 'core/utils/colors_palette.dart';
import 'core/utils/notifyHelper.dart';
import 'core/widgets/responsive_helper.dart';
import 'firebase_options.dart';
/*
* Vendor Emergency. New 19jun
01014981809
Q!1234567
*
Vendor wins
01142218113
A!123456
*
Vendor wins
01015981822
Aa@123456

winch
vendor@ma7lola.com
01274696869
01274696869
*
bt-vendor
01007587411
Aa@123456

* */


/*Main Vendors
* Ma7loula Emergency
* phone: 01234567898
* pass : 12345679
*Ma7loula Winch
* phone: 01234567899
* pass : Aa@123456
*
* App Vendors
* *Ma7loula 1 تغيير بطاريات  bt-vendor
* phone: 01234567897
* pass : Aa@123456
* Ma7loula 2 قطع غيال  car-parts-vendor
* phone: 01234567896
* pass : Aa@123456
* Mahlola winsh  ونش   winch
* phone: 01234567895
* pass : Aa@123456
* mahlola emerg  طوارئ   Emergency
* Vendor Emergency. New 19jun
01014981809
Q!1234567
* */

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  EasyLocalization.logger.enableBuildModes = [];
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  NotificationsHelper().initialize();
  runApp(
    EasyLocalization(
      path: AssetsManager.translationsFolder,
      supportedLocales: AppConfig.supportedLocales,
      fallbackLocale: AppConfig.fallbackLocale,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationsHelper().handleLaunchNotification();
    });
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);

    return Sizer(builder: ((context, constraints, deviceType) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => StartUpSlidesProvider()),
          ChangeNotifierProvider(create: (context) => ProductsProvider()),
          ChangeNotifierProvider(create: (context) => UserProvider()),
          ChangeNotifierProvider(create: (context) => CarProvider()),
          ChangeNotifierProvider(create: (context) => GetWinchOffersProvider()),
          ChangeNotifierProvider(create: (context) => GetEmergencyOffersProvider()),
        ],
        child: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus!.unfocus();
          },
          child: MaterialApp(
            navigatorKey: NotificationsHelper.navigatorKey,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: [
              ...context.localizationDelegates,
              FormBuilderLocalizations.delegate,
            ],
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            onGenerateTitle: (context) => LocaleKeys.appName.tr(),
            theme: ThemeData(
              canvasColor: ColorsPalette.white,
              colorScheme: ColorScheme.fromSwatch(
                primarySwatch: ColorsPalette.primarySwatch,
              )
                  .copyWith(
                    secondary: ColorsPalette.accentColor,
                  )
                  .copyWith(background: ColorsPalette.white),
            ),
            routes: AppConfig.routes,
          ),
        ),
      );
    }));
  }
}

/// in client app
/// should update location like here
/// font sizes
/// and in this vendor app we should test update order status
/// for winch and emergency and get list of services
/// and update service
