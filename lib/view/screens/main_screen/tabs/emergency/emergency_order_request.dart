import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ma7lola_vendor/controller/get_emergency_offers_provider.dart';
import 'package:ma7lola_vendor/core/services/http/apis/miscellaneous_api.dart';
import 'package:ma7lola_vendor/core/utils/assets_manager.dart';
import 'package:ma7lola_vendor/core/utils/colors_palette.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../../core/generated/locale_keys.g.dart';
import '../../../../../core/utils/font.dart';
import '../../../../../core/utils/helpers.dart';
import '../../../../../core/utils/snackbars.dart';
import '../../../../../core/utils/util_values.dart';
import '../../../../../core/widgets/custom_app_bar.dart';
import '../../../../../core/widgets/form_widgets/primary_button/simple_primary_button.dart';
import '../../../../../model/emergency/emergency_offers_model.dart';
import 'services_details_screen.dart';

class EmergencyMapRoutePage extends StatefulWidget {
  final double fromLat;
  final double fromLon;
  final double toLat;
  final double toLon;
  final int orderNum;
  final num? servicesPrice;
  final num? taxPrice;
  final num? total;
  final String vendorName;
  final String vendorNum;
  final String vendorCar;
  final String location;
  final User user;

  const EmergencyMapRoutePage({
    Key? key,
    required this.fromLat,
    required this.fromLon,
    required this.toLat,
    required this.user,
    required this.toLon,
    required this.servicesPrice,
    required this.total,
    required this.taxPrice,
    required this.orderNum,
    required this.vendorName,
    required this.vendorNum,
    required this.vendorCar,
    required this.location,
  }) : super(key: key);

  @override
  State<EmergencyMapRoutePage> createState() => _EmergencyMapRoutePageState();
}

class _EmergencyMapRoutePageState extends State<EmergencyMapRoutePage> {
  late GoogleMapController mapController;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _setMarkersAndPolyline();
  }
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

    final String googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1'
        '&origin=${position.latitude},${position.longitude}'
        '&destination=${widget.toLat},${widget.toLon}'
        '&travelmode=driving';

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl), mode: LaunchMode.externalApplication);
    } else {
      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: 'Could not launch Google Maps',
      );
    }
  }

  void _setMarkersAndPolyline() {
    _markers.add(
      Marker(
        markerId: MarkerId('start'),
        position: LatLng(widget.fromLat, widget.fromLon),
        infoWindow: InfoWindow(title: 'نقطة البداية'),
      ),
    );

    _markers.add(
      Marker(
        markerId: MarkerId('end'),
        position: LatLng(widget.toLat, widget.toLon),
        infoWindow: InfoWindow(title: 'نقطة النهاية'),
      ),
    );

    // رسم خط بين النقطتين
    _polylines.add(
      Polyline(
        polylineId: PolylineId('route'),
        points: [
          LatLng(widget.fromLat, widget.fromLon),
          LatLng(widget.toLat, widget.toLon),
        ],
        color: ColorsPalette.primaryColor,
        width: 3,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarApp(
        title: '${LocaleKeys.orderNumber.tr()} ${widget.orderNum}',
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                (widget.fromLat + widget.toLat) / 2,
                (widget.fromLon + widget.toLon) / 2,
              ),
              zoom: 10,
            ),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Align(
              alignment: AlignmentDirectional.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * .38,
                color: ColorsPalette.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.vendorName,
                          style: TextStyle(
                              color: ColorsPalette.customGrey,
                              fontWeight: FontWeight.w400,
                              fontFamily: ZainTextStyles.font,
                              fontSize: 14.sp),
                        ),
                        Spacer(),
                        Text(
                          widget.vendorCar,
                          style: TextStyle(
                              color: ColorsPalette.black,
                              fontWeight: FontWeight.w600,
                              fontFamily: ZainTextStyles.font,
                              fontSize: 12.sp),
                        ),
                      ],
                    ),
                    UtilValues.gap8,
                    //  servicesPrice
                    Row(crossAxisAlignment: CrossAxisAlignment.start ,mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${widget.user.name??""}',
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
                    Row(
                      children: [
                        Text(
                          widget.user.phone??"",
                          style: TextStyle(
                            color: ColorsPalette.black,
                            fontWeight: FontWeight.w400,
                            fontFamily: ZainTextStyles.font,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        SvgPicture.asset(
                          AssetsManager.location,
                          color: ColorsPalette.primaryColor,
                          height: 15,
                        ),
                        UtilValues.gap4,
                        Text(
                          widget.location,
                          style: TextStyle(
                              color: ColorsPalette.black,
                              fontWeight: FontWeight.w600,
                              fontFamily: ZainTextStyles.font,
                              fontSize: 12.sp),
                        ),
                      ],
                    ),
                    UtilValues.gap12,
                    Builder(builder: (context) {
                      context
                          .read<GetEmergencyOffersProvider>()
                          .getPendingRequest(locale: context.locale);

                      return SizedBox(
                        height: 43,
                        child: Row(children: [
                          Expanded(
                            child: SimplePrimaryButton(
                              borderRadius: BorderRadius.circular(5),
                              label: context
                                          .watch<GetEmergencyOffersProvider>()
                                          .listRequests
                                          .data
                                          ?.acceptedOffer !=
                                      null
                                  ? LocaleKeys.delivered.tr()
                                  : LocaleKeys.accept.tr(),
                              onPressed: context
                                          .watch<GetEmergencyOffersProvider>()
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
                                label: context.watch<GetEmergencyOffersProvider>().listRequests.data?.acceptedOffer != null ?LocaleKeys.call.tr():LocaleKeys.reject.tr(),
                                backgroundColor: ColorsPalette.white,
                                labelColor: ColorsPalette.black,
                                // onPressed: cancelOrder,
                                onPressed: () {
                                  final provider = context.read<GetEmergencyOffersProvider>();
                                  if (provider.listRequests.data?.acceptedOffer != null) {
                                    _callCustomer(provider.listRequests.data?.acceptedOffer?.user?.phone ?? "");
                                  } else {
                                    cancelOrder();
                                  }
                                },
                              ),
                            ),
                          )
                        ]),
                      );
                    }),
                    SizedBox(height: 10,),
                    SimplePrimaryButton(
                      label: LocaleKeys.OpeninGoogleMaps.tr(),
                      onPressed: openGoogleMapsDirections,
                    ),
                  ],
                ),
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
      await MiscellaneousApi.rejectEmergencyOffer(
          locale: context.locale, orderId: widget.orderNum);
      await MiscellaneousApi.getEmergencyOffers(locale: context.locale);

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
      await MiscellaneousApi.sentEmergencyOffer(
          locale: context.locale, orderId: widget.orderNum);
      setState(() {});
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
      await MiscellaneousApi.updateOrderStatusEmergency(
          locale: context.locale, orderId: widget.orderNum);

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return ServicesDetailsScreen(
          orderNum: widget.orderNum,
          vendorName: widget.vendorName,
          vendorNum: widget.vendorNum,
          car: widget.vendorCar,
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
