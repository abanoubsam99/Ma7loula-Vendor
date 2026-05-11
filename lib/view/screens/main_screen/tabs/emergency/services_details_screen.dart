import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ma7lola_vendor/core/generated/locale_keys.g.dart';
import 'package:ma7lola_vendor/core/services/http/apis/miscellaneous_api.dart';
import 'package:ma7lola_vendor/core/widgets/custom_app_bar.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/utils/assets_manager.dart';
import '../../../../../core/utils/colors_palette.dart';
import '../../../../../core/utils/font.dart';
import '../../../../../core/utils/snackbars.dart';
import '../../../../../core/utils/util_values.dart';
import '../../../../../core/widgets/form_widgets/primary_button/simple_primary_button.dart';
import '../../../../../model/emergency/services_model.dart';
import 'emergency_order_details_screen.dart';

class ServicesDetailsScreen extends StatefulWidget {
  ServicesDetailsScreen(
      {super.key,
      required this.car,
      required this.orderNum,
      required this.vendorName,
      required this.vendorNum});

  final String car;
  final int orderNum;
  final String vendorName;
  final String vendorNum;
  @override
  State<ServicesDetailsScreen> createState() => _ServicesDetailsScreenState();
}

class _ServicesDetailsScreenState extends State<ServicesDetailsScreen> {
  List<Services> servicesIds = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.grey,
      appBar: AppBarApp(
        title: LocaleKeys.servicesDetails.tr(),
      ),
      body: SingleChildScrollView(
        child: Column(
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
                    widget.car,
                    style: TextStyle(
                        color: ColorsPalette.black,
                        fontWeight: FontWeight.w400,
                        fontFamily: ZainTextStyles.font,
                        fontSize: 12.sp),
                  ),
                ],
              ),
            ),
            if (servicesIds.isNotEmpty)
              Container(
                  decoration: BoxDecoration(
                      color: ColorsPalette.white,
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: servicesIds
                        .map((service) => Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: ColorsPalette.lighttGrey,
                                  ),
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${service.name}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: ColorsPalette.customGrey,
                                            fontFamily: ZainTextStyles.font,
                                            fontSize: 12.sp),
                                      ),
                                      Spacer(),
                                      Text(
                                        '${service.price} ${LocaleKeys.le.tr()}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: ColorsPalette.customGrey,
                                            fontFamily: ZainTextStyles.font,
                                            fontSize: 12.sp),
                                      ),
                                      UtilValues.gap12,
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            servicesIds.remove(service);
                                          });
                                        },
                                        child: SvgPicture.asset(
                                          AssetsManager.delete,
                                          color: ColorsPalette.primaryColor,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                UtilValues.gap4
                              ],
                            ))
                        .toSet()
                        .toList(),
                  )),
            UtilValues.gap8,
            buildDropDownAllCarsEng(),
            UtilValues.gap12,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SimplePrimaryButton(
                borderRadius: BorderRadius.circular(5),
                label: LocaleKeys.save.tr(),
                backgroundColor: servicesIds.isNotEmpty
                    ? ColorsPalette.primaryColor
                    : ColorsPalette.primaryColor.withOpacity(.4),
                onPressed: servicesIds.isNotEmpty ? acceptOrder : () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  void acceptOrder() async {
    try {
      if (servicesIds.isNotEmpty) {
        List<Map<String, int>> serviceIdsList =
            servicesIds.map((service) => {'id': service.id ?? 0}).toList();

        await MiscellaneousApi.updateServiceEmergency(
            locale: context.locale,
            orderId: widget.orderNum,
            services: serviceIdsList);

        await MiscellaneousApi.updateOrderStatusEmergency(
          locale: context.locale,
          orderId: widget.orderNum,
        );

        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return EmergencyOrderDetails(
            orderNum: widget.orderNum,
            vendorName: widget.vendorName,
            vendorNum: widget.vendorNum,
          );
        }));

        showSnackbar(
          context: context,
          status: SnackbarStatus.success,
          message: LocaleKeys.done.tr(),
        );
      }

      // Navigator.pop(context);
    } catch (e) {
      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: e.toString(),
      );
    }
  }

  Widget buildDropDownAllCarsEng() {
    return FutureBuilder(
        future: MiscellaneousApi.listServicesEmergency(locale: context.locale),
        builder: (context, snapshot) {
          if (snapshot.data == null) return const SizedBox.shrink();
          if (snapshot.data?.data == null) return const SizedBox.shrink();

          final services = snapshot.data?.data?.services ?? [];
          if ((services.isEmpty)) {
            return const SizedBox.shrink();
          }
          Services? isChangeDropDownCarsEng =
              services.isNotEmpty ? services.first : null;

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonFormField<Services>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: ColorsPalette.primaryColor),
                  ),
                ),
                dropdownColor: Colors.white,
                icon: SvgPicture.asset(
                  'assets/images/expanded.svg',
                  fit: BoxFit.scaleDown,
                  width: 1.w,
                  height: .8.h,
                  color: ColorsPalette.black,
                ),
                alignment: Alignment.center,
                hint: Text(
                  LocaleKeys.choose.tr(),
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: ColorsPalette.black,
                    fontFamily: ZainTextStyles.font,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: const TextStyle(
                  fontFamily: ZainTextStyles.font,
                  color: ColorsPalette.black,
                ),
                value: isChangeDropDownCarsEng,
                onChanged: (Services? newValue) {
                  setState(() {
                    servicesIds.add(newValue!);
                    isChangeDropDownCarsEng = newValue;
                  });
                },
                items: services.isNotEmpty
                    ? services.map((Services services) {
                        return DropdownMenuItem<Services>(
                          value: services,
                          child: Text(
                            '${services.name}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ColorsPalette.black,
                              fontSize: 14.sp,
                              fontFamily: ZainTextStyles.font,
                            ),
                          ),
                        );
                      }).toList()
                    : []),
          );
        });
  }
}
