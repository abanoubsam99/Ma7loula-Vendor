import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ma7lola_vendor/view/screens/main_screen/tabs/winch/winch_my_orders_card.dart';
import 'package:ma7lola_vendor/view/screens/main_screen/tabs/winch/winch_order_request.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/services/secure_storage/secure_storage_keys.dart.dart';
import '../../../../../core/services/secure_storage/secure_storage_service.dart';

import '../../../../../controller/get_offers_provider.dart';
import '../../../../../controller/user_provider.dart';
import '../../../../../core/generated/locale_keys.g.dart';
import '../../../../../core/services/http/apis/miscellaneous_api.dart';
import '../../../../../core/utils/colors_palette.dart';
import '../../../../../core/utils/font.dart';
import '../../../../../core/utils/helpers.dart';
import '../../../../../core/widgets/loading_widget.dart';
import '../../../../../model/winch/winch_offers_model.dart';
import '../../../../../model/winch/winch_previous_orders.dart';
import '../my_orders_tab/local_widet/no_orders_found.dart';
import 'winch_order_details_screen.dart';

class WinchMyOrdersTab extends StatefulWidget {
  WinchMyOrdersTab({Key? key, required this.index}) : super(key: key);
  int index = 0;
  @override
  State<WinchMyOrdersTab> createState() => _WinchMyOrdersTabState();
}

