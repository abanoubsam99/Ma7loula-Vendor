// import 'package:animated_rating_stars/animated_rating_stars.dart';
import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ma7lola_vendor/core/generated/locale_keys.g.dart';
import 'package:ma7lola_vendor/core/services/http/apis/miscellaneous_api.dart';
import 'package:ma7lola_vendor/core/utils/colors_palette.dart';
import 'package:ma7lola_vendor/core/utils/helpers.dart';
import 'package:ma7lola_vendor/core/widgets/custom_app_bar.dart';
import 'package:ma7lola_vendor/core/widgets/custom_card.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../controller/user_provider.dart';
import '../../../../../../core/utils/assets_manager.dart';
import '../../../../../../core/utils/font.dart';
import '../../../../../../core/utils/util_values.dart';
import '../../../../../../core/widgets/loading_widget.dart';
import '../../../../../core/utils/snackbars.dart';
import '../../../../../core/widgets/form_widgets/primary_button/simple_primary_button.dart';
import '../../../../../model/order_details_model.dart';
import '../../../addresses_book_screen/local_widgets/address_card.dart';
import 'local_widet/my_orders_card.dart';
import 'local_widet/product_card.dart';

class OrderDetails extends StatefulWidget {
  const OrderDetails({
    Key? key,
    // required this.status,
    required this.orderNum,
    // required this.products,
    // required this.paymentMethod,
    // required this.car,
    // required this.total,
    // required this.orderDate,
    // required this.deliveryDate,
    required this.orderType,
  }) : super(key: key);

