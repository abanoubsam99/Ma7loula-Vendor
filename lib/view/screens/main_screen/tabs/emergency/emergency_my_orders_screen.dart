import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ma7lola_vendor/controller/get_emergency_offers_provider.dart';
import 'package:ma7lola_vendor/model/emergency/emergency_offers_model.dart';
import 'package:ma7lola_vendor/model/emergency/privous_orders.dart';
import 'package:ma7lola_vendor/view/screens/main_screen/tabs/emergency/emergency_order_request.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../../../controller/user_provider.dart';
import '../../../../../core/generated/locale_keys.g.dart';
import '../../../../../core/services/http/apis/miscellaneous_api.dart';
import '../../../../../core/utils/colors_palette.dart';
import '../../../../../core/utils/font.dart';
import '../../../../../core/utils/helpers.dart';
import '../../../../../core/widgets/loading_widget.dart';
import '../my_orders_tab/local_widet/no_orders_found.dart';
import 'emergency_my_orders_card.dart';
import 'emergency_order_details_screen.dart';

class EmergencyMyOrdersTab extends StatefulWidget {
  EmergencyMyOrdersTab({Key? key, required this.index}) : super(key: key);
  int index = 0;
  @override
  State<EmergencyMyOrdersTab> createState() => _EmergencyMyOrdersTabState();
}