class _WinchMyOrdersTabState extends State<WinchMyOrdersTab>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  Position? currentPosition;
  final _numberOfPostsPerRequest = 10;

  final PagingController<int, Orders> _pagingController =
      PagingController(firstPageKey: 1);

  int ordersLength = 0;
  Future<void> _fetchPage(int pageKey) async {
    try {
      final userProvider = context.read<UserProvider>();
      if (userProvider.isLoggedIn) {
        // Debug: Log vendor ID before fetching orders
        final vendorId = await SecureStorageService.instance
            .readString(key: SecureStorageKeys.vendorID);
        print('DEBUG - Fetching winch orders with vendor ID: $vendorId');
        
        final items = await MiscellaneousApi.getMyOrdersWinch(
          locale: context.locale,
          page: pageKey,
          perPage: _numberOfPostsPerRequest,
        );
        
        print('DEBUG - Winch orders response: pagination total: ${items.pagination?.total}');
        print('DEBUG - Orders count: ${items.data?.orders?.length ?? 0}');

        setState(() {
          ordersLength = items.pagination?.total ?? 0;

          if (items.data?.orders?.isEmpty ?? true) {
            _pagingController.appendLastPage([]);
            print('DEBUG - No winch orders found');
          } else {
            final isLastPage =
                (items.data?.orders?.length ?? 0) < _numberOfPostsPerRequest;

            if (isLastPage) {
              _pagingController.appendLastPage(items.data!.orders!);
            } else {
              final nextPageKey = pageKey + 1;
              _pagingController.appendPage(items.data!.orders!, nextPageKey);
            }
            print('DEBUG - Found ${items.data!.orders!.length} winch orders');
          }
          _isLoading = false;
        });
      } else {
        _pagingController.appendLastPage([]);
        print('DEBUG - User not logged in when trying to fetch winch orders');
      }
    } catch (e) {
      print('DEBUG - Error fetching winch orders: $e');
      _pagingController.error = e;
    }
  }

  final _scrollController = ScrollController();
  bool _isLoading = false;
  late TabController _tabController;

  int categorySelected = 0;

  @override
  void initState() {
    super.initState();
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
    _requestLocationPermission();
    WidgetsBinding.instance.addObserver(this);
    
    // Check and fix vendor ID before starting timer
    _checkAndFixVendorID();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTimer();
      // _getRe();
    });
  }
  
  // Make sure we have the correct vendor ID for winch vendors (should be 61)
  Future<void> _checkAndFixVendorID() async {
    final vendorId = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.vendorID);
    print('DEBUG - Current vendor ID: $vendorId');
    
    // Check if the vendor ID is not the winch vendor ID
    if (vendorId != '61') {
      print('DEBUG - Incorrect vendor ID for winch vendor. Updating to 61');
      await SecureStorageService.instance
          .writeString(key: SecureStorageKeys.vendorID, value: '61');
      
      // Verify the update
      final newVendorId = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.vendorID);
      print('DEBUG - Updated vendor ID to: $newVendorId');
      
      // Refresh the data after updating the vendor ID
      if (context.mounted) {
        final locale = Localizations.localeOf(context);
        _checkForWinchOrders(locale);
        _pagingController.refresh();
      }
    }
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

  void _startTimer() async {
    final locale = Localizations.localeOf(context);
    await _requestLocationPermission();
    setState(() {});
  
    // Update location and check for new orders
    context.read<GetWinchOffersProvider>().startTimerLiveLocation(
        locale: locale,
        lat: currentPosition?.latitude ?? 30.11861788360871,
        lon: currentPosition?.longitude ?? 31.303159675296993);
      
    // Also start checking for pending winch requests
    context.read<GetWinchOffersProvider>().startTimerRequestLiveTutors(
        locale: locale,lat:currentPosition!.latitude,lon: currentPosition!.longitude);
      
    print('DEBUG - Started timers for location updates and winch order requests checks');
  
    // Force an immediate check for winch orders
    _checkForWinchOrders(locale);
  }

  // Add a method to explicitly check for winch orders
  Future<void> _checkForWinchOrders(Locale locale) async {
    print('DEBUG - Manually checking for winch orders');
    try {
      final provider = context.read<GetWinchOffersProvider>();
      final offers = await provider.getPendingRequest(locale: locale,lat:currentPosition!.latitude,lon: currentPosition!.longitude);
      print('DEBUG - Winch offers response: ${offers.data?.toJson()}');
    
      // Refresh orders list
      _pagingController.refresh();
    } catch (e) {
      print('DEBUG - Error checking winch orders: $e');
    }
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        currentPosition = position;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    context.read<GetWinchOffersProvider>().closeTimer();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

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
                  .map((tab) => categorySelected == 0
                      ? buildGridViewActive(
                          height: MediaQuery.of(context).size.height)
                      : buildGridViewPrevise(
                          height: MediaQuery.of(context).size.height))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  SizedBox buildGridViewPrevise({required double height}) {
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
            childAspectRatio: 5.w / 1.5.h,
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
                        return WinchOrderDetails(
                          orderNum: order.id ?? 0,
                          vendorName: order.worker?.name ?? '',
                          userNum: order.worker?.phone ?? '',
                        );
                      }));
                    },
                    child: WinchMyOrderCard(
                      status: order.status ?? '',
                      date: order.durationInMinutes ?? '',
                      total: order.total ?? 0,
                      orderNum: order.id ?? 0,
                      fromText: order.fromText,
                      toText: order.toText,
                      myLocText: order.fromLon.toString() ?? '',
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return WinchOrderDetails(
                            orderNum: order.id ?? 0,
                            vendorName: order.worker?.name ?? '',
                            userNum: order.worker?.phone ?? '',
                          );
                        }));
                      },
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }

  SizedBox buildGridViewActive({required double height}) {
    // Use Consumer to watch for changes in the GetWinchOffersProvider
    return SizedBox(
      height: height,
      child: Consumer<GetWinchOffersProvider>(
        builder: (context, provider, _) {
          print('DEBUG - Rebuilding active orders view with latest data');
          // Fetch vendor ID for debugging
          SecureStorageService.instance
              .readString(key: SecureStorageKeys.vendorID)
              .then((vendorId) {
            print('DEBUG - Current vendor ID in active orders view: $vendorId');
          });
          
          // Use the data from the provider that's continuously updated by the polling mechanism
          final winchOffers = provider.listRequests;
            if (winchOffers.data == null) {
              print('DEBUG - No data available in winch offers');
              return Center(
                child: NoOrdersFound(),
              );
            }
            final orders = winchOffers.data?.requests;
            final acceptedOffer = winchOffers.data?.acceptedOffer;
            
            print('DEBUG - Active view data: requests: ${orders?.length ?? 0}, acceptedOffer: ${acceptedOffer != null ? "yes" : "no"}');

            if (acceptedOffer != null && (orders == null || orders.isEmpty)) {
              return Padding(
                padding: EdgeInsets.all(5.0.sp),
                child: InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return MapRoutePage(
                        orderNum: acceptedOffer.id ?? 0,
                        servicesPrice: acceptedOffer.servicesPrice ?? 0.0,
                        taxPrice: acceptedOffer.taxPrice ?? 0.0,
                        total: acceptedOffer.total ?? 0.0,
                        user: acceptedOffer.user!,
                        fromLat: acceptedOffer.fromLat ?? 0,
                        fromLon:double.tryParse(acceptedOffer.fromLon ?? '') ?? 0,
                        toLat: double.tryParse(acceptedOffer.toLat ?? '') ?? 0,
                        toLon: double.tryParse(acceptedOffer.toLon ?? '') ?? 0,
                        time: acceptedOffer.durationInMinutes ?? '',
                        distanceInKilo: acceptedOffer.distanceInMeters ?? '',
                        vendorName: acceptedOffer.worker?.name ?? '',
                        vendorNum: acceptedOffer.worker?.phone ?? '',
                        fromText: acceptedOffer.fromText ?? '',
                        toText: acceptedOffer.toText ?? '',
                        vendorCar:
                            '${acceptedOffer.userCar?.car?.model?.brand?.name} ${acceptedOffer.userCar?.car?.year}',
                      );
                    }));
                  },
                  child: WinchMyOrderCard(
                    status: acceptedOffer.status ?? '',
                    date: acceptedOffer.durationInMinutes ?? '',
                    total: acceptedOffer.total ?? 0,
                    orderNum: acceptedOffer.id ?? 0,

                    car: acceptedOffer.userCar,
                    fromText: acceptedOffer.fromText,
                    toText: acceptedOffer.toText,
                    myLocText: acceptedOffer.fromLon.toString() ?? '',
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return MapRoutePage(
                          orderNum: acceptedOffer.id ?? 0,
                          user: acceptedOffer.user!,
                          servicesPrice: acceptedOffer.servicesPrice ?? 0.0,
                          taxPrice: acceptedOffer.taxPrice ?? 0.0,
                          total: acceptedOffer.total ?? 0.0,
                          fromLat: acceptedOffer.fromLat ?? 0,
                          fromLon:
                              double.tryParse(acceptedOffer.fromLon ?? '') ?? 0,
                          toLat:
                              double.tryParse(acceptedOffer.toLat ?? '') ?? 0,
                          toLon:
                              double.tryParse(acceptedOffer.toLon ?? '') ?? 0,
                          time: acceptedOffer.durationInMinutes ?? '',
                          distanceInKilo: acceptedOffer.distanceInMeters ?? '',
                          vendorName: acceptedOffer.worker?.name ?? '',
                          vendorNum: acceptedOffer.worker?.phone ?? '',
                          fromText: acceptedOffer.fromText ?? '',
                          toText: acceptedOffer.toText ?? '',
                          vendorCar:
                              '${acceptedOffer.userCar?.car?.model?.brand?.name} ${acceptedOffer.userCar?.car?.year}',
                        );
                      }));
                    },
                  ),
                ),
              );
            }
            if (((orders?.isEmpty ?? false) || orders == null) &&
                acceptedOffer == null) {
              return Center(
                child: NoOrdersFound(),
              );
            }

            return GridView.builder(
                itemCount: orders?.length,
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 5.w / 1.5.h,
                ),
                itemBuilder: (context, index) {
                  final order = orders![index];

                  return Padding(
                    padding: EdgeInsets.all(5.0.sp),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return MapRoutePage(
                            orderNum: order.id ?? 0,
                            servicesPrice: order.servicesPrice ?? 0.0,
                            taxPrice: order.taxPrice ?? 0.0,
                            total: order.total ?? 0.0,
                            user: order.user!,
                            fromLat: order.fromLat ?? 0,
                            fromLon: double.tryParse(order.fromLon ?? '') ?? 0,
                            toLat: double.tryParse(order.toLat ?? '') ?? 0,
                            toLon: double.tryParse(order.toLon ?? '') ?? 0,
                            time: order.durationInMinutes ?? '',
                            distanceInKilo: order.distanceInMeters ?? '',
                            vendorName: order.worker?.name ?? '',
                            vendorNum: order.worker?.phone ?? '',
                            fromText: order.fromText ?? '',
                            toText: order.toText ?? '',
                            vendorCar:
                                '${order.userCar?.car?.model?.brand?.name} ${order.userCar?.car?.year}',
                          );
                        }));
                      },
                      child: WinchMyOrderCard(
                        status: order.status ?? '',
                        date: order.durationInMinutes ?? '',
                        total: order.total ?? 0,
                        orderNum: order.id ?? 0,
                        car: order.userCar,
                        fromText: order.fromText,
                        toText: order.toText,
                        myLocText: order.fromLon.toString() ?? '',
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return MapRoutePage(
                              orderNum: order.id ?? 0,
                              servicesPrice: order.servicesPrice ?? 0.0,
                              total: order.total ?? 0.0,
                              taxPrice: order.taxPrice ?? 0.0,
                              fromLat: order.fromLat ?? 0,
                              user: order.user!,
                              fromLon:
                                  double.tryParse(order.fromLon ?? '') ?? 0,
                              toLat: double.tryParse(order.toLat ?? '') ?? 0,
                              toLon: double.tryParse(order.toLon ?? '') ?? 0,
                              time: order.durationInMinutes ?? '',
                              distanceInKilo: order.distanceInMeters ?? '',
                              vendorName: order.worker?.name ?? '',
                              vendorNum: order.worker?.phone ?? '',
                              fromText: order.fromText ?? '',
                              toText: order.toText ?? '',
                              vendorCar:
                                  '${order.userCar?.car?.model?.brand?.name} ${order.userCar?.car?.year}',
                            );
                          }));
                        },
                      ),
                    ),
                  );
                });
          }),
    );
  }
}
