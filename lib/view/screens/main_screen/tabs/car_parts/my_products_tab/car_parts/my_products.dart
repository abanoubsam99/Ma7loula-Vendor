import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../../controller/user_provider.dart';
import '../../../../../../../core/generated/locale_keys.g.dart';
import '../../../../../../../core/services/http/apis/miscellaneous_api.dart';
import '../../../../../../../core/utils/colors_palette.dart';
import '../../../../../../../core/utils/font.dart';
import '../../../../../../../core/utils/helpers.dart';
import '../../../../../../../core/utils/snackbars.dart';
import '../../../../../../../core/utils/util_values.dart';
import '../../../../../../../core/widgets/loading_widget.dart';
import '../../../../../../../model/products_model.dart';
import '../../../home_tab/local_widgets/product_card.dart';
import '../../../home_tab/local_widgets/product_details_screen.dart';
import '../../../my_orders_tab/local_widet/no_orders_found.dart';
import 'add_car_part_screen.dart';

class MyProductsScreen extends StatefulWidget {
  MyProductsScreen({Key? key, required this.index}) : super(key: key);
  int index = 0;
  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen>
    with TickerProviderStateMixin {
  final _numberOfPostsPerRequest = 10;

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

  // Default to pending (index 1) instead of published (index 0)
  int categorySelected = 1;

  // Only showing pending products now
  final categories = [
    LocaleKeys.reviewingProducts.tr(), // Pending/Reviewing
    LocaleKeys.reviewingProducts.tr(), // Same title for both tabs
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
                  LocaleKeys.myProducts.tr(),
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: ColorsPalette.black,
                      fontFamily: ZainTextStyles.font),
                  textAlign: TextAlign.start,
                  //maxLines: 3,
                ),
              ),
              TabBar(
                overlayColor: MaterialStateProperty.all(ColorsPalette.white),
                labelColor: ColorsPalette.customGrey,
                unselectedLabelColor: ColorsPalette.customGrey,
                labelStyle: const TextStyle(color: ColorsPalette.black),
                controller: _tabController,
                tabs: tabs,
              ),
              UtilValues.gap12,
              _btn(),
              UtilValues.gap12,
              Expanded(
                child: FutureBuilder<ProductsModel>(
                  future: MiscellaneousApi.getSearchProducts(
                    locale: context.locale,
                    page: 1,
                    perPage: _numberOfPostsPerRequest,
                    status: 'pending', // Always show pending products only
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
            Navigator.pushNamed(context, AddCarPartScreen.routeName);
          } else {
            showSnackbar(
              context: context,
              status: SnackbarStatus.info,
              message: LocaleKeys.shouldLogin.tr(),
            );
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
            LocaleKeys.addCarParts.tr(),
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
}
