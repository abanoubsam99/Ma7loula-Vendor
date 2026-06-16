import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ma7lola_vendor/core/generated/locale_keys.g.dart';
import 'package:ma7lola_vendor/core/services/http/apis/miscellaneous_api.dart';
import 'package:ma7lola_vendor/core/utils/assets_manager.dart';
import 'package:ma7lola_vendor/core/utils/colors_palette.dart';
import 'package:ma7lola_vendor/core/widgets/custom_app_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../controller/user_provider.dart';
import '../../../../../../core/utils/font.dart';
import '../../../../../../core/utils/snackbars.dart';
import '../../../../../../core/utils/util_values.dart';
import '../../../../../../core/widgets/form_widgets/text_input_field.dart';
import '../../../../../../core/widgets/loading_widget.dart';
import '../../../../../../model/car_model_model.dart';
import '../../../../../../model/car_type_model.dart';
import '../../../../../../model/cars_list_model.dart';
import '../../../../../../model/tires_brand_model.dart';
import '../../../../../../model/years_model.dart';
import '../../../main_screen.dart';
import '../local_widgets/voltage_card.dart';

class AddTiresScreen extends StatefulWidget {
  static const String routeName = '/addtire';
  @override
  _AddTiresScreenState createState() => _AddTiresScreenState();
}

class _AddTiresScreenState extends State<AddTiresScreen> {
  final _formKey = GlobalKey<FormState>();
  var _price = TextEditingController();
  var _priceBeforeDisc = TextEditingController();
  var _productNo = TextEditingController();

  var _userNameController = TextEditingController();
  var _userMailController = TextEditingController();
  bool showSniper = false;

  bool _loading = false;
  bool _dloading = false;

  int? _isChangeDropDownBrands;
  int? _isChangeDropDownSizesWidth;
  int? _isChangeDropDownSizesHeight;
  int? _isChangeDropDownSizesLength;
  List<String>? tiresType = ['flat', 'normal'];
  // Updated width list with values from 110 to 230 in increments of 5
  List<int> widthList = [110, 115, 120, 125, 130, 135, 140, 145, 150, 155, 160, 165, 170, 175, 180, 185, 190, 195, 200, 205, 210, 215, 220, 225, 230];
  // Updated height list with specific aspect ratio values
  List<int> heightList = [30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85];
  // Updated length list to use rim sizes
  List<String> lengthList = ['R13', 'R14', 'R15', 'R16', 'R17', 'R18', 'R19', 'R20', 'R21', 'R22'];
  String? tt;

