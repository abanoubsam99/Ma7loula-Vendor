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

import '../../../../../../../controller/user_provider.dart';
import '../../../../../../../core/utils/font.dart';
import '../../../../../../../core/utils/snackbars.dart';
import '../../../../../../../core/utils/util_values.dart';
import '../../../../../../../core/widgets/form_widgets/text_input_field.dart';
import '../../../../../../../core/widgets/loading_widget.dart';
import '../../../../../../../model/car_model_model.dart';
import '../../../../../../../model/car_parts_model.dart';
import '../../../../../../../model/car_type_model.dart';
import '../../../../../../../model/cars_list_model.dart';
import '../../../../../../../model/tires_size_model.dart';
import '../../../../../../../model/years_model.dart';
import '../../../../main_screen.dart';
import '../local_widgets/voltage_card.dart';

class AddCarPartScreen extends StatefulWidget {
  static const String routeName = '/addcarpart';
  @override
  _AddCarPartScreenState createState() => _AddCarPartScreenState();
}

class _AddCarPartScreenState extends State<AddCarPartScreen> {
  final _formKey = GlobalKey<FormState>();
  var _price = TextEditingController();
  var _priceBeforeDisc = TextEditingController();
  var _productNo = TextEditingController();

  var _userNameController = TextEditingController();
  var _userMailController = TextEditingController();
  var _descriptionController = TextEditingController();
  bool showSniper = false;

  bool _loading = false;
  bool _loadings = false;

  String? _isChangeDropDownSizesWidth;
  List<String>? tiresType = ['pending', 'published'];
  List<TireSizes>? tiresSizes;
  String? _tup2;

  bool _changeWidth = false;
  bool _changeBrand = false;
  int? selected;
  int? selectedUserCar;
  List<Cars> carIds = [];