  // final List<Products> products;
  // final String status;
  // final String orderDate;
  // final String deliveryDate;
  final int orderNum;
  final int orderType;
  // final int paymentMethod;
  // final total;
  // final UserCar? car;

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  bool _isLoading = false;
  final TextEditingController _priceController = TextEditingController();
  String? address;
  var prices;
  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Directionality(
        textDirection: Helpers.isArabic(context) ? TextDirection.rtl : TextDirection.ltr,
        child: FutureBuilder<OrderRateModel>(
            future: /*(widget.orderType == 0)
                ? MiscellaneousApi.getBatteryOrderDetails(
                    locale: context.locale, id: widget.orderNum)
                : (widget.orderType == 1)
                    ? MiscellaneousApi.getTiresOrderDetails(
                        locale: context.locale, id: widget.orderNum)
                    :*/
                MiscellaneousApi.getCarPartsOrderDetails(
                    locale: context.locale, id: widget.orderNum),
            builder: (context, snapshot) {

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }
              if (snapshot.data == null) {
                return Center(child: CircularProgressIndicator(color: ColorsPalette.primaryColor,),);
              }
              final orderDetails = snapshot.data!;

              if (orderDetails.data == null) {
                return SizedBox.shrink();
              }
              final order = orderDetails.data?.order;
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
                          (order?.status ?? '').tr(),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '${LocaleKeys.products.tr()} (${order?.products?.length})',
                            style: TextStyle(
                                color: ColorsPalette.black,
                                fontWeight: FontWeight.w500,
                                fontFamily: ZainTextStyles.font,
                                fontSize: 12.sp),
                          ),
                        ),
                        _productsWidget(order),
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
                              Builder(builder: (context) {
                                final userProvider = context.read<UserProvider>();
                                if (userProvider.user != null) {
                                  address = userProvider.user?.data?.user?.vendor?.address;
                                  if (address != null) {
                                    return CustomCard(
                                      color: ColorsPalette.white,
                                      border:
                                          Border.all(color: ColorsPalette.grey),
                                      borderRadius: BorderRadius.circular(10),
                                      child: AddressCard(
                                        name: address ?? '',
                                        city: address ?? '',
                                        details: address ?? '',
                                        selected: false,
                                        // fromCheckout: true,
                                      ),
                                    );
                                  }
                                }
                                return SizedBox.shrink();
                              }),
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
                                    _orderDetails(LocaleKeys.orderDate.tr(),
                                        order?.deliveryTime ?? ''),
                                    // _orderDetails(LocaleKeys.onTheWay.tr(),
                                    //     order?.deliveryTime ?? ''),
                                    // _orderDetails(LocaleKeys.deliveryDate.tr(),
                                    //     order?.deliveryTime ?? ''),
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
                                            (order?.paymentMethod == 0 ||
                                                    order?.paymentMethod == 2)
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
                                            (order?.paymentMethod == 0 ||
                                                    order?.paymentMethod == 2)
                                                ? AssetsManager.cash
                                                : AssetsManager.masterCard,
                                          ),
                                        ],
                                      ),
                                      _paymentDetails(
                                        LocaleKeys.total.tr(),
                                        Helpers.formatPrice(order?.total).toString(),
                                      ),
                                      if(order?.offered_total!=null)
                                      _paymentDetails(
                                        "Offered Total".tr(),
                                        Helpers.formatPrice(order?.offered_total??0).toString(),
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
                                        SizedBox(height: 4),
                                        Text(
                                          (double.tryParse(order?.rate?.services?.toString() ?? '') ?? 0.0)
                                              .toStringAsFixed(1),
                                          style: TextStyle(fontSize: 12),
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
                        if(order?.status=="new")
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(children: [
                            Expanded(
                              flex: 1, 
                              child: SimplePrimaryButton(
                                borderRadius: BorderRadius.circular(5),
                                label: "Change Price".tr(),
                                onPressed: () {
                                  final value = num.tryParse(_priceController.text);

                                  if (value == null) {
                                    showSnackbar(
                                      context: context,
                                      status: SnackbarStatus.error,
                                      message: "Invalid price",
                                    );
                                    return;
                                  }

                                  updatePriceOrder(value);
                                },
                                // backgroundColor: ColorsPalette.white,

                                // labelColor: ColorsPalette.customGrey,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  controller: _priceController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: "Enter new price".tr(),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(children: [
                            Expanded(
                              child: SimplePrimaryButton(
                                borderRadius: BorderRadius.circular(5),
                                label: LocaleKeys.sub.tr(),
                                onPressed:updateOrder,
                              ),
                            ),
                            UtilValues.gap8,
                            Expanded(
                              child: SimplePrimaryButton(
                                borderRadius: BorderRadius.circular(5),
                                label: LocaleKeys.cancel.tr(),
                                backgroundColor: ColorsPalette.white,
                                labelColor: ColorsPalette.customGrey,
                                onPressed: cancelOrder,
                              ),
                            )
                          ]),
                        ),
                      ],
                    ),
                  ));
            }),
      ),
    );
  }
  void updateOrder() async {
    try {
      await MiscellaneousApi.updateCarPartsOrderStatus(locale: context.locale, orderId: widget.orderNum);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return OrderDetails(
          orderNum: widget.orderNum,
          orderType: widget.orderType
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
  Future<void> updatePriceOrder(num offered_total) async {
    try {

      await MiscellaneousApi.carPartsSubmitPriceOffer(
        locale: context.locale,
        orderId: widget.orderNum,
        offered_total: offered_total,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return OrderDetails(
              orderNum: widget.orderNum,
              orderType: widget.orderType,
            );
          },
        ),
      );

      showSnackbar(
        context: context,
        status: SnackbarStatus.success,
        message: LocaleKeys.done.tr(),
      );

    }  catch (e) {
      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: e.toString(),
      );
    }
  }


  void cancelOrder() async {
    try {
      if (widget.orderType == 0) {
        await MiscellaneousApi.cancelBatteryOrder(
            id: widget.orderNum, locale: context.locale);
        await MiscellaneousApi.getBatteryOrderDetails(
            locale: context.locale, id: widget.orderNum);
      } else if (widget.orderType == 1) {
        await MiscellaneousApi.cancelTiresOrder(
            id: widget.orderNum, locale: context.locale);
        await MiscellaneousApi.getTiresOrderDetails(
            locale: context.locale, id: widget.orderNum);
      } else {
        await MiscellaneousApi.cancelCarPartsOrder(
            id: widget.orderNum, locale: context.locale);
        await MiscellaneousApi.getCarPartsOrderDetails(
            locale: context.locale, id: widget.orderNum);
      }
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

  void _rateOrder({
    required double productsRate,
    required double servicesRate,
    required String comment,
  }) async {
    try {
      if (widget.orderType == 0) {
        await MiscellaneousApi.rateBatteryOrder(
          id: widget.orderNum,
          locale: context.locale,
          productsRate: productsRate,
          servicesRate: servicesRate,
          comment: comment,
        );
        await MiscellaneousApi.getBatteryOrderDetails(
            locale: context.locale, id: widget.orderNum);
      } else if (widget.orderType == 1) {
        await MiscellaneousApi.rateTiresOrder(
          id: widget.orderNum,
          locale: context.locale,
          productsRate: productsRate,
          servicesRate: servicesRate,
          comment: comment,
        );
        await MiscellaneousApi.getTiresOrderDetails(
            locale: context.locale, id: widget.orderNum);
      } else {
        await MiscellaneousApi.rateCarPartsOrder(
          id: widget.orderNum,
          locale: context.locale,
          productsRate: productsRate,
          servicesRate: servicesRate,
          comment: comment,
        );
        await MiscellaneousApi.getCarPartsOrderDetails(
            locale: context.locale, id: widget.orderNum);
      }
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

  double _ratingService = 0;
  double _ratingProducts = 0;
  String _comment = '';
  _showDialog() {
    showDialog(
      // barrierDismissible: isButtonEnabled,
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              LocaleKeys.rateOrder.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: ColorsPalette.black,
                fontFamily: ZainTextStyles.font,
              ),
              //maxLines: 3,
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LocaleKeys.rateProducts.tr(),
                  style: TextStyle(
                      color: ColorsPalette.customGrey,
                      fontWeight: FontWeight.w400,
                      fontFamily: ZainTextStyles.font,
                      fontSize: 12.sp),
                ),
                RatingBar.builder(
                  initialRating: 0,
                  minRating: 0,
                  allowHalfRating: true,
                  direction: Axis.horizontal,
                  itemCount: 5,
                  itemSize: 40.0,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  unratedColor: Colors.grey,
                  itemBuilder: (context, index) => Icon(
                    Icons.star, // You can add logic here for custom half icons if needed
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      _ratingProducts = rating;
                    });
                  },
                ),
                // AnimatedRatingStars(
                //   initialRating: 0,
                //   onChanged: (rating) {
                //     setState(() {
                //       _ratingProducts = rating;
                //     });
                //   },
                //   displayRatingValue: true, // Display the rating value
                //   interactiveTooltips: true, // Allow toggling half-star state
                //   customFilledIcon: Icons.star,
                //   customHalfFilledIcon: Icons.star_half,
                //   customEmptyIcon: Icons.star_border,
                //   starSize: 40.0,
                //   animationDuration: const Duration(milliseconds: 500),
                //   animationCurve: Curves.easeInOut,
                // ),
                UtilValues.gap16,
                Text(
                  LocaleKeys.rateService.tr(),
                  style: TextStyle(
                      color: ColorsPalette.customGrey,
                      fontWeight: FontWeight.w400,
                      fontFamily: ZainTextStyles.font,
                      fontSize: 12.sp),
                ),
                RatingBar.builder(
                  initialRating: _ratingService, // if you want to preserve state
                  minRating: 0,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 40.0,
                  direction: Axis.horizontal,
                  glow: false, // disable glow effect if you want a flat look
                  itemBuilder: (context, index) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  unratedColor: Colors.grey,
                  updateOnDrag: true, // makes it interactive like a slider
                  onRatingUpdate: (rating) {
                    setState(() {
                      _ratingService = rating;
                    });
                  },
                ),
                // AnimatedRatingStars(
                //   initialRating: 0,
                //   onChanged: (rating) {
                //     setState(() {
                //       _ratingService = rating;
                //     });
                //   },
                //   displayRatingValue: true, // Display the rating value
                //   interactiveTooltips: true, // Allow toggling half-star state
                //   customFilledIcon: Icons.star,
                //   customHalfFilledIcon: Icons.star_half,
                //   customEmptyIcon: Icons.star_border,
                //   starSize: 40.0,
                //   animationDuration: const Duration(milliseconds: 500),
                //   animationCurve: Curves.easeInOut,
                // ),
                UtilValues.gap16,
              ],
            ),
            actions: <Widget>[
              Row(
                children: [
                  Container(
                    // padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    // margin: EdgeInsets.all(1.sp),
                    height: 5.h,
                    child: ElevatedButton(
                        onPressed: () {
                          _rateOrder(
                              productsRate: _ratingProducts,
                              servicesRate: _ratingService,
                              comment: _comment);
                        },
                        style: ButtonStyle(
                            textStyle: MaterialStateProperty.all<TextStyle>(
                              TextStyle(
                                fontSize: 14.sp,
                              ),
                            ),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(
                                    color: ColorsPalette.primaryColor),
                              ),
                            ),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                ColorsPalette.primaryColor)),
                        child: Text(
                          LocaleKeys.save.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: ColorsPalette.lightGrey,
                              fontFamily: ZainTextStyles.font),
                          //maxLines: 3,
                        )),
                  ),
                  UtilValues.gap8,
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ButtonStyle(
                      textStyle: MaterialStateProperty.all<TextStyle>(
                        TextStyle(
                            fontSize: 14.sp, fontFamily: ZainTextStyles.font),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: ColorsPalette.black),
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          ColorsPalette.lightGrey),
                    ),
                    child: Text(
                      LocaleKeys.cancel.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: ColorsPalette.black,
                          fontFamily: ZainTextStyles.font),
                      //maxLines: 3,
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
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

  _orderDetails(String text, String date) {
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

  List<Map<String, dynamic>> prepareProductData(List<Products> products) {
    List<Map<String, dynamic>> productData = [];

    for (var product in products.toSet()) {
      productData.add({
        "id": product.id,
        "qty": product.qty,
      });
    }

    return productData;
  }

  _startSearchButton() {
    return Container(
      margin: EdgeInsets.all(10.sp),
      height: 6.h,
      child: ElevatedButton(
        onPressed: () {},
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all<TextStyle>(
            TextStyle(fontSize: 14.sp, fontFamily: ZainTextStyles.font),
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: ColorsPalette.primaryColor),
            ),
          ),
          backgroundColor:
              MaterialStateProperty.all<Color>(ColorsPalette.primaryColor),
        ),
        child: Center(
          child: _isLoading
              ? const LoadingWidget(
                  color: ColorsPalette.white,
                )
              : Text(
                  LocaleKeys.editProfile.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColorsPalette.white,
                      fontFamily: ZainTextStyles.font,
                      fontSize: 12.sp),
                ),
        ),
      ),
    );
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

  _productsWidget(Order? order) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: order?.products?.length,
          itemBuilder: (context, index) {
            final product = order?.products?[index];
            return Padding(
              padding: EdgeInsets.all(5.0.sp),
              child: InkWell(
                onTap: () {},
                child: ProductCard(
                  imageUrl: product?.thumbnail?.url ?? '',
                  title: product?.name ?? '',
                  onTap: () {},
                  onPressed: () {},
                  onPressedMinus: () {},
                  inCart: false,
                  showAdd: false,
                  description: '',
                  price: product?.total ?? 0.0,
                  discount: 0.0,
                  by: LocaleKeys.by.tr(),
                  vendorName: product?.vendor?.name ?? '',
                  productName: '',
                  qtyProduct: product?.qty ?? 1,
                  products: product!,
                ),
              ),
            );
          }),
    );
  }
}
