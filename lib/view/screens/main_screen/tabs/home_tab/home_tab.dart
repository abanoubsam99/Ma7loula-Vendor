import 'dart:io';

// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ma7lola_vendor/core/utils/assets_manager.dart';
import 'package:ma7lola_vendor/core/widgets/custom_app_bar.dart';
import 'package:ma7lola_vendor/model/category_model.dart';
import 'package:ma7lola_vendor/view/screens/main_screen/tabs/home_tab/notification_screen.dart';
import 'package:ma7lola_vendor/view/screens/main_screen/tabs/home_tab/top_slider.dart';
import 'package:ma7lola_vendor/view/screens/main_screen/tabs/my_products_tab/tires/my_tires.dart';
import 'package:ma7lola_vendor/view/screens/main_screen/tabs/my_products_tab/batteries/my_batteries.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:upgrader/upgrader.dart';

import '../../../../../controller/user_provider.dart';
import '../../../../../core/generated/locale_keys.g.dart';
import '../../../../../core/services/secure_storage/secure_storage_keys.dart.dart';
import '../../../../../core/services/secure_storage/secure_storage_service.dart';
import '../../../../../core/utils/colors_palette.dart';
import '../../../../../core/utils/font.dart';
import '../../../../../core/utils/snackbars.dart';
import '../../../../../core/utils/util_values.dart';
import '../../main_screen.dart';
import 'local_widgets/category_card.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeTabState();
  }
}

class _HomeTabState extends State<HomeTab> {
  bool _isInit = false;
  DateTime _backButtonTimestamp = DateTime.now();
  // late dynamic apiController;
  late UserProvider userProvider;
  List _fetchedTrendProducts = [];

  bool _isLoading = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      // checkInternetConnectivity();

      //SizeConfig.screenWidth = MediaQuery.of(context).size.width;
      //SizeConfig.screenHeight = MediaQuery.of(context).size.height;
      userProvider = context.read<UserProvider>();

      // apiController = context.read<ApiController>();

      // userProvider.autoLogin();
      // MiscellaneousApi.getCategories();
      // MiscellaneousApi.getTrendProducts().then((trendProducts) {
      //   setState(() => _fetchedTrendProducts = trendProducts);
      // });

      _scrollController = ScrollController()
        ..addListener(
          () {
            setState(() {
              if (_scrollController.offset >= 400) {
                _showBackToTopButton = true;
              } else {
                _showBackToTopButton = false;
              }
            });
          },
        );
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  bool _showBackToTopButton = false;
  late ScrollController _scrollController;
  int index1 = 2;

  // Future<bool> checkInternetConnectivity() async {
  //   final connectivityResult = await Connectivity().checkConnectivity();
  //   if (connectivityResult == ConnectivityResult.none) {
  //     setState(() {
  //       isInternetConnected = false;
  //     });
  //     return false;
  //   } else {
  //     setState(() {
  //       isInternetConnected = true;
  //     });
  //     return true;
  //   }
  // }

  // bool isInternetConnected = false;

