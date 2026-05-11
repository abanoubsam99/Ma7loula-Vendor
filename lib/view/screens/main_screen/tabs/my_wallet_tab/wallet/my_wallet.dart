import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ma7lola_vendor/view/screens/main_screen/tabs/my_wallet_tab/wallet/local_widget/winch_product_card.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../controller/user_provider.dart';
import '../../../../../../core/generated/locale_keys.g.dart';
import '../../../../../../core/services/http/apis/miscellaneous_api.dart';
import '../../../../../../core/utils/assets_manager.dart';
import '../../../../../../core/utils/colors_palette.dart';
import '../../../../../../core/utils/font.dart';
import '../../../../../../core/utils/helpers.dart';
import '../../../../../../core/utils/util_values.dart';
import '../../../../../../core/widgets/loading_widget.dart';
import '../../../../../../model/winch/my_transactions_model.dart';
import '../../../../../../model/winch/my_withdrawal_requests_model.dart';
import '../../my_orders_tab/local_widet/no_orders_found.dart';
import 'sent_withdrawal_request_screen.dart';

class MyWalletScreen extends StatefulWidget {
  MyWalletScreen({Key? key, required this.index}) : super(key: key);
  int index = 0;
  @override
  State<MyWalletScreen> createState() => _MyWalletScreenState();
}

