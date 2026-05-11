import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ma7lola_vendor/core/generated/locale_keys.g.dart';
import 'package:ma7lola_vendor/core/utils/colors_palette.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/utils/assets_manager.dart';
import '../../../../../core/utils/font.dart';
import '../../../../../core/utils/util_values.dart';
import '../../../../../model/category_model.dart';
import '../home_tab/local_widgets/category_card.dart';
import 'batteries/my_batteries.dart';
import 'tires/my_tires.dart';

class MyProductsTab extends StatefulWidget {
  @override
  _MyProductsTabState createState() => _MyProductsTabState();
}

class _MyProductsTabState extends State<MyProductsTab> {
  @override
  Widget build(BuildContext context) {
    final List<CategoriesModel> categories = [
      CategoriesModel(
          pic: AssetsManager.simple,
          title: LocaleKeys.tires.tr(),
          onTap: () {
            // Ensure we're only navigating to the Tires screen
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MyTiresScreen(
                  index: 0,
                ),
              ),
            );
          }),
      CategoriesModel(
          pic: AssetsManager.simple1,
          title: LocaleKeys.batteries.tr(),
          onTap: () {
            // Ensure we're only navigating to the Batteries screen
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MyBatteriesScreen(
                  index: 0,
                ),
              ),
            );
          }),
    ];

    return Scaffold(
        backgroundColor: ColorsPalette.lightGrey,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            UtilValues.gap48,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                LocaleKeys.myProducts.tr(),
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: ColorsPalette.black,
                    fontFamily: ZainTextStyles.font),
                textAlign: TextAlign.start,
                //maxLines: 3,
              ),
            ),
            Expanded(
              child: ListView.separated(
                  separatorBuilder: (context, index) {
                    return UtilValues.gap4;
                  },
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: CategoriesCard(
                        title: categories[index].title ?? '',
                        pic: categories[index].pic ?? '',
                        onTap: categories[index].onTap,
                      ),
                    );
                  }),
            ),
          ]),
        ));
  }
}
