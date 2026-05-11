import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../../core/generated/locale_keys.g.dart';
import '../../../../../../core/utils/assets_manager.dart';
import '../../../../../../core/utils/colors_palette.dart';
import '../../../../../../core/utils/font.dart';
import '../../../../../../core/utils/util_values.dart';
import '../../../../../../core/widgets/custom_network_image.dart';
import '../../../../../../model/products_model.dart';
import 'product_details_screen.dart';

class ProductCard extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String productName;
  final String description;
  final int? qtyProduct;
  final price;
  final discount;
  // final DiscountUnit discountUnit;
  final int? loyalityPoints;
  final VoidCallback onTap;
  final VoidCallback onPressed;
  final VoidCallback onPressedMinus;
  final Products products;
  //int pickup = 0;

  const ProductCard({
    super.key,
    required this.imageUrl,
    this.qtyProduct = 1,
    required this.onPressedMinus,
    required this.productName,
    required this.title,
    required this.description,
    required this.price,
    required this.discount,
    // required this.discountUnit,
    required this.onTap,
    required this.onPressed,
    this.loyalityPoints,
    required this.products,
    
    //required this.pickup
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          height: MediaQuery.of(context).size.height / 2,
          width: MediaQuery.of(context).size.width,
          // margin: UtilValues.paddinglrt8,
          // padding: UtilValues.padding8,
          decoration: BoxDecoration(
              color: ColorsPalette.white,
              borderRadius: UtilValues.borderRadius10,
              border: Border.all(color: ColorsPalette.border2)),
          child: Column(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                    child: (imageUrl != null && (imageUrl?.isNotEmpty ?? false))
                        ? CustomNetworkImage(
                            height: 140,
                            width: MediaQuery.of(context).size.width,
                            imageUrl: imageUrl ?? '',
                            fit: BoxFit.fill,
                          )
                        : Container(
                            height: 140,
                            color: ColorsPalette.lightpre,
                          ),
                  ),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return ProductDetailsScreen(
                            product: products,
                          );
                        }));
                      },
                      child: Container(
                        height: 25,
                        width: 25,
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: ColorsPalette.white,
                            borderRadius: BorderRadius.circular(30)),
                        child: SvgPicture.asset(
                          AssetsManager.dots,
                          color: ColorsPalette.customGrey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              UtilValues.gap12,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .5,
                      child: Text(
                        products.brand?.name ?? '-',
                        style: TextStyle(
                            color: ColorsPalette.customGrey,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily: ZainTextStyles.font),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .5,
                      child: Text(
                        title,
                        maxLines: 1,
                        style: const TextStyle(
                            color: ColorsPalette.black,
                            fontWeight: FontWeight.w600,
                            fontFamily: ZainTextStyles.font,
                            fontSize: 15),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .58,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (discount > 0) ...[
                            Text(
                              discount.toString(),
                              style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: ColorsPalette.red,
                                  color: ColorsPalette.red,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: ZainTextStyles.font),
                            ),
                          ],
                          UtilValues.gap4,
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                // ((qtyProduct ?? 1) * price).toString()
                                price.toString()
                                /*== 0
                                    ? LocaleKeys.priceOnSelection.tr()
                                    : Helpers.formatPrice(price)*/
                                ,
                                style: TextStyle(
                                  color: ColorsPalette.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              UtilValues.gap4,
                              Text(
                                LocaleKeys.le.tr(),
                                style: TextStyle(
                                  color: ColorsPalette.customGrey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