class _EmergencyMyOrdersTabState extends State<EmergencyMyOrdersTab>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  Position? currentPosition;
  final _numberOfPostsPerRequest = 10;

  final PagingController<int, EmOrders> _pagingController =
      PagingController(firstPageKey: 1);

  int ordersLength = 0;
  Future<void> _fetchPage(int pageKey) async {
    try {
      final userProvider = context.read<UserProvider>();
      if (userProvider.isLoggedIn) {
        final items = await MiscellaneousApi.getMyOrdersEmergency(
          locale: context.locale,
          page: pageKey,
          perPage: _numberOfPostsPerRequest,
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTimer();
      // _getRe();
    });
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
    // Store context locally to avoid potential issues
    final locale = Localizations.localeOf(context);
    
    // Check mounted before continuing with async operations
    if (!mounted) return;
    
    try {
      await _requestLocationPermission();
      
      // Double-check mounted after the async operation
      if (!mounted) return;
      
      setState(() {/* Update UI if needed */});
      
      // Get provider only if still mounted
      if (mounted) {
        final provider = context.read<GetEmergencyOffersProvider>();
        provider.startTimerLiveLocation(
            locale: locale,
            lat: currentPosition?.latitude ?? 30.11861788360871,
            lon: currentPosition?.longitude ?? 31.303159675296993);
      }
    } catch (e) {
      print('Error in _startTimer: $e');
    }
  }

  Future<void> _requestLocationPermission() async {
    // Check mounted before proceeding
    if (!mounted) return;
    
    try {
      LocationPermission permission = await Geolocator.requestPermission();

      // Check mounted again after the async call
      if (!mounted) return;

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        // Update local variable without setState for now
        final Position position = await Geolocator.getCurrentPosition();
        
        // Final mounted check before updating state
        if (mounted) {
          setState(() {
            currentPosition = position;
          });
        }
      }
    } catch (e) {
      print('Error requesting location permission: $e');
      // Don't rethrow to avoid crashes
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    context.read<GetEmergencyOffersProvider>().closeTimer();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  final categories = [
    LocaleKeys.activeOrders.tr(),
    LocaleKeys.completedOrders.tr(),
  ];

  // @override
  // void didChangeDependencies() {
  //   // TODO: implement didChangeDependencies
  //   super.didChangeDependencies();
  //   _get();
  // }

  // _get() async {
  //   await MiscellaneousApi.getOffers(
  //     locale: context.locale,
  //   );
  //   setState(() {});
  // }

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
        child: PagedGridView<int, EmOrders>(
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
          builderDelegate: PagedChildBuilderDelegate<EmOrders>(
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
                        return EmergencyOrderDetails(
                          orderNum: order.id ?? 0,
                          vendorName: order.worker?.name ?? '',
                          vendorNum: order.worker?.phone ?? '',
                        );
                      }));
                    },
                    child: EmergencyMyOrderCard(
                      status: order.status ?? '',
                      date: '',
                      total: order.total ?? 0,
                      orderNum: order.id ?? 0,
                      location: order.location.toString() ?? '',
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return EmergencyOrderDetails(
                            orderNum: order.id ?? 0,
                            vendorName: order.worker?.name ?? '',
                            vendorNum: order.worker?.phone ?? '',
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
    return SizedBox(
      height: height,
      child: FutureBuilder<EmergencyOffersModel>(
          future: MiscellaneousApi.getEmergencyOffers(locale: context.locale),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Center(
                child: NoOrdersFound(),
              );
            }
            final orders = snapshot.data?.data?.requests;
            final acceptedOffer = snapshot.data?.data?.acceptedOffer;

            if (acceptedOffer != null && (orders == null || orders.isEmpty)) {
              return Padding(
                padding: EdgeInsets.all(5.0.sp),
                child: InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return EmergencyMapRoutePage(
                        orderNum: acceptedOffer.id ?? 0,
                        user: acceptedOffer.user!,
                        servicesPrice: acceptedOffer.servicesPrice ?? 0.0,
                        taxPrice: acceptedOffer.taxPrice ?? 0.0,
                        total: acceptedOffer.total ?? 0.0,
                        fromLat: double.tryParse(acceptedOffer.lat ?? '') ?? 0,
                        fromLon: double.tryParse(acceptedOffer.lon ?? '') ?? 0,
                        toLat: double.tryParse(acceptedOffer.lat ?? '') ?? 0,
                        toLon: double.tryParse(acceptedOffer.lon ?? '') ?? 0,
                        vendorName: acceptedOffer.worker?.name ?? '',
                        vendorNum: acceptedOffer.worker?.phone ?? '',
                        location: acceptedOffer.location ?? '',
                        vendorCar:
                            '${acceptedOffer.userCar?.car?.model?.brand?.name} ${acceptedOffer.userCar?.car?.year}',
                      );
                    }));
                  },
                  child: EmergencyMyOrderCard(
                    status: acceptedOffer.status ?? '',
                    total: acceptedOffer.total ?? 0,
                    orderNum: acceptedOffer.id ?? 0,
                    location: acceptedOffer.location ?? '',
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return EmergencyMapRoutePage(
                          orderNum: acceptedOffer.id ?? 0,
                          user: acceptedOffer.user!,
                          servicesPrice: acceptedOffer.servicesPrice ?? 0.0,
                          taxPrice: acceptedOffer.taxPrice ?? 0.0,
                          total: acceptedOffer.total ?? 0.0,
                          fromLat:
                              double.tryParse(acceptedOffer.lat ?? '') ?? 0,
                          fromLon:
                              double.tryParse(acceptedOffer.lon ?? '') ?? 0,
                          toLat: double.tryParse(acceptedOffer.lat ?? '') ?? 0,
                          toLon: double.tryParse(acceptedOffer.lon ?? '') ?? 0,
                          vendorName: acceptedOffer.worker?.name ?? '',
                          vendorNum: acceptedOffer.worker?.phone ?? '',
                          location: acceptedOffer.location ?? '',
                          vendorCar:
                              '${acceptedOffer.userCar?.car?.model?.brand?.name} ${acceptedOffer.userCar?.car?.year}',
                        );
                      }));
                    },
                    date: '',
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
                          return EmergencyMapRoutePage(
                            orderNum: order.id ?? 0,
                            user: order.user!,
                            servicesPrice: order.servicesPrice ?? 0.0,
                            taxPrice: order.taxPrice ?? 0.0,
                            total: order.total ?? 0.0,
                            fromLat: double.tryParse(order.lat ?? '') ?? 0,
                            fromLon: double.tryParse(order.lon ?? '') ?? 0,
                            toLat: double.tryParse(order.lat ?? '') ?? 0,
                            toLon: double.tryParse(order.lon ?? '') ?? 0,
                            vendorName: order.worker?.name ?? '',
                            vendorNum: order.worker?.phone ?? '',
                            location: order.location ?? '',
                            vendorCar:
                                '${order.userCar?.car?.model?.brand?.name} ${order.userCar?.car?.year}',
                          );
                        }));
                      },
                      child: EmergencyMyOrderCard(
                        status: order.status ?? '',
                        total: order.total ?? 0,
                        orderNum: order.id ?? 0,
                        location: order.location ?? '',
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return EmergencyMapRoutePage(
                              orderNum: order.id ?? 0,
                              user: order.user!,
                              servicesPrice: order.servicesPrice ?? 0.0,
                              taxPrice: order.taxPrice ?? 0.0,
                              total: order.total ?? 0.0,
                              fromLat: double.tryParse(order.lat ?? '') ?? 0,
                              fromLon: double.tryParse(order.lon ?? '') ?? 0,
                              toLat: double.tryParse(order.lat ?? '') ?? 0,
                              toLon: double.tryParse(order.lon ?? '') ?? 0,
                              vendorName: order.worker?.name ?? '',
                              vendorNum: order.worker?.phone ?? '',
                              location: order.location ?? '',
                              vendorCar:
                                  '${order.userCar?.car?.model?.brand?.name} ${order.userCar?.car?.year}',
                            );
                          }));
                        },
                        date: '',
                      ),
                    ),
                  );
                });
          }),
    );
  }
}
