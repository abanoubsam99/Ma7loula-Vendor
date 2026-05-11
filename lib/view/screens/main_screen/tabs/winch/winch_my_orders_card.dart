import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../core/generated/locale_keys.g.dart';
import '../../../../../../core/utils/assets_manager.dart';
import '../../../../../../core/utils/colors_palette.dart';
import '../../../../../../core/utils/font.dart';
import '../../../../../../core/utils/helpers.dart';
import '../../../../../../core/utils/util_values.dart';
import '../../../../../model/winch/winch_offers_model.dart' as w;

class WinchMyOrderCard extends StatelessWidget {
  final String status;
  final total;
  final String date;
  final String? fromText;
  final String? toText;
  final String? myLocText;
  final int orderNum;
  final w.UserCar? car;
  final VoidCallback onTap;

  const WinchMyOrderCard({
    super.key,
    required this.status,
    required this.date,
    required this.total,
    required this.orderNum,
    this.car,
    required this.onTap,
    this.fromText,
    this.toText,
    this.myLocText,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColors();
    return GestureDetector(
        onTap: onTap,
        child: Container(
          // height: 60,
          width: MediaQuery.of(context).size.width,
          // margin: UtilValues.paddinglrt8,
          padding: UtilValues.padding8,
          decoration: BoxDecoration(
              color: ColorsPalette.white,
              borderRadius: UtilValues.borderRadius10,
              border: Border.all(color: ColorsPalette.border2)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                        color: color.first,
                        borderRadius: BorderRadius.circular(25.sp)),
                    child: Text(
                      status,
                      style: TextStyle(
                          color: ColorsPalette.black,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          fontFamily: ZainTextStyles.font),
                    ),
                  ),
                  Spacer(),
                  Text(
                    '${Helpers.formatPrice(total)}${LocaleKeys.le.tr()}',
                    style: TextStyle(
                        color: ColorsPalette.black,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: ZainTextStyles.font),
                  )
                ],
              ),
              UtilValues.gap8,
              Row(
                children: [
                  Text(
                    '${LocaleKeys.orderNumber.tr()} $orderNum',
                    style: TextStyle(
                        color: ColorsPalette.black,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: ZainTextStyles.font),
                  ),
                  Spacer(),
                  Text(
                    date,
                    style: TextStyle(
                        color: ColorsPalette.customGrey,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        fontFamily: ZainTextStyles.font),
                  )
                ],
              ),
              UtilValues.gap8,
              if (fromText != null &&
                  toText != null &&
                  toText!.isNotEmpty &&
                  fromText!.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: ColorsPalette.grey,
                          borderRadius: BorderRadius.circular(5.sp),
                          border: Border.all(color: ColorsPalette.customGrey),
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              AssetsManager.lc,
                              color: ColorsPalette.primaryColor,
                              height: 10,
                              width: 10,
                            ),
                            UtilValues.gap12,
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .3,
                              child: Text(
                                fromText ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: ColorsPalette.black,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: ZainTextStyles.font),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    UtilValues.gap4,
                    Icon(Icons.arrow_right_alt),
                    UtilValues.gap4,
                    Flexible(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: ColorsPalette.grey,
                          borderRadius: BorderRadius.circular(5.sp),
                          border: Border.all(color: ColorsPalette.customGrey),
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              AssetsManager.lc,
                              color: ColorsPalette.primaryColor,
                              height: 10,
                              width: 10,
                            ),
                            UtilValues.gap12,
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .3,
                              child: Text(
                                toText ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: ColorsPalette.black,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: ZainTextStyles.font),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              UtilValues.gap8,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorsPalette.grey,
                  borderRadius: BorderRadius.circular(5.sp),
                  border: Border.all(color: ColorsPalette.customGrey),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      AssetsManager.carShape,
                      color: ColorsPalette.primaryColor,
                      height: 10,
                      width: 10,
                    ),
                    UtilValues.gap12,
                    if (car != null)
                      Text(
                        '${car?.car?.model?.brand?.name} ${car?.car?.model?.name} ${car?.car?.year}',
                        style: TextStyle(
                            color: ColorsPalette.black,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            fontFamily: ZainTextStyles.font),
                      ),
                    /* if (carEm != null)
                      Text(
                        '${carEm?.car?.model?.brand?.name} ${carEm?.car?.model?.name} ${carEm?.car?.year}',
                        style: TextStyle(
                            color: ColorsPalette.black,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            fontFamily: ZainTextStyles.font),
                      ),*/
                  ],
                ),
              ),
              UtilValues.gap4,
              Divider(
                color: ColorsPalette.customGrey.withOpacity(.5),
                endIndent: 10,
                indent: 10,
              ),
              UtilValues.gap8,
              InkWell(
                onTap: onTap, // Use the same callback as the parent GestureDetector
                child: Text(
                  LocaleKeys.orderDetails.tr(),
                  style: TextStyle(
                      color: ColorsPalette.primaryColor, // Changed to primary color to indicate it's clickable
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700, // Made bolder to highlight
                      fontFamily: ZainTextStyles.font),
                ),
              )
            ],
          ),
        ));
  }

  List<Color> _getColors() {
    switch (status) {
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

class OrderStatus {
  static const ORDER_CANCELLED = 'cancelled';
  static const ORDER_NEW = 'new';
  static const ORDER_PREPARING = 'preparing';
  static const ORDER_COMPELETED = 'complete';
  static const ORDER_DELIVERED = 'delivered';
  static const ORDER_ON_THE_RUN = 'on_the_run';

  static const BALANCE = 'balance';
  static const APP_COMMISSION = 'app_commission';
}

/// serm حرارى سيلكون فرى
///
