import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math' as m;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ma7lola_vendor/core/services/http/apis/miscellaneous_api.dart';
import 'package:ma7lola_vendor/core/utils/assets_manager.dart';
import 'package:ma7lola_vendor/core/utils/colors_palette.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../../controller/get_offers_provider.dart';
import '../../../../../core/generated/locale_keys.g.dart';
import '../../../../../core/services/http/api_endpoints.dart';
import '../../../../../core/utils/font.dart';
import '../../../../../core/utils/helpers.dart';
import '../../../../../core/utils/snackbars.dart';
import '../../../../../core/utils/util_values.dart';
import '../../../../../core/widgets/custom_app_bar.dart';
import '../../../../../core/widgets/form_widgets/primary_button/simple_primary_button.dart';
import '../../../../../model/winch/winch_offers_model.dart';
import 'winch_order_details_screen.dart';

class MapRoutePage extends StatefulWidget {
  final double fromLat;
  final double fromLon;
  final double toLat;
  final double toLon;
  final num? servicesPrice;
  final num? taxPrice;
  final num? total;
  final int orderNum;
  final User user;
  final String time;
  final String distanceInKilo;
  final String vendorName;
  final String vendorNum;
  final String vendorCar;
  final String fromText;
  final String toText;

  const MapRoutePage({
    Key? key,
    required this.fromLat,
    required this.fromLon,
    required this.toLat,
    required this.toLon,
    required this.user,
    required this.servicesPrice,
    required this.total,
    required this.taxPrice,
    required this.orderNum,
    required this.time,
    required this.distanceInKilo,
    required this.vendorName,
    required this.vendorNum,
    required this.vendorCar,
    required this.fromText,
    required this.toText,
  }) : super(key: key);

  @override
  State<MapRoutePage> createState() => _MapRoutePageState();
}

class _MapRoutePageState extends State<MapRoutePage> {
  GoogleMapController? mapController;
  Position? currentLocation;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  List<LatLng> polylineCoordinates = [];
  bool _isLoading = true;
  bool _hasFetchedPendingRequest = false;

