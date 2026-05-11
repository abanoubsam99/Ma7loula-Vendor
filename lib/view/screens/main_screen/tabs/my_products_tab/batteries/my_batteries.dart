import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ma7lola_vendor/core/generated/locale_keys.g.dart';
import 'package:ma7lola_vendor/core/services/http/apis/miscellaneous_api.dart';
import 'package:ma7lola_vendor/core/utils/colors_palette.dart';
import 'package:ma7lola_vendor/core/utils/snackbars.dart';
import 'package:ma7lola_vendor/model/products_model.dart';
import 'package:ma7lola_vendor/view/screens/main_screen/tabs/home_tab/local_widgets/product_details_screen.dart';
import 'package:ma7lola_vendor/view/screens/main_screen/tabs/my_orders_tab/local_widet/no_orders_found.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../controller/user_provider.dart';
import '../../../../../../core/utils/font.dart';
import '../../../../../../core/utils/helpers.dart';
import '../../../../../../core/utils/util_values.dart';
import '../../../../../../core/widgets/custom_app_bar.dart';
import '../../../../../../core/widgets/loading_widget.dart';
import '../../home_tab/local_widgets/product_card.dart';
import 'add_battery_screen.dart';

class MyBatteriesScreen extends StatefulWidget {
  MyBatteriesScreen({Key? key, required this.index}) : super(key: key);
  int index = 0;
  @override
  State<MyBatteriesScreen> createState() => _MyBatteriesScreenState();
}

class _MyBatteriesScreenState extends State<MyBatteriesScreen>
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
            title: LocaleKeys.batteries.tr(),
          ),
          body: Column(
            children: [
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
                    
                    // Print image URLs for debugging
                    print('\n==== BATTERY IMAGES DEBUG ====');
                    print('Status: ${categorySelected == 0 ? "PUBLISHED" : "PENDING"}');
                    print('Total products: ${products?.length ?? 0}');
                    
                    // Log each product's image URL
                    for (int i = 0; i < (products?.length ?? 0); i++) {
                      final product = products![i];
                      final hasImages = product.images != null && (product.images?.isNotEmpty ?? false);
                      final imageUrl = hasImages ? product.images?.first.url ?? 'No URL' : 'No image';
                      print('Product ${i+1}: ${product.name ?? 'Unnamed'} - Image URL: "$imageUrl"');
                    }
                    print('===============================\n');
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
                                      ? _fixImageUrl(product.images?.first.url ?? '')
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

  // Helper method to fix duplicate filenames in image URLs
  String _fixImageUrl(String url) {
    if (url.isEmpty) return url;
    
    try {
      // Check for the duplicate filename pattern
      if (url.contains('.jpg/') || url.contains('.png/') || 
          url.contains('.jpeg/') || url.contains('.gif/')) {
        
        // Extract the filename from the URL
        final filename = url.split('/').last;
        
        // If the URL contains the pattern "filename.ext/filename.ext", fix it
        final pattern = '/$filename';
        if (url.contains(pattern)) {
          final correctedUrl = url.substring(0, url.lastIndexOf(pattern));
          print('Fixed URL: "$correctedUrl" (was: "$url")');
          return correctedUrl;
        }
      }
    } catch (e) {
      print('Error fixing image URL: $e');
    }
    
    return url;
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
            Navigator.pushNamed(context, AddBatteryScreen.routeName);
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
            LocaleKeys.addBattery.tr(),
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
