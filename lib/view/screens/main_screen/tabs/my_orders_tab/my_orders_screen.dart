import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ma7lola_vendor/controller/user_provider.dart';
import 'package:ma7lola_vendor/core/generated/locale_keys.g.dart';
import 'package:ma7lola_vendor/core/services/http/apis/miscellaneous_api.dart';
import 'package:ma7lola_vendor/core/utils/assets_manager.dart';
import 'package:ma7lola_vendor/core/utils/colors_palette.dart';
import 'package:ma7lola_vendor/view/screens/main_screen/tabs/my_orders_tab/local_widet/no_orders_found.dart';
import 'package:ma7lola_vendor/view/screens/main_screen/tabs/my_orders_tab/order_details_screen.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/utils/font.dart';
import '../../../../../core/utils/helpers.dart';
import '../../../../../core/utils/util_values.dart';
import '../../../../../core/widgets/form_widgets/primary_button/primary_button.dart';
import '../../../../../core/widgets/loading_widget.dart';
import '../../../../../model/my_orders_model.dart';
import 'local_widet/my_orders_card.dart';

class MyOrdersTab extends StatefulWidget {
  MyOrdersTab({Key? key, required this.index}) : super(key: key);
  int index = 0;
  @override
  State<MyOrdersTab> createState() => _MyOrdersTabState();
}

class _MyOrdersTabState extends State<MyOrdersTab>
    with TickerProviderStateMixin {
  final _numberOfPostsPerRequest = 10;

  final PagingController<int, Orders> _pagingController =
      PagingController(firstPageKey: 1);

  int ordersLength = 0;
  Future<void> _fetchPage(int pageKey) async {
    try {
      final userProvider = context.read<UserProvider>();
      if (userProvider.isLoggedIn) {
        final items = await MiscellaneousApi.getMyOrdersBatteries(
          locale: context.locale,
          page: pageKey,
          perPage: _numberOfPostsPerRequest,
          status: categorySelected == 0 ? 'active' : 'completed',
        );

        setState(() {
          ordersLength = items.pagination?.total ?? 0;

          if (items.data?.orders?.isEmpty ?? true) {
            _pagingController.appendLastPage([]);
          } else {
            final isLastPage =
                (items.data?.orders?.length ?? 0) < _numberOfPostsPerRequest;

            if (isLastPage) {
              _pagingController.appendLastPage(items.data!.orders!);
            } else {
              final nextPageKey = pageKey + 1;
              _pagingController.appendPage(items.data!.orders!, nextPageKey);
            }
          }
          _isLoading = false;
        });
      } else {
        _pagingController.appendLastPage([]);
      }
    } catch (e) {
      _pagingController.error = e;
    }
  }

  final _scrollController = ScrollController();
  bool _isLoading = false;
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
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
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

        _pagingController.refresh();
      });
    } else {
      _pagingController.itemList?.clear();
      _pagingController.itemList = [];
    }

    // _fetchPage(1);

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
    LocaleKeys.activeOrders.tr(),
    LocaleKeys.completedOrders.tr(),
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
      child: SafeArea(
        child: DefaultTabController(
          length: categories.length,
          child: Scaffold(
            backgroundColor: ColorsPalette.lightGrey,
            appBar: TabBar(
              overlayColor: MaterialStateProperty.all(ColorsPalette.white),
              labelColor: ColorsPalette.customGrey,
              unselectedLabelColor: ColorsPalette.customGrey,
              labelStyle: TextStyle(color: ColorsPalette.black),
              controller: _tabController,
              tabs: tabs,
            ),
            body: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: tabs
                  .map((tab) =>
                      buildGridView(height: MediaQuery.of(context).size.height))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  var total;
  var prices;
  _addToCartButton() {
    return PrimaryButton(
      onPressed: () {
        // Navigator.push(context, MaterialPageRoute(builder: (context) {
        //   return CartScreen(
        //     carID: widget.userCarId,
        //     car: widget.car,
        //   );
        // }));
      },
      backgroundColor: ColorsPalette.customGrey,
      child: Center(
        child: _isLoading
            ? LoadingWidget(
                size: 20,
                color: ColorsPalette.white,
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Builder(builder: (context) {
                    return Text(
                      '0.00',
                      style: TextStyle(
                          color: ColorsPalette.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                          fontFamily: ZainTextStyles.font),
                    );
                  }),
                  Spacer(),
                  Text(
                    LocaleKeys.addToCart.tr(),
                    style: TextStyle(
                        color: ColorsPalette.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 10.sp,
                        fontFamily: ZainTextStyles.font),
                  ),
                  UtilValues.gap8,
                  SvgPicture.asset(
                    AssetsManager.angleRight,
                    width: 12,
                    height: 13,
                    color: ColorsPalette.white,
                  ),
                ],
              ),
      ),
    );
  }

  SizedBox buildGridView({required double height}) {
    return SizedBox(
      height: height,
      child: RefreshIndicator(
        color: ColorsPalette.primaryColor,
        onRefresh: () => Future.sync(() => _pagingController.refresh()),
        child: PagedGridView<int, Orders>(
          scrollController: _scrollController,
          showNewPageProgressIndicatorAsGridChild: false,
          showNewPageErrorIndicatorAsGridChild: false,
          showNoMoreItemsIndicatorAsGridChild: false,
          pagingController: _pagingController,
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            childAspectRatio: 5.w / 1.84.h,
            // crossAxisSpacing: 0,
            // mainAxisSpacing: 0,
            // crossAxisCount: 1,
          ),
          builderDelegate: PagedChildBuilderDelegate<Orders>(
              firstPageProgressIndicatorBuilder: (context) =>
                  const Center(child: LoadingWidget()),
              newPageProgressIndicatorBuilder: (context) =>
                  const Center(child: LoadingWidget()),
              noItemsFoundIndicatorBuilder: (context) => _isLoading
                  ? const Center(child: LoadingWidget())
                  : NoOrdersFound(),
              itemBuilder: (context, item, index) {
                final order = item;
                return Padding(
                  padding: EdgeInsets.all(5.0.sp),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return OrderDetails(
                          // status: order.status ?? '',
                          // products: order.products ?? [],
                          orderNum: order.id ?? 1,
                          // car: order.userCar,
                          // paymentMethod: order.paymentMethod ?? 0,
                          // total: order.total,
                          // orderDate: order.createdAt ?? '',
                          // deliveryDate: order.deliveryTime ?? '',
                          orderType: categorySelected,
                        );
                      }));
                    },
                    child: MyOrderCard(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return OrderDetails(
                            // status: order.status ?? '',
                            // products: order.products ?? [],
                            orderNum: order.id ?? 1,
                            // car: order.userCar,
                            // paymentMethod: order.paymentMethod ?? 0,
                            // total: order.total,
                            // orderDate: order.createdAt ?? '',
                            // deliveryDate: order.deliveryTime ?? '',
                            orderType: categorySelected,
                          );
                        }));
                      },
                      status: order.status ?? '',
                      date: order.deliveryTime ?? '',
                      total: order.total ?? 0,
                      orderNum: order.id ?? 1,
                      car: order.userCar,
                      products: order.products ?? [],
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }
}
