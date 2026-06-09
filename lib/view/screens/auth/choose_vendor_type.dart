import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:ma7lola_vendor/core/utils/font.dart';
import 'package:ma7lola_vendor/core/widgets/custom_card.dart';
import 'package:sizer/sizer.dart';

import '../../../core/generated/locale_keys.g.dart';
import '../../../core/services/secure_storage/secure_storage_keys.dart.dart';
import '../../../core/services/secure_storage/secure_storage_service.dart';
import '../../../core/utils/assets_manager.dart';
import '../../../core/utils/colors_palette.dart';
import '../../../core/utils/util_values.dart';
import '../../../model/requirements_doc_model.dart';
import 'LoginScreen.dart';
import 'required_doc.dart';

class ChooseVendorType extends StatefulWidget {
  // static const String routeName = '/ChooseVendorType';

  bool isIntroScreen;
  ChooseVendorType({Key? key, required this.isIntroScreen}) : super(key: key);

  @override
  State<ChooseVendorType> createState() => _ChooseVendorTypeState();
}

class _ChooseVendorTypeState extends State<ChooseVendorType> {
  final List<Requirements> reqDoc = [
    Requirements(
      id: 1,
      title: LocaleKeys.btVendorTitle.tr(),
      body: LocaleKeys.btVendorBody.tr(),
    ),
    Requirements(
      id: 2,
      title: LocaleKeys.carPartsVendorTitle.tr(),
      body: LocaleKeys.carPartsVendorBody.tr(),
    ),
    Requirements(
      id: 3,
      title: LocaleKeys.winchVendorTitle.tr(),
      body: LocaleKeys.winchVendorBody.tr(),
    ),
    Requirements(
      id: 4,
      title: LocaleKeys.emergencyVendorTitle.tr(),
      body: LocaleKeys.emergencyVendorBody.tr(),
    ),
  ];
  int _vendorId = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: ColorsPalette.lighttGrey,
            image: DecorationImage(
              fit: BoxFit.fill,
              colorFilter: ColorFilter.mode(ColorsPalette.light.withOpacity(.9), BlendMode.lighten),
              image: AssetImage(AssetsManager.backgroundLogo),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
              UtilValues.gap24,
              Center(
                child: Text(
                  LocaleKeys.vendorType.tr(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontFamily: ZainTextStyles.font, fontSize: 22.sp),
                ),
              ),
              UtilValues.gap32,
              Expanded(
                  child: ListView.separated(
                      separatorBuilder: (context, index) {
                        return UtilValues.gap12;
                      },
                      itemCount: reqDoc.length ?? 0,
                      itemBuilder: (context, index) {
                        final doc = reqDoc[index];
                        return _chooseVendorTypeCard(doc.title ?? '', doc.body ?? '', doc.id ?? 0);
                      })),
              // Spacer(),
              _changePasswordButton(),
              UtilValues.gap16
            ]),
          ),
        ),
      ),
    );
  }

  _changePasswordButton() {
    return Container(
      margin: EdgeInsets.all(1.sp),
      height: 6.h,
      child: ElevatedButton(
        onPressed: () async {
          if (_vendorId != 0) {
            await Future.wait([
              SecureStorageService.instance.writeString(
                key: SecureStorageKeys.vendorID,
                value: _vendorId.toString(),
              ),
            ]).then((value) => (widget.isIntroScreen == true)
                ? Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return LoginScreen(
                      products: [],
                      batteries: [],
                      tires: [],
                      carID: 0,
                      fromCart: false,
                      fromCartBatteries: false,
                      fromCartTires: false,
                      car: null,
                    );
                  }))
                : Navigator.pushNamed(context, RequiredDoc.routeName));
          }
        },
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all<TextStyle>(
            TextStyle(fontSize: 14.sp, fontFamily: ZainTextStyles.font),
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: _vendorId != 0 ? ColorsPalette.primaryColor : ColorsPalette.primaryColor.withOpacity(0.10),
              ),
            ),
          ),
          backgroundColor: MaterialStateProperty.all<Color>(
            _vendorId != 0 ? ColorsPalette.primaryColor : ColorsPalette.primaryColor.withOpacity(0.10),
          ),
        ),
        child: Center(
          child: Text(
            LocaleKeys.continu.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: ColorsPalette.white, fontFamily: ZainTextStyles.font, fontSize: 12.sp),
          ),
        ),
      ),
    );
  }

  _chooseVendorTypeCard(String title, String description, int value) {
    return InkWell(
      onTap: () {
        setState(() {
          _vendorId = value;
        });
      },
      child: CustomCard(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          color: ColorsPalette.white,
          child: Row(
            children: [
              Radio(value: value, groupValue: _vendorId, onChanged: (int? e) {
                if (e != null) {
                  setState(() {
                    _vendorId = e;
                  });
                }
              }),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        color: ColorsPalette.black,
                        fontWeight: FontWeight.w700,
                        fontFamily: ZainTextStyles.font,
                        fontSize: 12.sp),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .7,
                    child: Text(
                      description,
                      style: TextStyle(
                          color: ColorsPalette.customGrey,
                          fontWeight: FontWeight.w500,
                          fontFamily: ZainTextStyles.font,
                          fontSize: 10.sp),
                      maxLines: 3,
                    ),
                  ),
                ],
              ),
            ],
          )),
    );
  }
}