  @override
  void initState() {
    super.initState();
    // Add debug print when screen initializes
    print('\n\n========================');
    print('ADD CAR PART SCREEN INITIALIZED');
    print('Initial selected value: $selected');
    print('========================\n\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarApp(
        title: LocaleKeys.addCarParts.tr(),
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
                          child: idImg.isEmpty
                              ? Icon(Icons.camera_alt_outlined)
                              : Image.file(
                                  _image!,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                    nameFormField(),
                    UtilValues.gap12,
                    skuFormField(),
                    UtilValues.gap16,
                    pricesFormField(),
                    UtilValues.gap16,
                    productsNoFormField(),
                    UtilValues.gap12,
                    // Description field
                    descriptionFormField(),
                    UtilValues.gap12,
                    // Category dropdown
                    buildDropDownCategoriesField(),
                    UtilValues.gap12,
                    buildDropDownCarsTypesField(),
                    UtilValues.gap12,
                    if (carModels != null) buildDropDownCarsModelsField(),
                    UtilValues.gap12,
                    buildDropDownAllCarsField(),
                    UtilValues.gap12,
                    buildDropDownAllCarsEng(),
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
      
      // Debug what's missing
      print('\n\n===== VALIDATION DEBUG =====');
      print('Form validates: ${formState!.validate()}');
      print('Image uploaded: ${idImg.isNotEmpty}');
      print('Car IDs not empty: ${carIds.isNotEmpty}');
      print('Car Type selected: ${isChangeDropDownCarsType != null}');
      print('Car Engine selected: ${isChangeDropDownCarsEng != null}');
      print('Car Model selected: ${isChangeDropDownCarsModel != null}');
      print('Category selected: ${isChangeDropDownCategory != null}');
      print('============================\n\n');
      
      if (formState.validate() &&
          idImg.isNotEmpty &&
          carIds.isNotEmpty &&
          isChangeDropDownCarsType != null &&
          isChangeDropDownCarsEng != null &&
          isChangeDropDownCarsModel != null &&
          isChangeDropDownCategory != null) {
        
        setState(() => _loadings = true);
        // Debug print car IDs before submission
        final uniqueCarIds = carIds.map((e) => e.id ?? 0).toSet().toList();
        print('\n\n======== DEBUG FORM SUBMISSION ========');
        print('Submitting form with car IDs: $uniqueCarIds');
        print('Original car list before unique: ${carIds.map((e) => e.id).toList()}');
        print('Car count before unique: ${carIds.length}, after unique: ${uniqueCarIds.length}');
        print('Selected variable value: $selected');
        print('isChangeDropDownCarsType value: $isChangeDropDownCarsType');
        print('isChangeDropDownCarsModel value: $isChangeDropDownCarsModel');
        print('isChangeDropDownCarsEng value: ${isChangeDropDownCarsEng?.id}');
        print('========================================\n\n');
        
        await MiscellaneousApi.addCarParts(
          name: _userNameController.text,
          locale: context.locale,
          description: _descriptionController.text,
          sku: _userMailController.text,
          brandId: 1,
          status: 'pending', // Always save as pending
          stock: int.tryParse(_productNo.text) ?? 0,
          price: int.tryParse(_price.text) ?? 0,
          priceBeforeDiscount: int.tryParse(_priceBeforeDisc.text) ?? 0,
          carIds: uniqueCarIds,
          images: [idImg],
          categoryId: isChangeDropDownCategory ?? 3,
        );
        showSnackbar(
          context: context,
          status: SnackbarStatus.success,
          message: LocaleKeys.done.tr(),
        );
        setState(() => _loadings = true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MainScreen(
                    index: 1,
                  )),
        );
      } else {
        // Check which conditions are failing and provide specific error messages
        if (!formState.validate()) {
          showSnackbar(
            context: context,
            status: SnackbarStatus.error,
            message: 'Please complete all required fields',
          );
        } else if (idImg.isEmpty) {
          showSnackbar(
            context: context,
            status: SnackbarStatus.error,
            message: 'Please add a product photo',
          );
        } else if (carIds.isEmpty) {
          showSnackbar(
            context: context,
            status: SnackbarStatus.error,
            message: 'Please select at least one car',
          );
        } else {
          showSnackbar(
            context: context,
            status: SnackbarStatus.error,
            message: LocaleKeys.pleaseSelectAllOptions.tr(),
          );
        }
      }
    } catch (e) {
      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: e.toString(),
      );
      setState(() => _loadings = false);
    } finally {
      setState(() => _loadings = false);
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
          child: _loadings
              ? const LoadingWidget(
                  color: ColorsPalette.white,
                )
              : Text(
                  LocaleKeys.addCarParts.tr(),
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
          inputType: TextInputType.name,
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
          inputType: TextInputType.name,
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
          UtilValues.gap8,
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

  // Description form field
  descriptionFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.locale.languageCode == 'en' ? 'Description' : 'الوصف',
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
          controller: _descriptionController,
          inputType: TextInputType.multiline,
          maxLines: 3,
          name: context.locale.languageCode == 'en' ? 'Description' : 'الوصف',
          key: const ValueKey('description'),
          hint: context.locale.languageCode == 'en' ? 'Enter product description' : 'أدخل وصف المنتج',
          validator: FormBuilderValidators.required(),
        ),
      ],
    );
  }

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
                itemCount: tiresType != null ? (tiresType?.length ?? 0) : 0,
                itemBuilder: (context, index) {
                  final name = tiresType?[index];
                  if (tiresType != null) {
                    return _vol(name, name);
                  }
                  return SizedBox.shrink();
                }),
          ),
        ],
      ),
    );
  }

  _vol(String? name, String? value) {
    return CardVoltages(
      name: name ?? '',
      value: value,
      selectedValue: _tup2,
      onChanged: _onType2,
    );
  }

  void _onType2(String? type) async {
    setState(() {
      _tup2 = type;
    });
  }

  Widget buildDropDownWidth() {
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
        onChanged: (String? newValue) async {
          _isChangeDropDownSizesWidth = newValue!;
          _changeWidth = true;
          setState(() {});
        },
        items: tiresSizes != null
            ? tiresSizes?.map((TireSizes tireSize) {
                  return DropdownMenuItem<String>(
                    value:
                        '${tireSize.width}_${tireSize.height}_${tireSize.length}',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${tireSize.width}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ColorsPalette.black,
                            fontSize: 12.sp,
                            fontFamily: ZainTextStyles.font,
                          ),
                        ),
                        UtilValues.gap32,
                        Text(
                          '${tireSize.height}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ColorsPalette.black,
                            fontSize: 12.sp,
                            fontFamily: ZainTextStyles.font,
                          ),
                        ),
                        UtilValues.gap32,
                        Text(
                          '${tireSize.length}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ColorsPalette.black,
                            fontSize: 12.sp,
                            fontFamily: ZainTextStyles.font,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList() ??
                []
            : [],
      ),
    );
  }

  Widget buildDropDownCategoriesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.categories.tr(),
          style: TextStyle(
            fontSize: 10.sp,
            color: change ? ColorsPalette.black : ColorsPalette.darkGrey,
            fontFamily: ZainTextStyles.font,
            fontWeight: FontWeight.w600,
          ),
        ),
        UtilValues.gap4,
        FutureBuilder<CarPartsModel>(
          future: MiscellaneousApi.getCarParts(locale: context.locale),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return const LoadingWidget();
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            final carBrands = snapshot.data?.data?.productCategories;

            // Check if carBrands is null or empty
            if (carBrands == null || carBrands.isEmpty) {
              return Text('No car brands available');
            }

            return Container(
                height: 55,
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
                    LocaleKeys.category.tr(),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color:
                          change ? ColorsPalette.black : ColorsPalette.darkGrey,
                      fontFamily: ZainTextStyles.font,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: const TextStyle(
                    fontFamily: ZainTextStyles.font,
                    color: ColorsPalette.black,
                  ),
                  value: isChangeDropDownCategory,
                  onChanged: (int? newValue) async {
                    setState(() {
                      isChangeDropDownCategory = newValue;
                    });
                  },
                  items: carBrands.map((ProductCategories carsType) {
                    return DropdownMenuItem<int>(
                      value: carsType.id,
                      child: Text(
                        carsType.name ?? 'Unknown',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ColorsPalette.black,
                          fontSize: 12.sp,
                          fontFamily: ZainTextStyles.font,
                        ),
                      ),
                    );
                  }).toList(),
                ));
          },
        ),
      ],
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
        return Column(
          children: [
            Container(
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
                  if (newValue != null) {
                    print('Car selected with ID: ${newValue.id}');
                    print('Car model: ${newValue.model?.brand?.name} ${newValue.year} - ${newValue.engine}');
                    
                    setState(() {
                      // Check if car already exists in the list to avoid duplicates
                      if (!carIds.any((car) => car.id == newValue.id)) {
                        carIds.add(newValue);
                        print('\n\n======== DEBUG CAR SELECTION ========');
                        print('Added car to list. Current car IDs: ${carIds.map((car) => car.id).toList()}');
                        print('Current selected value: $selected');
                        print('====================================\n\n');
                      } else {
                        print('Car already in list! Current car IDs: ${carIds.map((car) => car.id).toList()}');
                      }
                      isChangeDropDownCarsEng = newValue;
                    });
                  }
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
            ),
            if (carIds.isNotEmpty) ...[
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: ColorsPalette.lightGrey),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Cars',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                        fontFamily: ZainTextStyles.font,
                      ),
                    ),
                    SizedBox(height: 5),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: carIds.map((car) {
                        return Chip(
                          backgroundColor: ColorsPalette.lightGrey,
                          label: Text(
                            '${car.model?.brand?.name} ${car.year} - ${car.engine}',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontFamily: ZainTextStyles.font,
                            ),
                          ),
                          deleteIcon: Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() {
                              carIds.removeWhere((c) => c.id == car.id);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      } else {
        return SizedBox.shrink();
      }
    });
  }

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

  ///
  bool change = false;
  bool changeModel = false;
  bool changeCar = false;
  CarModelModel? carModels;
  CarsListModel? allCarsList;
  YearsModel? yearsList;
  int? isChangeDropDownCarsType;
  int? isChangeDropDownCategory;
  int? isChangeDropDownCarsModel;
  int? isChangeDropDownCars1;
  Cars? isChangeDropDownCarsEng;

  String idImg = '';
  File? _image;

  final ImagePicker _picker = ImagePicker();

  Future<void> _checkPermission() async {
    final status = await Permission.photos.status;
    if (status.isDenied) {
      await Permission.photos.request();
    }
  }

  Future<void> _captureImage() async {
    await _checkPermission();

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (image != null) {
        setState(() {
          _image = File(image.path);
        });
        
        final img = await ImageCompressor.compressImage(_image!);
        final d = await MiscellaneousApi.uploadImage(
            image: img, locale: context.locale);
        setState(() {
          idImg = d.data?.images?.first.filename ?? '';
        });
        setState(() => _loading = true);

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
        message: 'خطأ في اختيار الصورة: $e',
      );
    }
  }
}