  /* Future<void> checkInternet() async {
    final result = await checkInternetConnectivity();
    setState(() {
      isInternetConnected = result;
    });
  }
*/

  Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      setState(() {
        isOnline = true;
      });
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      setState(() {
        isOnline = false;
      });
      return false;
    }
  }

  bool isOnline = false;

  Future<int?>? _getVendorId() async {
    final storedVendorId = await SecureStorageService.instance.readString(key: SecureStorageKeys.vendorID);
    return int.tryParse(storedVendorId ?? '') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final List<CategoriesModel> categories = [
      CategoriesModel(
          pic: AssetsManager.simple,
          title: LocaleKeys.tires.tr(),
          onTap: () {
            // Navigate directly to the MyTiresScreen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyTiresScreen(
                  index: 0,
                ),
              ),
            );
          }),
      CategoriesModel(
          pic: AssetsManager.simple1,
          title: LocaleKeys.batteries.tr(),
          onTap: () {
            // Navigate directly to the MyBatteriesScreen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyBatteriesScreen(
                  index: 0,
                ),
              ),
            );
          }),
      CategoriesModel(
          pic: AssetsManager.fileList,
          title: LocaleKeys.myOrders.tr(),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MainScreen(
                        index: 2,
                      )),
            );
          }),
    ];
    final List<CategoriesModel> categoriesCarParts = [
      CategoriesModel(
          pic: AssetsManager.simple2,
          title: LocaleKeys.products.tr(),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MainScreen(
                        index: 1,
                      )),
            );
          }),
      CategoriesModel(
          pic: AssetsManager.fileList,
          title: LocaleKeys.myOrders.tr(),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MainScreen(
                        index: 2,
                      )),
            );
          }),
    ];
    final List<CategoriesModel> categoriesWinch = [
      CategoriesModel(
          pic: AssetsManager.wallet,
          title: LocaleKeys.drawerWallet.tr(),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MainScreen(
                        index: 1,
                      )),
            );
          }),
      CategoriesModel(
          pic: AssetsManager.fileList,
          title: LocaleKeys.myOrders.tr(),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MainScreen(
                        index: 2,
                      )),
            );
          }),
    ];

    return WillPopScope(
      onWillPop: () => _doubleBackToExit(context),
      child: UpgradeAlert(
        child: Scaffold(
          backgroundColor: ColorsPalette.white,
          appBar: CustomAppBar(
            actions: [
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, NotificationsScreen.routeName);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: SvgPicture.asset(AssetsManager.notification),
                ),
              ),
            ],
          ),
          body:    CustomScrollView(
            physics: UtilValues.scrollPhysics,
            controller: _scrollController,
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    // _homeGetAddress(),
                    // UtilValues.gap12,
                    TopSlider(),
                    UtilValues.gap16,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        LocaleKeys.searchingFor.tr(),
                        style: TextStyle(
                          color: ColorsPalette.veryDarkGrey,
                          fontWeight: FontWeight.w600,
                          fontFamily: ZainTextStyles.font,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                    UtilValues.gap8,
                    FutureBuilder<int?>(
                        future: _getVendorId(),
                        builder: (context, snapshot) {
                          return Column(
                            children: [
                              if (snapshot.data == 1)
                                SizedBox(
                                  height: MediaQuery.of(context).size.height - 400,
                                  child: ListView.separated(
                                      separatorBuilder: (context, index) {
                                        return UtilValues.gap4;
                                      },
                                      itemCount: categories.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: CategoriesCard(
                                            title: categories[index].title ?? '',
                                            pic: categories[index].pic ?? '',
                                            onTap: categories[index].onTap,
                                          ),
                                        );
                                      }),
                                ),
                              if (snapshot.data == 2)
                                SizedBox(
                                  height: MediaQuery.of(context).size.height - 400,
                                  child: ListView.separated(
                                      separatorBuilder: (context, index) {
                                        return UtilValues.gap4;
                                      },
                                      itemCount: categoriesCarParts.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: CategoriesCard(
                                            title: categoriesCarParts[index].title ?? '',
                                            pic: categoriesCarParts[index].pic ?? '',
                                            onTap: categoriesCarParts[index].onTap,
                                          ),
                                        );
                                      }),
                                ),
                              if (snapshot.data == 3)
                                SizedBox(
                                  height: MediaQuery.of(context).size.height - 400,
                                  child: ListView.separated(
                                      separatorBuilder: (context, index) {
                                        return UtilValues.gap4;
                                      },
                                      itemCount: categoriesWinch.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: CategoriesCard(
                                            title: categoriesWinch[index].title ?? '',
                                            pic: categoriesWinch[index].pic ?? '',
                                            onTap: categoriesWinch[index].onTap,
                                          ),
                                        );
                                      }),
                                ),
                              if (snapshot.data == 4)
                                SizedBox(
                                  width: double.maxFinite,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: CategoriesCard(
                                        pic: AssetsManager.fileList,
                                        title: LocaleKeys.myOrders.tr(),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => MainScreen(
                                                  index: 1,
                                                )),
                                          );
                                        }),
                                  ),
                                )
                            ],
                          );
                        })
                  ],
                ),
              )
            ],
          )
          // body: isInternetConnected == true || isOnline == true
          //     ?
          // CustomScrollView(
          //         physics: UtilValues.scrollPhysics,
          //         controller: _scrollController,
          //         slivers: [
          //           SliverList(
          //             delegate: SliverChildListDelegate(
          //               [
          //                 // _homeGetAddress(),
          //                 // UtilValues.gap12,
          //                 TopSlider(),
          //                 UtilValues.gap16,
          //                 Padding(
          //                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
          //                   child: Text(
          //                     LocaleKeys.searchingFor.tr(),
          //                     style: TextStyle(
          //                       color: ColorsPalette.veryDarkGrey,
          //                       fontWeight: FontWeight.w600,
          //                       fontFamily: ZainTextStyles.font,
          //                       fontSize: 10.sp,
          //                     ),
          //                   ),
          //                 ),
          //                 UtilValues.gap8,
          //                 FutureBuilder<int?>(
          //                     future: _getVendorId(),
          //                     builder: (context, snapshot) {
          //                       return Column(
          //                         children: [
          //                           if (snapshot.data == 1)
          //                             SizedBox(
          //                               height: MediaQuery.of(context).size.height - 400,
          //                               child: ListView.separated(
          //                                   separatorBuilder: (context, index) {
          //                                     return UtilValues.gap4;
          //                                   },
          //                                   itemCount: categories.length,
          //                                   itemBuilder: (context, index) {
          //                                     return Padding(
          //                                       padding: const EdgeInsets.symmetric(horizontal: 8.0),
          //                                       child: CategoriesCard(
          //                                         title: categories[index].title ?? '',
          //                                         pic: categories[index].pic ?? '',
          //                                         onTap: categories[index].onTap,
          //                                       ),
          //                                     );
          //                                   }),
          //                             ),
          //                           if (snapshot.data == 2)
          //                             SizedBox(
          //                               height: MediaQuery.of(context).size.height - 400,
          //                               child: ListView.separated(
          //                                   separatorBuilder: (context, index) {
          //                                     return UtilValues.gap4;
          //                                   },
          //                                   itemCount: categoriesCarParts.length,
          //                                   itemBuilder: (context, index) {
          //                                     return Padding(
          //                                       padding: const EdgeInsets.symmetric(horizontal: 8.0),
          //                                       child: CategoriesCard(
          //                                         title: categoriesCarParts[index].title ?? '',
          //                                         pic: categoriesCarParts[index].pic ?? '',
          //                                         onTap: categoriesCarParts[index].onTap,
          //                                       ),
          //                                     );
          //                                   }),
          //                             ),
          //                           if (snapshot.data == 3)
          //                             SizedBox(
          //                               height: MediaQuery.of(context).size.height - 400,
          //                               child: ListView.separated(
          //                                   separatorBuilder: (context, index) {
          //                                     return UtilValues.gap4;
          //                                   },
          //                                   itemCount: categoriesWinch.length,
          //                                   itemBuilder: (context, index) {
          //                                     return Padding(
          //                                       padding: const EdgeInsets.symmetric(horizontal: 8.0),
          //                                       child: CategoriesCard(
          //                                         title: categoriesWinch[index].title ?? '',
          //                                         pic: categoriesWinch[index].pic ?? '',
          //                                         onTap: categoriesWinch[index].onTap,
          //                                       ),
          //                                     );
          //                                   }),
          //                             ),
          //                           if (snapshot.data == 4)
          //                             SizedBox(
          //                               width: double.maxFinite,
          //                               child: Padding(
          //                                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
          //                                 child: CategoriesCard(
          //                                     pic: AssetsManager.fileList,
          //                                     title: LocaleKeys.myOrders.tr(),
          //                                     onTap: () {
          //                                       Navigator.push(
          //                                         context,
          //                                         MaterialPageRoute(
          //                                             builder: (context) => MainScreen(
          //                                                   index: 1,
          //                                                 )),
          //                                       );
          //                                     }),
          //                               ),
          //                             )
          //                         ],
          //                       );
          //                     })
          //               ],
          //             ),
          //           )
          //         ],
          //       )
          //     : const Center(child: Text('Check Internet Connectivity')),
        ),
      ),
    );
  }

  Future<bool> _doubleBackToExit(BuildContext context) async {
    final differenceBetweenNowAndLastTimestamp = DateTime.now().difference(_backButtonTimestamp);
    if (differenceBetweenNowAndLastTimestamp.inSeconds > 1) {
      showSnackbar(
        context: context,
        status: SnackbarStatus.info,
        message: LocaleKeys.doubleBackToExit.tr(),
      );
      _backButtonTimestamp = DateTime.now();
      return false;
    } else {
      return true;
    }
  }
}