  bool _changeWidth = false;
  bool _changeBrand = false;
  int? selected;
  int? selectedUserCar;
  List<Cars> carIds = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarApp(
        title: LocaleKeys.addTire.tr(),
      ),
      bottomNavigationBar: _changePasswordButton(),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            decoration: BoxDecoration(
              color: ColorsPalette.lighttGrey,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UtilValues.gap16,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Center(
                        child: Text(
                          LocaleKeys.productPhoto.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: ColorsPalette.customGrey,
                              fontFamily: ZainTextStyles.font,
                              fontSize: 12.sp),
                        ),
                      ),
                    ),
                    UtilValues.gap4,
                    Center(
                      child: InkWell(
                        onTap: _captureImage,
                        child: Container(
                          height: 50,
                          width: 150,
                          decoration: BoxDecoration(
                              color: ColorsPalette.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: _images.isEmpty
                              ? Icon(Icons.camera_alt_outlined)
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: _images.map((img) => Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Image.file(
                                          img,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      )).toList(),
                                ),
                        ),
                      ),
                    ),
                    nameFormField(),
                    UtilValues.gap12,
                    skuFormField(),
                    UtilValues.gap12,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildDropDownBrands(),
                            UtilValues.gap12,
                            _typesWidget(),
                            Text(
                              LocaleKeys.sizeDetails.tr(),
                              style: TextStyle(
                                  color: ColorsPalette.black,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: ZainTextStyles.font,
                                  fontSize: 12.sp),
                            ),
                            UtilValues.gap2,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: buildDropDownWidth(),
                                ),
                                UtilValues.gap12,
                                Expanded(
                                  child: buildDropDownHeight(),
                                ),
                                UtilValues.gap12,
                                Expanded(
                                  child: buildDropDownLength(),
                                ),
                              ],
                            )
                          ]),
                    ),
                    UtilValues.gap12,
                    productsNoFormField(),
                    UtilValues.gap12,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        LocaleKeys.price.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: ColorsPalette.customGrey,
                            fontFamily: ZainTextStyles.font,
                            fontSize: 12.sp),
                      ),
                    ),
                    pricesFormField(),
                    UtilValues.gap12,
                    buildDropDownCarsTypesField(),
                    UtilValues.gap12,
                    if (carModels != null) buildDropDownCarsModelsField(),
                    UtilValues.gap12,
                    buildDropDownAllCarsField(),
                    UtilValues.gap12,
                    if (carIds.isNotEmpty)
                      Container(
                          decoration: BoxDecoration(
                              color: ColorsPalette.white,
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: carIds
                                .map((car) => Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: ColorsPalette.lighttGrey,
                                          ),
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Text(
                                                '${car.model?.brand?.name} ${car.year} - ${car.engine}',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: ColorsPalette
                                                        .customGrey,
                                                    fontFamily:
                                                        ZainTextStyles.font,
                                                    fontSize: 12.sp),
                                              ),
                                              Spacer(),
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    carIds.remove(car);
                                                  });
                                                },
                                                child: SvgPicture.asset(
                                                  AssetsManager.delete,
                                                  color: ColorsPalette
                                                      .primaryColor,
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
                    UtilValues.gap32,
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  void changePassword() async {
    try {
      final formState = _formKey.currentState ?? _formKey.currentState;
      if (formState!.validate() &&
          _isChangeDropDownBrands != null &&
          tt != null &&
          _isChangeDropDownSizesWidth != null &&
          _isChangeDropDownSizesHeight != null &&
          _isChangeDropDownSizesLength != null &&
          _images.isNotEmpty &&
          carIds.isNotEmpty &&
          isChangeDropDownCarsType != null &&
          isChangeDropDownCarsEng != null &&
          isChangeDropDownCarsModel != null &&
          isChangeDropDownCars1 != null &&
          _uploadedImages.isNotEmpty) {
        setState(() {
          _dloading = true;
        });
        await MiscellaneousApi.addTire(
          description: _userMailController.text,
          sku: _userMailController.text,
          name: _userNameController.text,
          tireType: tt ?? '',
          brandId: _isChangeDropDownBrands ?? 0,
          stock: int.parse(_productNo.text),
          price: int.parse(_price.text),
          priceBeforeDiscount: int.parse(_priceBeforeDisc.text),
          yearManufacture: isChangeDropDownCars1 ?? 0,
          height: _isChangeDropDownSizesHeight ?? 0,
          width: _isChangeDropDownSizesWidth ?? 0,
          length: _isChangeDropDownSizesLength ?? 0,
          carIds: carIds.map((e) => e.id ?? 0).toSet().toList(),
          images: _uploadedImages,
          locale: context.locale,
        );
        showSnackbar(
          context: context,
          status: SnackbarStatus.success,
          message: LocaleKeys.done.tr(),
        );
        setState(() => _dloading = true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MainScreen(
                    index: 1,
                  )),
        );
      } else {
        showSnackbar(
          context: context,
          status: SnackbarStatus.error,
          message: LocaleKeys.pleaseSelectAllOptions.tr(),
        );
      }
    } catch (e) {
      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: e.toString(),
      );
      setState(() => _dloading = false);
    } finally {
      setState(() => _dloading = false);
    }
  }

  _changePasswordButton() {
    return Container(
      // padding: EdgeInsets.symmetric(vertical: 2.h),
      margin: EdgeInsets.all(10.sp),
      height: 6.h,
      child: ElevatedButton(
        onPressed: changePassword,
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
          child: _dloading
              ? const LoadingWidget(
                  color: ColorsPalette.white,
                )
              : Text(
                  LocaleKeys.addTire.tr(),
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

  Widget nameFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.name.tr(),
          style: TextStyle(
              color: ColorsPalette.black,
              fontWeight: FontWeight.w400,
              fontFamily: ZainTextStyles.font,
              fontSize: 14.sp),
        ),
        TextInputField(
          padding: EdgeInsets.all(11.sp),
          focusedBorder: OutlineInputBorder(
            borderRadius: UtilValues.borderRadius10,
            borderSide:
                const BorderSide(color: ColorsPalette.extraDarkGrey, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: UtilValues.borderRadius10,
            borderSide:
                BorderSide(color: ColorsPalette.extraDarkGrey, width: 1),
          ),
          color: ColorsPalette.darkGrey,
          backgroundColor: ColorsPalette.white,
          controller: _userNameController,
          inputType: TextInputType.text,
          name: LocaleKeys.name.tr(),
          key: const ValueKey('name'),
          hint: LocaleKeys.name.tr(),
          validator: FormBuilderValidators.required(),
        ),
      ],
    );
  }

  Widget skuFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SKU',
          style: TextStyle(
              color: ColorsPalette.black,
              fontWeight: FontWeight.w400,
              fontFamily: ZainTextStyles.font,
              fontSize: 14.sp),
        ),
        TextInputField(
          padding: EdgeInsets.all(11.sp),
          focusedBorder: OutlineInputBorder(
            borderRadius: UtilValues.borderRadius10,
            borderSide:
                const BorderSide(color: ColorsPalette.extraDarkGrey, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: UtilValues.borderRadius10,
            borderSide:
                BorderSide(color: ColorsPalette.extraDarkGrey, width: 1),
          ),
          color: ColorsPalette.darkGrey,
          backgroundColor: ColorsPalette.white,
          controller: _userMailController,
          inputType: TextInputType.text,
          name: LocaleKeys.mail.tr(),
          key: const ValueKey('sku'),
          hint: LocaleKeys.sku.tr(),
          validator: FormBuilderValidators.required(),
        ),
      ],
    );
  }

  Widget pricesFormField() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextInputField(
              padding: EdgeInsets.all(10.sp),
              focusedBorder: OutlineInputBorder(
                borderRadius: UtilValues.borderRadius10,
                borderSide: const BorderSide(
                    color: ColorsPalette.extraDarkGrey, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: UtilValues.borderRadius10,
                borderSide:
                    BorderSide(color: ColorsPalette.extraDarkGrey, width: 1),
              ),
              color: ColorsPalette.darkGrey,
              backgroundColor: ColorsPalette.white,
              controller: _price,
              inputType: TextInputType.number,
              name: LocaleKeys.name.tr(),
              key: const ValueKey('price'),
              hint: LocaleKeys.price.tr(),
              validator: FormBuilderValidators.required(),
            ),
          ),
          UtilValues.gap2,
          Expanded(
            child: TextInputField(
              padding: EdgeInsets.all(10.sp),
              focusedBorder: OutlineInputBorder(
                borderRadius: UtilValues.borderRadius10,
                borderSide: const BorderSide(
                    color: ColorsPalette.extraDarkGrey, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: UtilValues.borderRadius10,
                borderSide:
                    BorderSide(color: ColorsPalette.extraDarkGrey, width: 1),
              ),
              color: ColorsPalette.darkGrey,
              backgroundColor: ColorsPalette.white,
              controller: _priceBeforeDisc,
              inputType: TextInputType.number,
              name: LocaleKeys.name.tr(),
              key: const ValueKey('priceBe'),
              hint: LocaleKeys.priceBe.tr(),
              validator: FormBuilderValidators.required(),
            ),
          ),
        ],
      ),
    );
  }

  Widget productsNoFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.productsNo.tr(),
          style: TextStyle(
              color: ColorsPalette.black,
              fontWeight: FontWeight.w400,
              fontFamily: ZainTextStyles.font,
              fontSize: 14.sp),
        ),
        TextInputField(
          padding: EdgeInsets.all(11.sp),
          focusedBorder: OutlineInputBorder(
            borderRadius: UtilValues.borderRadius10,
            borderSide:
                const BorderSide(color: ColorsPalette.extraDarkGrey, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: UtilValues.borderRadius10,
            borderSide:
                BorderSide(color: ColorsPalette.extraDarkGrey, width: 1),
          ),
          color: ColorsPalette.darkGrey,
          backgroundColor: ColorsPalette.white,
          controller: _productNo,
          inputType: TextInputType.number,
          name: LocaleKeys.productsNo.tr(),
          key: const ValueKey('productsNo'),
          hint: LocaleKeys.productsNo.tr(),
          validator: FormBuilderValidators.required(),
        ),
      ],
    );
  }

  List<String> tiresTypes = ['flat', 'normal'];

  _typesWidget() {
    return SizedBox(
      height: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.choose.tr(),
            style: TextStyle(
                color: ColorsPalette.black,
                fontWeight: FontWeight.w400,
                fontFamily: ZainTextStyles.font,
                fontSize: 12.sp),
          ),
          UtilValues.gap2,
          Expanded(
            child: ListView.separated(
                separatorBuilder: (context, index) {
                  return UtilValues.gap4;
                },
                shrinkWrap: true,
                itemCount: tiresTypes.length,
                itemBuilder: (context, index) {
                  final name = tiresTypes[index];
                  return _types(name, name);
                  return SizedBox.shrink();
                }),
          ),
        ],
      ),
    );
  }

  // _volWidget() {
  //   return SizedBox(
  //     height: 150,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       mainAxisAlignment: MainAxisAlignment.start,
  //       children: [
  //         Text(
  //           LocaleKeys.choose.tr(),
  //           style: TextStyle(
  //               color: ColorsPalette.black,
  //               fontWeight: FontWeight.w400,
  //               fontFamily: ZainTextStyles.font,
  //               fontSize: 12.sp),
  //         ),
  //         UtilValues.gap2,
  //         Expanded(
  //           child: ListView.separated(
  //               separatorBuilder: (context, index) {
  //                 return UtilValues.gap4;
  //               },
  //               shrinkWrap: true,
  //               itemCount: tiresType != null ? (tiresType?.length ?? 0) : 0,
  //               itemBuilder: (context, index) {
  //                 final name = tiresType?[index];
  //                 if (tiresType != null) {
  //                   return _types(name, name);
  //                 }
  //                 return SizedBox.shrink();
  //               }),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  _types(String? name, String? value) {
    return CardVoltages(
      name: name ?? '',
      value: value,
      selectedValue: tt,
      onChanged: _onType,
    );
  }

  void _onType(String? type) async {
    setState(() {
      tt = type;
    });
    setState(() {});
  }

  Widget buildDropDownBrands() {
    return FutureBuilder<TiresBrandsModel>(
      future: MiscellaneousApi.getTiresBrands(
        locale: context.locale,
      ),
      builder: (context, brand) {
        if (brand.data != null &&
            (brand.data?.data?.brands?.isNotEmpty ?? false)) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.tireBrand.tr(),
                style: TextStyle(
                    color: ColorsPalette.black,
                    fontWeight: FontWeight.w400,
                    fontFamily: ZainTextStyles.font,
                    fontSize: 12.sp),
              ),
              UtilValues.gap2,
              Container(
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonFormField<int>(
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
                    color: _changeBrand
                        ? ColorsPalette.primaryColor
                        : ColorsPalette.darkGrey,
                  ),
                  alignment: Alignment.center,
                  hint: Text(
                    LocaleKeys.choseBrand.tr(),
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
                  value: _isChangeDropDownBrands,
                  onChanged: (int? newValue) async {
                    _isChangeDropDownBrands = newValue!;
                    _changeBrand = true;
                    setState(() {});
                  },
                  items: brand.data?.data?.brands?.map((Brands tireBrands) {
                        return DropdownMenuItem<int>(
                          value: tireBrands.id,
                          child: Text(
                            tireBrands.name ?? 'Unknown',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ColorsPalette.black,
                              fontSize: 12.sp,
                              fontFamily: ZainTextStyles.font,
                            ),
                          ),
                        );
                      }).toList() ??
                      [],
                ),
              ),
            ],
          );
        }
        return SizedBox.shrink();
      },
    );
  }

  Widget buildDropDownWidth() {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonFormField<int>(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: ColorsPalette.primaryColor),
          ),
        ),
        dropdownColor: Colors.white,
        icon: SvgPicture.asset(
          'assets/images/expanded.svg',
          fit: BoxFit.scaleDown,
          width: 1.w,
          height: .8.h,
          color: _changeWidth
              ? ColorsPalette.primaryColor
              : ColorsPalette.darkGrey,
        ),
        alignment: Alignment.center,
        hint: Text(
          LocaleKeys.width.tr(),
          style: TextStyle(
            fontSize: 10.sp,
            color: _changeWidth ? ColorsPalette.black : ColorsPalette.darkGrey,
            fontFamily: ZainTextStyles.font,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: const TextStyle(
          fontFamily: ZainTextStyles.font,
          color: ColorsPalette.black,
        ),
        value: _isChangeDropDownSizesWidth,
        onChanged: (int? newValue) async {
          _isChangeDropDownSizesWidth = newValue!;
          _changeWidth = true;
          setState(() {});
        },
        items: widthList.map((int width) {
              return DropdownMenuItem<int>(
                value: width,
                child: Text(
                  '$width',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ColorsPalette.black,
                    fontSize: 12.sp,
                    fontFamily: ZainTextStyles.font,
                  ),
                ),
              );
            }).toList() ??
            [],
      ),
    );
  }

  Widget buildDropDownHeight() {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonFormField<int>(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: ColorsPalette.primaryColor),
          ),
        ),
        dropdownColor: Colors.white,
        icon: SvgPicture.asset(
          'assets/images/expanded.svg',
          fit: BoxFit.scaleDown,
          width: 1.w,
          height: .8.h,
          color: _changeWidth
              ? ColorsPalette.primaryColor
              : ColorsPalette.darkGrey,
        ),
        alignment: Alignment.center,
        hint: Text(
          LocaleKeys.height.tr(),
          style: TextStyle(
            fontSize: 10.sp,
            color: _changeWidth ? ColorsPalette.black : ColorsPalette.darkGrey,
            fontFamily: ZainTextStyles.font,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: const TextStyle(
          fontFamily: ZainTextStyles.font,
          color: ColorsPalette.black,
        ),
        value: _isChangeDropDownSizesHeight,
        onChanged: (int? newValue) async {
          _isChangeDropDownSizesHeight = newValue;
          _changeWidth = true;
          setState(() {});
        },
        items: heightList.map((int height) {
              return DropdownMenuItem<int>(
                value: height,
                child: Text(
                  '$height',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ColorsPalette.black,
                    fontSize: 12.sp,
                    fontFamily: ZainTextStyles.font,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget buildDropDownLength() {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: ColorsPalette.primaryColor),
          ),
        ),
        dropdownColor: Colors.white,
        icon: SvgPicture.asset(
          'assets/images/expanded.svg',
          fit: BoxFit.scaleDown,
          width: 1.w,
          height: .8.h,
          color: _changeWidth
              ? ColorsPalette.primaryColor
              : ColorsPalette.darkGrey,
        ),
        alignment: Alignment.center,
        hint: Text(
          LocaleKeys.length.tr(),
          style: TextStyle(
            fontSize: 10.sp,
            color: _changeWidth ? ColorsPalette.black : ColorsPalette.darkGrey,
            fontFamily: ZainTextStyles.font,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: const TextStyle(
          fontFamily: ZainTextStyles.font,
          color: ColorsPalette.black,
        ),
        value: _isChangeDropDownSizesLength != null ? lengthList[_isChangeDropDownSizesLength! - 13] : null,
        onChanged: (String? newValue) async {
          if (newValue != null) {
            // Extract the number from the rim size (e.g., 'R13' -> 13)
            _isChangeDropDownSizesLength = int.parse(newValue.substring(1));
            _changeWidth = true;
            setState(() {});
          }
        },
        items: lengthList.map((String rimSize) {
              return DropdownMenuItem<String>(
                value: rimSize,
                child: Text(
                  rimSize,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ColorsPalette.black,
                    fontSize: 12.sp,
                    fontFamily: ZainTextStyles.font,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget buildDropDownCarsTypesField() {
    return FutureBuilder<CarTypeModel>(
      future: MiscellaneousApi.getCarsType(locale: context.locale),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return const LoadingWidget();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final carBrands = snapshot.data?.data?.carBrands;

        // Check if carBrands is null or empty
        if (carBrands == null || carBrands.isEmpty) {
          return Text('No car brands available');
        }

        return Container(
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonFormField<int>(
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
                color: change
                    ? ColorsPalette.primaryColor
                    : ColorsPalette.darkGrey,
              ),
              alignment: Alignment.center,
              hint: Text(
                LocaleKeys.carType.tr(),
                style: TextStyle(
                  fontSize: 10.sp,
                  color: change ? ColorsPalette.black : ColorsPalette.darkGrey,
                  fontFamily: ZainTextStyles.font,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: const TextStyle(
                fontFamily: ZainTextStyles.font,
                color: ColorsPalette.black,
              ),
              value: isChangeDropDownCarsType,
              onChanged: (int? newValue) async {
                try {
                  setState(() {
                    change = true;
                    changeModel = true;
                    changeCar = true;
                  });
                  isChangeDropDownCarsType = newValue;
                  isChangeDropDownCarsModel = null;
                  isChangeDropDownCarsEng = null;
                  carModels = await MiscellaneousApi.getCarsModel(
                      locale: context.locale, carBrandId: newValue!);
                  setState(() {
                    change = false;
                    changeModel = false;
                    changeCar = false;
                  });
                } catch (e) {
                } finally {
                  setState(() {
                    change = false;
                    changeModel = false;
                    changeCar = false;
                  });
                }
              },
              items: carBrands.map((CarBrands carsType) {
                return DropdownMenuItem<int>(
                  value: carsType.id,
                  child: Text(
                    carsType.name ?? 'Unknown',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ColorsPalette.black,
                      fontSize: 14.sp,
                      fontFamily: ZainTextStyles.font,
                    ),
                  ),
                );
              }).toList(),
            ));
      },
    );
  }

  Widget buildDropDownCarsModelsField() {
    return Builder(builder: (context) {
      if (carModels != null && !change) {
        return Container(
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonFormField<int>(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: ColorsPalette.primaryColor),
              ),
            ),
            dropdownColor: Colors.white,
            icon: SvgPicture.asset(
              'assets/images/expanded.svg',
              fit: BoxFit.scaleDown,
              width: 1.w,
              height: .8.h,
              color: changeModel
                  ? ColorsPalette.primaryColor
                  : ColorsPalette.darkGrey,
            ),
            alignment: Alignment.center,
            hint: Text(
              LocaleKeys.carModel.tr(),
              style: TextStyle(
                fontSize: 10.sp,
                color:
                    changeModel ? ColorsPalette.black : ColorsPalette.darkGrey,
                fontFamily: ZainTextStyles.font,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: const TextStyle(
              fontFamily: ZainTextStyles.font,
              color: ColorsPalette.black,
            ),
            value: isChangeDropDownCarsModel,
            onChanged: (int? newValue) async {
              try {
                setState(() {
                  change = true;
                  changeModel = true;
                  changeCar = true;
                });
                isChangeDropDownCarsModel = newValue;
                yearsList = await MiscellaneousApi.getYears(
                    locale: context.locale,
                    carTypeId: isChangeDropDownCarsType!,
                    carModelId: newValue!);
                setState(() {
                  change = false;
                  changeModel = false;
                  changeCar = false;
                });
              } catch (e) {
              } finally {
                setState(() {
                  change = false;
                  changeModel = false;
                  changeCar = false;
                });
              }
            },
            items: carModels != null
                ? carModels?.data?.carModels?.map((CarModels carModels) {
                    return DropdownMenuItem<int>(
                      value: carModels.id,
                      child: Text(
                        carModels.name ?? 'Unknown',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ColorsPalette.black,
                          fontSize: 14.sp,
                          fontFamily: ZainTextStyles.font,
                        ),
                      ),
                    );
                  }).toList()
                : [],
          ),
        );
      } else {
        return SizedBox.shrink();
      }
    });
  }

  Widget buildDropDownAllCarsEng() {
    return Builder(builder: (context) {
      if (allCarsList != null &&
          !changeModel &&
          carModels != null &&
          !change &&
          !changeModel) {
        return Container(
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonFormField<Cars>(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: ColorsPalette.primaryColor),
              ),
            ),
            dropdownColor: Colors.white,
            icon: SvgPicture.asset(
              'assets/images/expanded.svg',
              fit: BoxFit.scaleDown,
              width: 1.w,
              height: .8.h,
              color: changeCar
                  ? ColorsPalette.primaryColor
                  : ColorsPalette.darkGrey,
            ),
            alignment: Alignment.center,
            hint: Text(
              LocaleKeys.engine.tr(),
              style: TextStyle(
                fontSize: 10.sp,
                color: changeCar ? ColorsPalette.black : ColorsPalette.darkGrey,
                fontFamily: ZainTextStyles.font,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: const TextStyle(
              fontFamily: ZainTextStyles.font,
              color: ColorsPalette.black,
            ),
            value: isChangeDropDownCarsEng,
            onChanged: (Cars? newValue) {
              setState(() {
                carIds.add(newValue!);
                isChangeDropDownCarsEng = newValue;
              });
            },
            items: (allCarsList != null)
                ? allCarsList?.data?.cars?.map((Cars cars) {
                    return DropdownMenuItem<Cars>(
                      value: cars,
                      child: Text(
                        '${cars.model?.brand?.name} ${cars.year} - ${cars.engine}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ColorsPalette.black,
                          fontSize: 14.sp,
                          fontFamily: ZainTextStyles.font,
                        ),
                      ),
                    );
                  }).toList()
                : [],
          ),
        );
      } else {
        return SizedBox.shrink();
      }
    });
  }

  ///
  bool change = false;
  bool changeModel = false;
  bool changeCar = false;
  CarModelModel? carModels;
  CarsListModel? allCarsList;
  YearsModel? yearsList;
  int? isChangeDropDownCarsType;
  int? isChangeDropDownCarsModel;
  int? isChangeDropDownCars1;
  Cars? isChangeDropDownCarsEng;

  Widget buildDropDownAllCarsField() {
    return Builder(builder: (context) {
      if (yearsList != null && !changeModel && carModels != null && !change) {
        return Container(
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonFormField<int>(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: ColorsPalette.primaryColor),
              ),
            ),
            dropdownColor: Colors.white,
            icon: SvgPicture.asset(
              'assets/images/expanded.svg',
              fit: BoxFit.scaleDown,
              width: 1.w,
              height: .8.h,
              color: changeModel
                  ? ColorsPalette.primaryColor
                  : ColorsPalette.darkGrey,
            ),
            alignment: Alignment.center,
            hint: Text(
              LocaleKeys.choose.tr(),
              style: TextStyle(
                fontSize: 10.sp,
                color:
                    changeModel ? ColorsPalette.black : ColorsPalette.darkGrey,
                fontFamily: ZainTextStyles.font,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: const TextStyle(
              fontFamily: ZainTextStyles.font,
              color: ColorsPalette.black,
            ),
            value: isChangeDropDownCars1,
            onChanged: (int? newValue) async {
              try {
                setState(() {
                  changeModel = true;
                });
                isChangeDropDownCars1 = newValue;
                allCarsList = await MiscellaneousApi.getCars(
                    locale: context.locale,
                    carTypeId: isChangeDropDownCarsType!,
                    carModelId: isChangeDropDownCarsModel!,
                    year: newValue!);
                setState(() {
                  changeModel = false;
                });
              } catch (e) {
              } finally {
                setState(() {
                  changeModel = false;
                });
              }
            },
            items: yearsList != null
                ? yearsList?.data?.years?.map((String year) {
                    return DropdownMenuItem<int>(
                      value: int.tryParse(year),
                      child: Text(
                        year,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ColorsPalette.black,
                          fontSize: 14.sp,
                          fontFamily: ZainTextStyles.font,
                        ),
                      ),
                    );
                  }).toList()
                : [],
          ),
        );
      } else {
        return SizedBox.shrink();
      }
    });
  }

  List<File> _images = [];
List<String> _uploadedImages = [];

  final ImagePicker _picker = ImagePicker();

  Future<void> _checkPermission() async {
    final status = await Permission.camera.status;
    if (status.isDenied) {
      await Permission.camera.request();
    }
  }

  Future<void> _captureImage() async {
  final status = await Permission.storage.status;
  if (status.isDenied) {
    await Permission.storage.request();
  }

  try {
    final List<XFile>? images = await _picker.pickMultiImage(imageQuality: 100);
    if (images != null && images.isNotEmpty) {
      setState(() {
        _images = images.map((x) => File(x.path)).toList();
        _loading = true;
      });
      // Optionally compress images before upload
      List<File> compressedImages = [];
      for (var img in _images) {
        final compressed = await ImageCompressor.compressImage(img);
        compressedImages.add(compressed);
      }
      // Upload each image and collect their URLs or filenames
      _uploadedImages = [];
      for (final img in compressedImages) {
        final d = await MiscellaneousApi.uploadImage(image: img, locale: context.locale);
        if (d.data?.images?.isNotEmpty ?? false) {
          _uploadedImages.add(d.data!.images!.first.filename ?? '');
        }
      }
      setState(() {
        _loading = false;
      });
      showSnackbar(
        context: context,
        status: SnackbarStatus.success,
        message: LocaleKeys.done.tr(),
      );
    }
  } catch (e) {
    print('خطأ في اختيار الصورة: $e');
    showSnackbar(
      context: context,
      status: SnackbarStatus.error,
      message: e.toString(),
    );
    setState(() => _loading = false);
  }
}
}