  Future<void> openGoogleMapsDirections() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check location services
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: 'Location services are disabled',
      );
    }

    // Check permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return showSnackbar(
          context: context,
          status: SnackbarStatus.error,
          message: 'Location permissions are denied',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: 'Location permissions are permanently denied',
      );
    }

    // Get current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentLocation = position;
    setState(() {});
    final String googleMapsUrl = 'https://www.google.com/maps/dir/?api=1'
        '&origin=${position.latitude},${position.longitude}'
        '&destination=${widget.toLat},${widget.toLon}'
        '&travelmode=driving';

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl),
          mode: LaunchMode.externalApplication);
    } else {
      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: 'Could not launch Google Maps',
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getRoutePolyline();
    });
  }

  Future<void> _fetchPendingRequest() async {
    if (_hasFetchedPendingRequest) return;
    _hasFetchedPendingRequest = true;

    if (currentLocation == null) return;

    try {
      await context.read<GetWinchOffersProvider>().getPendingRequest(
            locale: context.locale,
            lat: currentLocation!.latitude,
            lon: currentLocation!.longitude,
          );
    } catch (_) {
      // ignore errors here; provider will handle retries via timer if needed
    }
  }

  // Get detailed route polyline from Google Directions API
  Future<void> _getRoutePolyline() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentLocation = position;
    setState(() {
      _isLoading = true;
    });

    // Add markers for pickup and dropoff locations
    _markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(widget.fromLat, widget.fromLon),
        infoWindow: InfoWindow(title: widget.fromText),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );

    _markers.add(
      Marker(
        markerId: const MarkerId('dropoff'),
        position: LatLng(widget.toLat, widget.toLon),
        infoWindow: InfoWindow(title: widget.toText),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    try {
      // Clear existing polylines
      polylineCoordinates = [];

      dev.log("🔍 Attempting to get route between locations");

      bool routeFound = false;
      PolylinePoints polylinePoints = PolylinePoints();

      // Make direct HTTP request to Google Directions API - First attempt
      try {
        const String apiKey1 = '$googleMapApiKey';

        dev.log(
            "💡 Attempt 1: Using API key: $apiKey1 with direct HTTP request");

        final response = await http.get(
          Uri.parse('https://maps.googleapis.com/maps/api/directions/json?'
              'origin=${widget.fromLat},${widget.fromLon}'
              '&destination=${widget.toLat},${widget.toLon}'
              '&mode=driving'
              '&key=$apiKey1'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'OK') {
            // Get route points from the API response
            List<dynamic> steps = data['routes'][0]['legs'][0]['steps'];

            for (var step in steps) {
              String points = step['polyline']['points'];
              polylineCoordinates.addAll(polylinePoints
                  .decodePolyline(points)
                  .map((point) => LatLng(point.latitude, point.longitude)));
            }
            dev.log(
                "✅ Attempt 1 succeeded: Got ${polylineCoordinates.length} route points");
            routeFound = true;
          } else {
            dev.log("⚠️ Attempt 1 failed: ${data['status']}");
          }
        } else {
          dev.log("⚠️ Error fetching route data: ${response.statusCode}");
        }
      } catch (e) {
        dev.log("❌ Attempt 1 exception: $e");
      }

      // Second attempt with different API key if first attempt failed
      if (!routeFound) {
        try {
          const String apiKey2 = '$googleMapApiKey';

          dev.log(
              "💡 Attempt 2: Using API key: $apiKey2 with direct HTTP request");

          final response = await http.get(
            Uri.parse('https://maps.googleapis.com/maps/api/directions/json?'
                'origin=${widget.fromLat},${widget.fromLon}'
                '&destination=${widget.toLat},${widget.toLon}'
                '&mode=driving'
                '&key=$apiKey2'),
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['status'] == 'OK') {
              // Get route points from the API response
              List<dynamic> steps = data['routes'][0]['legs'][0]['steps'];

              polylineCoordinates = []; // Clear any previous points
              for (var step in steps) {
                String points = step['polyline']['points'];
                polylineCoordinates.addAll(polylinePoints
                    .decodePolyline(points)
                    .map((point) => LatLng(point.latitude, point.longitude)));
              }
              dev.log(
                  "✅ Attempt 2 succeeded: Got ${polylineCoordinates.length} route points");
              routeFound = true;
            } else {
              dev.log("⚠️ Attempt 2 failed: ${data['status']}");
              dev.log(
                  "⚠️ IMPORTANT: Enable the Directions API in the Google Cloud Console!");
            }
          } else {
            dev.log("⚠️ Error fetching route data: ${response.statusCode}");
          }
        } catch (e) {
          dev.log("❌ Attempt 2 exception: $e");
        }
      }

      // If we still don't have a route, use direct line fallback
      if (!routeFound) {
        dev.log(
            "⚠️ All attempts to get route failed - using direct line fallback");
        polylineCoordinates = [
          LatLng(widget.fromLat, widget.fromLon),
          LatLng(widget.toLat, widget.toLon),
        ];
      }

      // Add the polyline to the map
      setState(() {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: polylineCoordinates,
            color: ColorsPalette.primaryColor,
            width: 5,
          ),
        );
        _isLoading = false;
      });

      // Fit map bounds to show the route
      if (mapController != null && polylineCoordinates.isNotEmpty) {
        final bounds = _getBounds(polylineCoordinates);
        mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 80.0),
        );
      }
    } catch (e) {
      dev.log('❌ Error in route calculation: $e');
      setState(() {
        // Fallback to direct line on error
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: [
              LatLng(widget.fromLat, widget.fromLon),
              LatLng(widget.toLat, widget.toLon),
            ],
            color: ColorsPalette.primaryColor,
            width: 5,
          ),
        );
        _isLoading = false;
      });
    } finally {
      if (mounted) {
        await _fetchPendingRequest();
      }
    }
  }

  // Calculate bounds to fit all polyline points
  // Calculate bounds to fit all polyline points
  LatLngBounds _getBounds(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  // Deprecated - now using _getBounds instead
  void _zoomToBounds() {
    if (polylineCoordinates.isEmpty || mapController == null) {
      return;
    }

    final bounds = _getBounds(polylineCoordinates);
    mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  int _getDisInKilo() {
    final dis = (int.tryParse(widget.distanceInKilo) ?? 0) / 1000;
    return dis.toInt();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBarApp(
        title: '${LocaleKeys.orderNumber.tr()} ${widget.orderNum}',
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Map fills the whole screen
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: LatLng(
                (widget.fromLat + widget.toLat) / 2,
                (widget.fromLon + widget.toLon) / 2,
              ),
              zoom: 13,
            ),
            markers: _markers,
            polylines: _polylines,
            zoomControlsEnabled: true,
            myLocationEnabled: false,
            compassEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
              // Call _zoomToBounds to fit the map to the route if route points exist
              if (polylineCoordinates.isNotEmpty) {
                _zoomToBounds();
              }
            },
          ),

          // Loading indicator overlay - shown while calculating route
          if (_isLoading)
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                        color: ColorsPalette.primaryColor),
                    const SizedBox(height: 16),
                    Text(
                      'جاري حساب المسار...',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom info panel
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: height * .40,
              color: ColorsPalette.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Column(
                children: [
                  // Vendor name and car info
                  Row(
                    children: [
                      Text(
                        widget.vendorName,
                        style: TextStyle(
                          color: ColorsPalette.customGrey,
                          fontWeight: FontWeight.w400,
                          fontFamily: ZainTextStyles.font,
                          fontSize: 14.sp,
                        ),
                      ),
                      Spacer(),
                      Text(
                        widget.vendorCar,
                        style: TextStyle(
                          color: ColorsPalette.black,
                          fontWeight: FontWeight.w600,
                          fontFamily: ZainTextStyles.font,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                  UtilValues.gap8,

                  //  servicesPrice
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${widget.user.name ?? ""}',
                        style: TextStyle(
                            color: ColorsPalette.black,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: ZainTextStyles.font),
                      ),
                      Spacer(),
                      Text(
                        '${Helpers.formatPrice(widget.total!)}${LocaleKeys.le.tr()}',
                        style: TextStyle(
                            color: ColorsPalette.black,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: ZainTextStyles.font),
                      ),
                    ],
                  ),
                  UtilValues.gap8,
                  // Vendor number and time/distance
                  Row(
                    children: [
                      Text(
                        widget.user.phone ?? "",
                        style: TextStyle(
                          color: ColorsPalette.black,
                          fontWeight: FontWeight.w400,
                          fontFamily: ZainTextStyles.font,
                          fontSize: 14.sp,
                        ),
                      ),
                      Spacer(),
                      Text(
                        '${widget.time} ${LocaleKeys.min.tr()} - ${_getDisInKilo()} ${LocaleKeys.kilo.tr()} ',
                        style: TextStyle(
                          color: ColorsPalette.customGrey,
                          fontWeight: FontWeight.w400,
                          fontFamily: ZainTextStyles.font,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                  UtilValues.gap8,
                  // From location
                  Row(
                    children: [
                      SvgPicture.asset(
                        AssetsManager.location,
                        color: ColorsPalette.primaryColor,
                        height: 15,
                      ),
                      UtilValues.gap4,
                      Text(
                        LocaleKeys.from.tr(),
                        style: TextStyle(
                          color: ColorsPalette.customGrey,
                          fontWeight: FontWeight.w400,
                          fontFamily: ZainTextStyles.font,
                          fontSize: 12.sp,
                        ),
                      ),
                      UtilValues.gap4,
                      Expanded(
                        child: Text(
                          widget.fromText,
                          style: TextStyle(
                            color: ColorsPalette.black,
                            fontWeight: FontWeight.w600,
                            fontFamily: ZainTextStyles.font,
                            fontSize: 12.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  UtilValues.gap8,

                  // To location
                  Row(
                    children: [
                      SvgPicture.asset(
                        AssetsManager.flag,
                        color: ColorsPalette.primaryColor,
                      ),
                      UtilValues.gap4,
                      Text(
                        LocaleKeys.to.tr(),
                        style: TextStyle(
                          color: ColorsPalette.customGrey,
                          fontWeight: FontWeight.w400,
                          fontFamily: ZainTextStyles.font,
                          fontSize: 12.sp,
                        ),
                      ),
                      UtilValues.gap4,
                      Expanded(
                        child: Text(
                          widget.toText,
                          style: TextStyle(
                            color: ColorsPalette.black,
                            fontWeight: FontWeight.w600,
                            fontFamily: ZainTextStyles.font,
                            fontSize: 12.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  UtilValues.gap12,

                  // Action buttons
                  Builder(builder: (context) {
                    return SizedBox(
                      height: 43,
                      child: Row(children: [
                        Expanded(
                          child: SimplePrimaryButton(
                            borderRadius: BorderRadius.circular(5),
                            label: context
                                        .watch<GetWinchOffersProvider>()
                                        .listRequests
                                        .data
                                        ?.acceptedOffer !=
                                    null
                                ? LocaleKeys.delivered.tr()
                                : LocaleKeys.accept.tr(),
                            onPressed: context
                                        .watch<GetWinchOffersProvider>()
                                        .listRequests
                                        .data
                                        ?.acceptedOffer !=
                                    null
                                ? updateOrder
                                : acceptOrder,
                          ),
                        ),
                        UtilValues.gap8,
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: ColorsPalette.black),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: SimplePrimaryButton(
                              borderRadius: BorderRadius.circular(5),
                              label: context
                                          .watch<GetWinchOffersProvider>()
                                          .listRequests
                                          .data
                                          ?.acceptedOffer !=
                                      null
                                  ? LocaleKeys.call.tr()
                                  : LocaleKeys.reject.tr(),
                              backgroundColor: ColorsPalette.white,
                              labelColor: ColorsPalette.black,
                              // onPressed: (){context.watch<GetWinchOffersProvider>().listRequests.data?.acceptedOffer != null ?_callCustomer(context.watch<GetWinchOffersProvider>().listRequests.data?.acceptedOffer?.user?.phone??""):cancelOrder();
                              // },
                              onPressed: () {
                                final provider =
                                    context.read<GetWinchOffersProvider>();
                                if (provider.listRequests.data?.acceptedOffer !=
                                    null) {
                                  _callCustomer(provider.listRequests.data
                                          ?.acceptedOffer?.user?.phone ??
                                      "");
                                } else {
                                  cancelOrder();
                                }
                              },
                            ),
                          ),
                        ),
                      ]),
                    );
                  }),
                  SizedBox(
                    height: 10,
                  ),
                  SimplePrimaryButton(
                    label: LocaleKeys.OpeninGoogleMaps.tr(),
                    onPressed: openGoogleMapsDirections,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _callCustomer(String vendorNum) async {
    await launchUrlString("tel://$vendorNum");
  }

  void cancelOrder() async {
    try {
      // Get current location
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      await MiscellaneousApi.rejectWinchOffer(
          locale: context.locale, orderId: widget.orderNum);
      await MiscellaneousApi.getWinchOffers(
          locale: context.locale,
          lon: position.longitude,
          lat: position.latitude);

      setState(() {});
      showSnackbar(
        context: context,
        status: SnackbarStatus.success,
        message: LocaleKeys.done.tr(),
      );
      Navigator.pop(context);
    } catch (e) {
      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: e.toString(),
      );
    }
  }

  void acceptOrder() async {
    try {
      await MiscellaneousApi.sentWinchOffer(
          locale: context.locale, orderId: widget.orderNum);

      showSnackbar(
        context: context,
        status: SnackbarStatus.success,
        message: LocaleKeys.done.tr(),
      );
      // Navigator.pop(context);
    } catch (e) {
      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: e.toString(),
      );
    }
  }

  void updateOrder() async {
    try {
      await MiscellaneousApi.updateOrderStatusWinch(
          locale: context.locale, orderId: widget.orderNum);

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return WinchOrderDetails(
          orderNum: widget.orderNum,
          vendorName: widget.vendorName,
          userNum: widget.vendorNum,
        );
      }));
      showSnackbar(
        context: context,
        status: SnackbarStatus.success,
        message: LocaleKeys.done.tr(),
      );
      // Navigator.pop(context);
    } catch (e) {
      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: e.toString(),
      );
    }
  }
}