class _MyWalletScreenState extends State<MyWalletScreen>
    with TickerProviderStateMixin {
  final _numberOfPostsPerRequest = 20;

  int ordersLength = 0;

  final _scrollController = ScrollController();
  late TabController _tabController;

  @override
  void initState() {
    _scrollController.addListener(() {
      if (!(_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse)) {
        return;
      }
      FocusScope.of(context).unfocus();
    });

    _tabController = TabController(vsync: this, length: categories.length)
      ..addListener(_handleTabSelection);
    _init();

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.index == 0 || _tabController.index == 1) {
      setState(() {
        categorySelected = _tabController.index;
      });
    } else {}
    print(_tabController.index);
  }

  _init() {
    if (widget.index != 0) {
      setState(() {
        categorySelected = widget.index;
        _tabController.index = widget.index;
      });
    }
  }

  int categorySelected = 0;

  final categories = [
    LocaleKeys.operationsHistory.tr(),
    LocaleKeys.withdrawalRequests.tr(),
  ];

  @override
  Widget build(BuildContext context) {
    final tabs = categories
        .map((e) => Tab(
              child: Text(
                e,
                style: TextStyle(
                    color: ColorsPalette.customGrey,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: ZainTextStyles.font),
              ),
            ))
        .toList();

    return Directionality(
      textDirection:
          Helpers.isArabic(context) ? TextDirection.rtl : TextDirection.ltr,
      child: DefaultTabController(
        length: categories.length,
        child: Scaffold(
          backgroundColor: ColorsPalette.lightGrey,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UtilValues.gap48,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  LocaleKeys.drawerWallet.tr(),
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: ColorsPalette.black,
                      fontFamily: ZainTextStyles.font),
                  textAlign: TextAlign.start,
                  //maxLines: 3,
                ),
              ),
              UtilValues.gap12,
              Container(
                color: ColorsPalette.primaryLightColor,
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      AssetsManager.wallet,
                      color: ColorsPalette.primaryColor,
                      width: 15,
                      height: 15,
                    ),
                    UtilValues.gap8,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocaleKeys.currentBalance.tr(),
                          style: TextStyle(
                              color: ColorsPalette.black,
                              fontWeight: FontWeight.w400,
                              fontFamily: ZainTextStyles.font,
                              fontSize: 12.sp),
                        ),
                        FutureBuilder<MyTransactionsModel>(
                            future: MiscellaneousApi.getMyTransactions(
                              locale: context.locale,
                              page: 1,
                              perPage: _numberOfPostsPerRequest,
                            ),
                            builder: (context, snapshot) {
                              final userProvider = context.read<UserProvider>();

                              if (!userProvider.isLoggedIn) {
                                return const SizedBox.shrink();
                              }
                              if (snapshot.data == null) {
                                return const SizedBox.shrink();
                              }

                              final banners = snapshot.data!;

                              if (banners.data == null) {
                                return const SizedBox.shrink();
                              }

                              return Text(
                                '${banners.data?.balance.toString()} ${LocaleKeys.le.tr()}',
                                style: TextStyle(
                                    color: ColorsPalette.black,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: ZainTextStyles.font,
                                    fontSize: 12.sp),
                              );
                            }),
                      ],
                    ),
                    Spacer(),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SentWithdrawalRequestScreen()),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ColorsPalette.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          LocaleKeys.withdrawalRequest.tr(),
                          style: TextStyle(
                              color: ColorsPalette.primaryColor,
                              fontWeight: FontWeight.w600,
                              fontFamily: ZainTextStyles.font,
                              fontSize: 10.sp),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              UtilValues.gap8,
              TabBar(
                overlayColor: MaterialStateProperty.all(ColorsPalette.white),
                labelColor: ColorsPalette.customGrey,
                unselectedLabelColor: ColorsPalette.customGrey,
                labelStyle: const TextStyle(color: ColorsPalette.black),
                controller: _tabController,
                tabs: tabs,
              ),
              UtilValues.gap12,
              categorySelected == 0
                  ? Expanded(
                      child: FutureBuilder<MyTransactionsModel>(
                        future: MiscellaneousApi.getMyTransactions(
                          locale: context.locale,
                          page: 1,
                          perPage: _numberOfPostsPerRequest,
                        ),
                        builder: (context, snapshot) {
                          final userProvider = context.read<UserProvider>();

                          if (!userProvider.isLoggedIn) {
                            return const NoOrdersFound();
                          }
                          if (snapshot.data == null) {
                            return const Center(
                              child: LoadingWidget(),
                            );
                          }

                          final banners = snapshot.data!;

                          if (banners.data == null) {
                            return const SizedBox.shrink();
                          }
                          final products = banners.data?.transactions;
                          if (products?.isEmpty ?? false) {
                            return const NoOrdersFound();
                          }

                          return Center(
                            child: GridView.builder(
                                itemCount: products?.length,
                                padding: EdgeInsets.zero,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1,
                                  childAspectRatio: 8.w / 1.h,
                                ),
                                itemBuilder: (context, index) {
                                  final product = products![index];
                                  return Padding(
                                    padding: EdgeInsets.all(5.0.sp),
                                    child: Center(
                                      child: WinchProductCard(
                                        orderID:
                                            product.orderId.toString() ?? '',
                                        date: product.date ?? '',
                                        type: product.type ?? '',
                                        amount: product.amount ?? '',
                                      ),
                                    ),
                                  );
                                }),
                          );
                        },
                      ),
                    )
                  : Expanded(
                      child: FutureBuilder<MyWithdrawalRequestsModel>(
                        future: MiscellaneousApi.getMyWithdrawalRequests(
                          locale: context.locale,
                          page: 1,
                          perPage: _numberOfPostsPerRequest,
                        ),
                        builder: (context, snapshot) {
                          final userProvider = context.read<UserProvider>();

                          if (!userProvider.isLoggedIn) {
                            return const NoOrdersFound();
                          }
                          if (snapshot.data == null) {
                            return const Center(
                              child: LoadingWidget(),
                            );
                          }

                          final banners = snapshot.data!;

                          if (banners.data == null) {
                            return const SizedBox.shrink();
                          }
                          final products = banners.data?.requests;
                          if (products?.isEmpty ?? false) {
                            return const NoOrdersFound();
                          }

                          return Center(
                            child: GridView.builder(
                                itemCount: products?.length,
                                padding: EdgeInsets.zero,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1,
                                  childAspectRatio: 8.w / 1.h,
                                ),
                                itemBuilder: (context, index) {
                                  final product = products![index];
                                  return Padding(
                                    padding: EdgeInsets.all(5.0.sp),
                                    child: Center(
                                      child: WinchProductCard(
                                        orderID: product.id.toString() ?? '',
                                        date: product.date ?? '',
                                        type: product.status ?? '',
                                        amount: product.amount ?? '',
                                      ),
                                    ),
                                  );
                                }),
                          );
                        },
                      ),
                    ),
              UtilValues.gap64
            ],
          ),
        ),
      ),
    );
  }
}
