// import 'package:animated_rating_stars/animated_rating_stars.dart';
import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ma7lola_vendor/core/generated/locale_keys.g.dart';
import 'package:ma7lola_vendor/core/services/http/apis/miscellaneous_api.dart';
import 'package:ma7lola_vendor/core/utils/colors_palette.dart';
import 'package:ma7lola_vendor/core/utils/helpers.dart';
import 'package:ma7lola_vendor/core/widgets/custom_app_bar.dart';
import 'package:ma7lola_vendor/core/widgets/custom_card.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../../../core/utils/assets_manager.dart';
import '../../../../../../core/utils/font.dart';
import '../../../../../../core/utils/util_values.dart';
import '../../../../../../core/widgets/form_widgets/primary_button/simple_primary_button.dart';
import '../../../../../core/utils/snackbars.dart';
import '../../../../../model/winch/order_details_model.dart';
import '../my_orders_tab/local_widet/my_orders_card.dart';

class WinchOrderDetails extends StatefulWidget {
  const WinchOrderDetails({
    Key? key,
    required this.orderNum,
    required this.userNum,
    required this.vendorName,
  }) : super(key: key);

  final int orderNum;
  final String userNum;
  final String vendorName;

  @override
  State<WinchOrderDetails> createState() => _WinchOrderDetailsState();
}

class _WinchOrderDetailsState extends State<WinchOrderDetails> {
  bool _isLoadingAccept = false;
  bool _isLoadingCancel = false;

