import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ma7lola_vendor/core/generated/locale_keys.g.dart';
import 'package:ma7lola_vendor/core/services/http/apis/miscellaneous_api.dart';
import 'package:ma7lola_vendor/core/utils/assets_manager.dart';
import 'package:ma7lola_vendor/core/utils/colors_palette.dart';
import 'package:ma7lola_vendor/model/products_model.dart';
import 'package:ma7lola_vendor/view/screens/main_screen/tabs/home_tab/local_widgets/product_details_screen.dart';
import 'package:ma7lola_vendor/view/screens/main_screen/tabs/my_orders_tab/local_widet/no_orders_found.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../controller/user_provider.dart';
import '../../../../../../core/utils/font.dart';
import '../../../../../../core/utils/helpers.dart';
import '../../../../../../core/utils/snackbars.dart';
import '../../../../../../core/utils/util_values.dart';
import '../../../../../../core/widgets/custom_app_bar.dart';
import '../../../../../../core/widgets/form_widgets/primary_button/primary_button.dart';
import '../../../../../../core/widgets/loading_widget.dart';
import '../../home_tab/local_widgets/product_card.dart';
import 'add_tire_screen.dart';

class MyTiresScreen extends StatefulWidget {
  MyTiresScreen({Key? key, required this.index}) : super(key: key);
  int index = 0;
  @override
  State<MyTiresScreen> createState() => _MyTiresScreenState();
}

class _MyTiresScreenState extends State<MyTiresScreen>
    with TickerProviderStateMixin {
  final _numberOfPostsPerRequest = 10;

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
    LocaleKeys.previewProducts.tr(),
    LocaleKeys.reviewingProducts.tr(),
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
          appBar: AppBarApp(
            title: LocaleKeys.tires.tr(),
          ),
          body: Column(
            children: [
              TabBar(
                overlayColor: MaterialStateProperty.all(ColorsPalette.white),
                labelColor: ColorsPalette.customGrey,
                unselectedLabelColor: ColorsPalette.customGrey,
                labelStyle: TextStyle(color: ColorsPalette.black),
                controller: _tabController,
                tabs: tabs,
              ),
              UtilValues.gap12,
              _btn(),
              UtilValues.gap12,
              Expanded(
                child: FutureBuilder<ProductsModel>(
                  future: MiscellaneousApi.getSearchProductsTires(
                    locale: context.locale,
                    page: 1,
                    perPage: _numberOfPostsPerRequest,
                    status: categorySelected == 0 ? 'published' : 'pending',
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
                    final products = banners.data?.products;
                    if (products?.isEmpty ?? false) {
                      return const NoOrdersFound();
                    }
                    return Center(
                      child: GridView.builder(
                          itemCount: products?.length,
                          padding: EdgeInsets.zero,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 3.w / 1.84.h,
                          ),
                          itemBuilder: (context, index) {
                            final product = products![index];
                            return Padding(
                              padding: EdgeInsets.all(5.0.sp),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return ProductDetailsScreen(
                                      product: product,
                                    );
                                  }));
                                },
                                child: ProductCard(
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return ProductDetailsScreen(
                                        product: product,
                                      );
                                    }));
                                  },
                                  qtyProduct: product.qty ?? 1,
                                  imageUrl: (product.images != null &&
                                          (product.images?.isNotEmpty ?? false))
                                      ? product.images?.first.url ?? ''
                                      : '',
                                  title: product.name ?? '',
                                  onPressed: () {},
                                  onPressedMinus: () {},
                                  description: product.description ?? '',
                                  price: product.price ?? 0.0,
                                  discount: product.priceBeforeDiscount ?? 0.0,
                                  
                                  productName: product.brand?.name ?? '',
                                  products: product,
                                ),
                              ),
                            );
                          }),
                    );
                  },
                ),
              ),

              // Expanded(
              //   child: TabBarView(
              //     controller: _tabController,
              //     physics: const BouncingScrollPhysics(),
              //     children: tabs
              //         .map((tab) => buildGridView(
              //             height: MediaQuery.of(context).size.height))
              //         .toList(),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  _btn() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      margin: EdgeInsets.all(1.sp),
      height: 6.h,
      child: ElevatedButton(
        onPressed: () {
          final userProvider = context.read<UserProvider>();

          if (userProvider.isLoggedIn) {
            Navigator.pushNamed(context, AddTiresScreen.routeName);
          } else {
            showSnackbar(
                context: context,
                status: SnackbarStatus.info,
                message: LocaleKeys.shouldLogin.tr());
          }
        },
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all<TextStyle>(
            TextStyle(fontSize: 14.sp, fontFamily: ZainTextStyles.font),
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: ColorsPalette.black),
            ),
          ),
          backgroundColor:
              MaterialStateProperty.all<Color>(ColorsPalette.lightGrey),
        ),
        child: Center(
          child: Text(
            LocaleKeys.addTire.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ColorsPalette.black,
                fontFamily: ZainTextStyles.font,
                fontSize: 12.sp),
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

  // SizedBox buildGridView({required double height}) {
  //   return SizedBox(
  //     height: height,
  //     child: RefreshIndicator(
  //       color: ColorsPalette.primaryColor,
  //       onRefresh: () => Future.sync(() => _pagingController.refresh()),
  //       child: PagedGridView<int, Products>(
  //         scrollController: _scrollController,
  //         showNewPageProgressIndicatorAsGridChild: false,
  //         showNewPageErrorIndicatorAsGridChild: false,
  //         showNoMoreItemsIndicatorAsGridChild: false,
  //         pagingController: _pagingController,
  //         padding: EdgeInsets.zero,
  //         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //           crossAxisCount: 2,
  //           childAspectRatio: 3.w / 1.84.h,
  //           // crossAxisSpacing: 0,
  //           // mainAxisSpacing: 0,
  //           // crossAxisCount: 1,
  //         ),
  //         builderDelegate: PagedChildBuilderDelegate<Products>(
  //             firstPageProgressIndicatorBuilder: (context) =>
  //                 const Center(child: LoadingWidget()),
  //             newPageProgressIndicatorBuilder: (context) =>
  //                 const Center(child: LoadingWidget()),
  //             noItemsFoundIndicatorBuilder: (context) => _isLoading
  //                 ? const Center(child: LoadingWidget())
  //                 : NoOrdersFound(),
  //             itemBuilder: (context, item, index) {
  //               final product = item;
  //               return Padding(
  //                 padding: EdgeInsets.all(5.0.sp),
  //                 child: InkWell(
  //                   onTap: () {
  //                     Navigator.push(context,
  //                         MaterialPageRoute(builder: (context) {
  //                       return ProductDetailsScreen(
  //                         product: product,
  //                       );
  //                     }));
  //                   },
  //                   child: ProductCard(
  //                     onTap: () {
  //                       Navigator.push(context,
  //                           MaterialPageRoute(builder: (context) {
  //                         return ProductDetailsScreen(
  //                           product: product,
  //                         );
  //                       }));
  //                     },
  //                     qtyProduct: product.qty ?? 1,
  //                     imageUrl: product.images?.first.url ?? '',
  //                     title: product.name ?? '',
  //                     onPressed: () {},
  //                     onPressedMinus: () {},
  //                     description: product.description ?? '',
  //                     price: product.price ?? 0.0,
  //                     discount: product.priceBeforeDiscount ?? 0.0,
  //                     
  //                     productName: product.brand?.name ?? '',
  //                     products: product,
  //                   ),
  //                 ),
  //               );
  //             }),
  //       ),
  //     ),
  //   );
  // }
}
