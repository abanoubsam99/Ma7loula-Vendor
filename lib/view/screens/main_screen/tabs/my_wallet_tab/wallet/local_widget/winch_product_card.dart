import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../../core/generated/locale_keys.g.dart';
import '../../../../../../../core/utils/colors_palette.dart';
import '../../../../../../../core/utils/font.dart';
import '../../../../../../../core/utils/helpers.dart';
import '../../../../../../../core/utils/util_values.dart';
import '../../../my_orders_tab/local_widet/my_orders_card.dart';

class WinchProductCard extends StatelessWidget {
  final String? orderID;
  final String date;
  final String type;
  final amount;

  const WinchProductCard({
    super.key,
    required this.orderID,
    required this.date,
    required this.type,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColors();

    return Container(
      width: MediaQuery.of(context).size.width,
      // margin: UtilValues.paddinglrt8,
      padding: UtilValues.padding8,
      decoration: BoxDecoration(
          color: ColorsPalette.white,
          borderRadius: UtilValues.borderRadius10,
          border: Border.all(color: ColorsPalette.border2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(
                '${LocaleKeys.orderNumber.tr()} $orderID',
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
          UtilValues.gap12,
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                    color: color.first,
                    borderRadius: BorderRadius.circular(25.sp)),
                child: Text(
                  type,
                  style: TextStyle(
                      color: ColorsPalette.black,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: ZainTextStyles.font),
                ),
              ),
              Spacer(),
              Text(
                '${Helpers.formatPrice(amount)}${LocaleKeys.le.tr()}',
                style: TextStyle(
                    color: ColorsPalette.black,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: ZainTextStyles.font),
              )
            ],
          ),
        ],
      ),
    );
  }

  List<Color> _getColors() {
    switch (type) {
      case OrderStatus.APP_COMMISSION:
        return [ColorsPalette.lightpre];

      case OrderStatus.BALANCE:
        return [ColorsPalette.lightGreen];

      default:
        return [ColorsPalette.lightpre];
    }
  }
}