  String? address;
  var prices;
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          Helpers.isArabic(context) ? TextDirection.rtl : TextDirection.ltr,
      child: FutureBuilder<OrderRateModel>(
          future: MiscellaneousApi.getWinchOrderDetails(
              locale: context.locale, id: widget.orderNum),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    color: ColorsPalette.primaryColor,
                  ),
                ),
              );
            }

            final WinchOrderDetails = snapshot.data!;

            if (WinchOrderDetails.data == null) {
              return SizedBox.shrink();
            }
            final order = WinchOrderDetails.data?.order;
            final color = _getColors(order);

            return Scaffold(
                backgroundColor: ColorsPalette.lightGrey,
                appBar: AppBarApp(
                  title: '${LocaleKeys.orderNumber.tr()} ${widget.orderNum}',
                  actions: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                          color: color.first,
                          borderRadius: BorderRadius.circular(25.sp)),
                      child: Text(
                        order?.status ?? '',
                        style: TextStyle(
                            color: ColorsPalette.black,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            fontFamily: ZainTextStyles.font),
                      ),
                    ),
                  ],
                ),
                body: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UtilValues.gap12,
                      _vendorCard(order?.worker?.name ?? '',
                          order?.worker?.phone ?? ''),
                      Container(
                        decoration: BoxDecoration(
                            color: ColorsPalette.white,
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.all(10),
                        child: Row(
                          children: [
                            SvgPicture.asset(AssetsManager.carShape),
                            UtilValues.gap8,
                            Text(
                              (order?.userCar != null)
                                  ? '${order?.userCar?.car?.model?.brand?.name} ${order?.userCar?.car?.model?.name} ${order?.userCar?.car?.year}'
                                  : '----',
                              style: TextStyle(
                                  color: ColorsPalette.black,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: ZainTextStyles.font,
                                  fontSize: 12.sp),
                            ),
                          ],
                        ),
                      ),
                      UtilValues.gap8,
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LocaleKeys.addressSelected.tr(),
                              style: TextStyle(
                                  color: ColorsPalette.black,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: ZainTextStyles.font,
                                  fontSize: 12.sp),
                            ),
                            UtilValues.gap4,
                            // CustomCard(
                            //   color: ColorsPalette.white,
                            //   border: Border.all(color: ColorsPalette.grey),
                            //   borderRadius: BorderRadius.circular(10),
                            //   child: AddressCard(
                            //     name: order?.fromText ?? '',
                            //     city: order?.toText ?? '',
                            //     details: '${order?.fromLat}, ${order?.fromLon}',
                            //     selected: false,
                            //     // fromCheckout: true,
                            //   ),
                            // ),
                            CustomCard(
                              color: ColorsPalette.white,
                              child: Row(
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
                                        fontSize: 12.sp),
                                  ),
                                  UtilValues.gap4,
                                  Expanded(
                                    child: Text(
                                      order?.fromText ?? '',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: ColorsPalette.black,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: ZainTextStyles.font,
                                          fontSize: 12.sp),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            UtilValues.gap2,
                            CustomCard(
                              color: ColorsPalette.white,
                              child: Row(
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
                                        fontSize: 12.sp),
                                  ),
                                  UtilValues.gap4,
                                  Expanded(
                                    child: Text(
                                      order?.toText ?? '',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: ColorsPalette.black,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: ZainTextStyles.font,
                                          fontSize: 12.sp),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            UtilValues.gap8,
                            Text(
                              LocaleKeys.paymentData.tr(),
                              style: TextStyle(
                                  color: ColorsPalette.black,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: ZainTextStyles.font,
                                  fontSize: 12.sp),
                            ),
                            UtilValues.gap4,
                            CustomCard(
                              border: Border.all(color: ColorsPalette.grey),
                              color: ColorsPalette.white,
                              child: Column(
                                children: [
                                  _winchOrderDetails(LocaleKeys.orderDate.tr(),
                                      order?.durationInMinutes ?? ''),
                                  // _winchOrderDetails(LocaleKeys.onTheWay.tr(),
                                  //     order?.durationInMinutes ?? ''),
                                  // _winchOrderDetails(
                                  //     LocaleKeys.deliveryDate.tr(),
                                  //     order?.durationInMinutes ?? ''),
                                ],
                              ),
                            ),
                            UtilValues.gap8,
                            Text(
                              LocaleKeys.paymentData.tr(),
                              style: TextStyle(
                                  color: ColorsPalette.black,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: ZainTextStyles.font,
                                  fontSize: 12.sp),
                            ),
                            UtilValues.gap4,
                            CustomCard(
                                border: Border.all(color: ColorsPalette.grey),
                                color: ColorsPalette.white,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          LocaleKeys.paymentMethod.tr(),
                                          style: TextStyle(
                                              color: ColorsPalette.customGrey,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: ZainTextStyles.font,
                                              fontSize: 12.sp),
                                        ),
                                        Spacer(),
                                        Text(
                                          (int.tryParse(order?.paymentMethod ?? '') ==
                                                      0 ||
                                                  int.tryParse(order
                                                              ?.paymentMethod ??
                                                          '') ==
                                                      2)
                                              ? LocaleKeys.cash.tr()
                                              : LocaleKeys.credit.tr(),
                                          style: TextStyle(
                                              color: ColorsPalette.black,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: ZainTextStyles.font,
                                              fontSize: 12.sp),
                                        ),
                                        UtilValues.gap4,
                                        SvgPicture.asset(
                                          (int.tryParse(order?.paymentMethod ??
                                                          '') ==
                                                      0 ||
                                                  int.tryParse(order
                                                              ?.paymentMethod ??
                                                          '') ==
                                                      2)
                                              ? AssetsManager.cash
                                              : AssetsManager.masterCard,
                                        ),
                                      ],
                                    ),
                                    _paymentDetails(
                                      LocaleKeys.total.tr(),
                                      Helpers.formatPrice(order?.total)
                                          .toString(),
                                    ),
                                  ],
                                )),
                          ],
                        ),
                      ),
                      UtilValues.gap8,
                      if (order?.rate != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            LocaleKeys.rate.tr(),
                            style: TextStyle(
                                color: ColorsPalette.black,
                                fontWeight: FontWeight.w500,
                                fontFamily: ZainTextStyles.font,
                                fontSize: 12.sp),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: CustomCard(
                              border: Border.all(color: ColorsPalette.grey),
                              color: ColorsPalette.white,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        LocaleKeys.rateService.tr(),
                                        style: TextStyle(
                                            color: ColorsPalette.customGrey,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: ZainTextStyles.font,
                                            fontSize: 12.sp),
                                      ),
                                      Spacer(),
                                      RatingBarIndicator(
                                        rating: double.tryParse(order?.rate?.services?.toString() ?? '') ?? 0.0,
                                        itemBuilder: (context, index) => Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        unratedColor: Colors.grey,
                                        itemCount: 5,
                                        itemSize: 15.0,
                                        direction: Axis.horizontal,
                                      ),
                                      // AnimatedRatingStars(
                                      //   readOnly: true,
                                      //   initialRating: double.parse(
                                      //       order?.rate?.services?.toString() ??
                                      //           ''),
                                      //   onChanged: (rating) {},
                                      //   displayRatingValue:
                                      //       true, // Display the rating value
                                      //   interactiveTooltips:
                                      //       true, // Allow toggling half-star state
                                      //   customFilledIcon: Icons.star,
                                      //   customHalfFilledIcon: Icons.star_half,
                                      //   customEmptyIcon: Icons.star_border,
                                      //   starSize: 15.0,
                                      //   animationDuration:
                                      //       const Duration(milliseconds: 500),
                                      //   animationCurve: Curves.easeInOut,
                                      // ),
                                    ],
                                  ),
                                ],
                              )),
                        ),
                      ],
                    if (order?.status == 'new') ...[
                      UtilValues.gap8,
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(children: [
                          Expanded(
                            child: SimplePrimaryButton(
                              borderRadius: BorderRadius.circular(5),
                              label: LocaleKeys.sub.tr(),
                              isLoading: _isLoadingAccept,
                              onPressed: _isLoadingAccept ? null : _acceptOrder,
                            ),
                          ),
                          UtilValues.gap8,
                          Expanded(
                            child: SimplePrimaryButton(
                              borderRadius: BorderRadius.circular(5),
                              label: LocaleKeys.cancel.tr(),
                              backgroundColor: ColorsPalette.white,
                              labelColor: ColorsPalette.customGrey,
                              isLoading: _isLoadingCancel,
                              onPressed: _isLoadingCancel ? null : _cancelOrder,
                            ),
                          )
                        ]),
                      ),
                    ],
                  ],
                ),
              ));
          }),
    );
  }

  void _acceptOrder() async {
    try {
      setState(() {
        _isLoadingAccept = true;
      });
      await MiscellaneousApi.updateOrderStatusWinch(
        locale: context.locale,
        orderId: widget.orderNum,
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return WinchOrderDetails(
          orderNum: widget.orderNum,
          userNum: widget.userNum,
          vendorName: widget.vendorName,
        );
      }));
      showSnackbar(
        context: context,
        status: SnackbarStatus.success,
        message: LocaleKeys.done.tr(),
      );
    } catch (e) {
      setState(() {
        _isLoadingAccept = false;
      });
      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: e.toString(),
      );
    }
  }

  void _cancelOrder() async {
    try {
      setState(() {
        _isLoadingCancel = true;
      });
      // For winch orders, we may need to check if there's a specific cancel method
      // For now, we'll use updateOrderStatusWinch with a cancel status
      // You may need to adjust this based on your API requirements
      await MiscellaneousApi.updateOrderStatusWinch(
        locale: context.locale,
        orderId: widget.orderNum,
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return WinchOrderDetails(
          orderNum: widget.orderNum,
          userNum: widget.userNum,
          vendorName: widget.vendorName,
        );
      }));
      setState(() {
        _isLoadingCancel = false;
      });
      showSnackbar(
        context: context,
        status: SnackbarStatus.success,
        message: LocaleKeys.done.tr(),
      );
    } catch (e) {
      setState(() {
        _isLoadingCancel = false;
      });
      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: e.toString(),
      );
    }
  }

  _paymentDetails(String text, String num) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: TextStyle(
              color: ColorsPalette.customGrey,
              fontWeight: FontWeight.w400,
              fontFamily: ZainTextStyles.font,
              fontSize: 12.sp),
        ),
        Spacer(),
        Text(
          num.toString(),
          style: TextStyle(
              color: ColorsPalette.black,
              fontWeight: FontWeight.w600,
              fontFamily: ZainTextStyles.font,
              fontSize: 12.sp),
        ),
        UtilValues.gap4,
        Text(
          LocaleKeys.le.tr(),
          style: TextStyle(
              color: ColorsPalette.customGrey,
              fontWeight: FontWeight.w400,
              fontFamily: ZainTextStyles.font,
              fontSize: 12.sp),
        ),
      ],
    );
  }

  _winchOrderDetails(String text, String date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: TextStyle(
              color: ColorsPalette.customGrey,
              fontWeight: FontWeight.w400,
              fontFamily: ZainTextStyles.font,
              fontSize: 12.sp),
        ),
        Spacer(),
        Text(
          date,
          style: TextStyle(
              color: ColorsPalette.black,
              fontWeight: FontWeight.w600,
              fontFamily: ZainTextStyles.font,
              fontSize: 12.sp),
        ),
      ],
    );
  }

  _vendorCard(String vendorName, String vendorNum) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      height: 80,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: ColorsPalette.white,
          borderRadius: UtilValues.borderRadius10,
          border: Border.all(color: ColorsPalette.border2)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                AssetsManager.userPic,
                width: MediaQuery.of(context).size.width * .2,
                fit: BoxFit.fill,
              ),
            ),
          ),
          UtilValues.gap12,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              UtilValues.gap8,
              Text(
                vendorName,
                style: const TextStyle(
                    color: ColorsPalette.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: ZainTextStyles.font),
              ),
              UtilValues.gap8,
              SizedBox(
                height: 20,
                width: MediaQuery.of(context).size.width * .57,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      vendorNum,
                      style: const TextStyle(
                          color: ColorsPalette.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: ZainTextStyles.font),
                    ),
                    Spacer(),
                    Row(
                      children: [
                        InkWell(
                            onTap: () => _callVendor(vendorNum),
                            child: SvgPicture.asset(
                              AssetsManager.phone,
                            )),
                        UtilValues.gap24,
                        InkWell(
                            onTap: () => _openSmsChat(vendorNum),
                            child: Icon(
                              CupertinoIcons.chat_bubble_text,
                              size: 17,
                            )),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
          UtilValues.gap4
        ],
      ),
    );
  }

  void _callVendor(String vendorNum) async {
    await launchUrlString("tel://$vendorNum");
  }

  void _openSmsChat(String vendorNum) async {
    await launchUrlString("sms://$vendorNum");
  }

  List<Color> _getColors(Order? order) {
    switch (order?.status) {
      case OrderStatus.ORDER_CANCELLED:
      case OrderStatus.ORDER_ON_THE_RUN:
        return [ColorsPalette.yellow];

      case OrderStatus.ORDER_DELIVERED:
      case OrderStatus.ORDER_COMPELETED:
        return [ColorsPalette.lightGreen];

      case OrderStatus.ORDER_PREPARING:
      case OrderStatus.ORDER_NEW:
        return [ColorsPalette.lightBlue];

      default:
        return [ColorsPalette.lightpre];
    }
  }
}
