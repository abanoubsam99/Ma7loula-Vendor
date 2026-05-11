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
import '../../../../../../model/tires_size_model.dart';
import '../../../../../../model/voltages_model.dart';
import '../../../../../../model/years_model.dart';
import '../../../main_screen.dart';
import '../local_widgets/voltage_card.dart';

class AddBatteryScreen extends StatefulWidget {
  static const String routeName = '/addbattery';
  @override
  _AddBatteryScreenState createState() => _AddBatteryScreenState();
}

class _AddBatteryScreenState extends State<AddBatteryScreen> {
  final _formKey = GlobalKey<FormState>();
  var _price = TextEditingController();
  var _priceBeforeDisc = TextEditingController();
  var _productNo = TextEditingController();

  var _userNameController = TextEditingController();
  var _userMailController = TextEditingController();
  bool showSniper = false;

  bool _loading = false;
  bool _loadings = false;

  int? _isChangeDropDownBrands;
  String? _isChangeDropDownSizesWidth;
  List<String>? tiresType = [];
  List<TireSizes>? tiresSizes;
  String? _tupe;
  String? _tup2;
  
  // List of voltage options
  List<String> voltageOptions = ['A 40', 'A 30'];
  String? selectedVoltage;

  bool _changeWidth = false;
  bool _changeBrand = false;
  int? selected;
  int? selectedUserCar;
  List<Cars> carIds = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarApp(
        title: LocaleKeys.addBattery.tr(),
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
                    buildDropDownBrands(),
                    UtilValues.gap12,
                    _volts(),
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

                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    //   child: Text(
                    //     LocaleKeys.year.tr(),
                    //     textAlign: TextAlign.center,
                    //     style: TextStyle(
                    //         fontWeight: FontWeight.bold,
                    //         color: ColorsPalette.customGrey,
                    //         fontFamily: ZainTextStyles.font,
                    //         fontSize: 12.sp),
                    //   ),
                    // ),
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
                    UtilValues.gap12,
                    _typesWidget(),
                    UtilValues.gap32,
                    // productsNoFormField(),
                    // UtilValues.gap12,
                    // _typesWidget(),
                    // UtilValues.gap12,
                    // UtilValues.gap12,
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  _volts() {
    // Debug print to track selected value
    print('\n\n======== VOLTS METHOD CALLED ========');
    print('Selected car_id: $selected');
    print('====================================\n\n');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Message when no car is selected
        // Car selection message removed as requested
          
        // Show voltage selector widget
        _electricVoltageWidget(),
      ],
    );
  }
  
  // New widget for electric voltage selection
  _electricVoltageWidget() {
    return SizedBox(
      height: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            context.locale.languageCode == 'en' ? 'Choose Electric Voltage' : 'اختر الجهد الكهربائي',
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
                itemCount: voltageOptions.length,
                itemBuilder: (context, index) {
                  final voltage = voltageOptions[index];
                  return _voltageOptionItem(voltage, voltage);
                }),
          ),
        ],
      ),
    );
  }
  
  // Item widget for voltage option selection
  _voltageOptionItem(String? name, String? value) {
    return CardVoltages(
      name: name ?? '',
      value: value,
      selectedValue: selectedVoltage,
      onChanged: _onVoltageChange,
    );
  }
  
  // Handler for voltage option change
  void _onVoltageChange(String? voltage) {
    print('\n\n======== VOLTAGE SELECTED ========');
    print('Voltage changed to: $voltage');
    print('===================================\n\n');
    
    setState(() {
      selectedVoltage = voltage;
      // Also set _tupe to be the same (for backward compatibility)
      _tupe = voltage;
    });
  }

  void changePassword() async {
    try {
      // Print all form values for debugging
      print('\n\n============ FORM SUBMISSION DEBUG ============');
      print('Name: ${_userNameController.text}');
      print('SKU: ${_userMailController.text}');
      print('Brand ID: $_isChangeDropDownBrands');
      print('Tire Type: $_tup2');
      print('Voltage selected: $_tupe');
      print('Alternative voltage: $selectedVoltage');
      print('Stock: ${_productNo.text}');
      print('Price: ${_price.text}');
      print('Price Before Discount: ${_priceBeforeDisc.text}');
      print('Year: $isChangeDropDownCars1');
      print('Image: $idImg');
      print('Car IDs: ${carIds.map((e) => e.id).toList()}');
      print('Car IDs after unique: ${carIds.map((e) => e.id ?? 0).toSet().toList()}');
      print('Selected car_id variable: $selected');
      print('Car Type ID: $isChangeDropDownCarsType');
      print('Car Model ID: $isChangeDropDownCarsModel');
      print('Car Engine: ${isChangeDropDownCarsEng?.engine}');
      print('============================================\n\n');
      
      final formState = _formKey.currentState ?? _formKey.currentState;
      
      // Print validation status for each field
      print('\n\n======== VALIDATION STATUS ========');
      print('Form validates: ${formState!.validate()}');
      print('Brand (_isChangeDropDownBrands): ${_isChangeDropDownBrands != null}');
      print('Voltage (selectedVoltage): ${selectedVoltage != null}');
      print('Tire Type (_tup2): ${_tup2 != null}');
      print('Image (_uploadedImages): ${_uploadedImages.isNotEmpty}');
      print('Car IDs (carIds): ${carIds.isNotEmpty}');
      print('Car Type (isChangeDropDownCarsType): ${isChangeDropDownCarsType != null}');
      print('Car Engine (isChangeDropDownCarsEng): ${isChangeDropDownCarsEng != null}');
      print('Car Model (isChangeDropDownCarsModel): ${isChangeDropDownCarsModel != null}');
      print('Year (isChangeDropDownCars1): ${isChangeDropDownCars1 != null}');
      print('====================================\n\n');
      
      // Very simplified validation - only check critical fields
      if (formState.validate() &&
          _isChangeDropDownBrands != null &&
          selectedVoltage != null && // Only require selectedVoltage
          _uploadedImages.isNotEmpty &&
          carIds.isNotEmpty) {
        setState(() => _loadings = true);
        
        // Print the exact payload being sent to the API
        print('\n\n============ ALL VARIABLE VALUES ============');
        print('FORM CONTROLLERS:');
        print('_userNameController: ${_userNameController.text}');
        print('_userMailController: ${_userMailController.text}');
        print('_productNo: ${_productNo.text}');
        print('_price: ${_price.text}');
        print('_priceBeforeDisc: ${_priceBeforeDisc.text}');
        
        print('\nDROPDOWN SELECTIONS:');
        print('_isChangeDropDownBrands: ${_isChangeDropDownBrands}');
        print('_isChangeDropDownSizesWidth: ${_isChangeDropDownSizesWidth}');
        print('selectedVoltage: ${selectedVoltage}');
        print('_tupe (alternative voltage): ${_tupe}');
        print('_tup2 (tire type): ${_tup2}');
        print('isChangeDropDownCarsType: ${isChangeDropDownCarsType}');
        print('isChangeDropDownCarsEng: ${isChangeDropDownCarsEng?.engine}');
        print('isChangeDropDownCarsModel: ${isChangeDropDownCarsModel}');
        print('isChangeDropDownCars1 (year): ${isChangeDropDownCars1}');
        
        print('\nIMAGES & IDs:');
        print('idImg: ${idImg}');
        print('_images (File objects): ${_images.length} files');
        print('_uploadedImages: ${_uploadedImages}');
        print('carIds: ${carIds.map((e) => '${e.id} (${e.model?.name})').toList()}');
        print('===========================================\n\n');
        
        print('\n\n============ CURRENT API PAYLOAD ============');
        print('description: ${_userMailController.text}');
        print('sku: ${_userMailController.text}');
        print('name: ${_userNameController.text}');
        print('tireType: ${_tup2 ?? ''}');
        print('brandId: ${_isChangeDropDownBrands ?? 0}');
        print('stock: ${int.tryParse(_productNo.text) ?? 0}');
        print('price: ${int.tryParse(_price.text) ?? 0}');
        print('priceBeforeDiscount: ${int.tryParse(_priceBeforeDisc.text) ?? 0}');
        print('yearManufacture: ${isChangeDropDownCars1 ?? 0}');
        print('voltage: ${selectedVoltage ?? 'A 40'}');
        print('carIds: ${carIds.map((e) => e.id ?? 0).toSet().toList()}');
        print('images: ${_uploadedImages}');
        print('======================================\n\n');
        await MiscellaneousApi.addBattery(
          description: _userMailController.text,
          sku: _userMailController.text,
          name: _userNameController.text,
          tireType: _tup2 ?? '',
          brandId: _isChangeDropDownBrands ?? 0,
          stock: int.tryParse(_productNo.text) ?? 0,
          price: int.tryParse(_price.text) ?? 0,
          priceBeforeDiscount: int.tryParse(_priceBeforeDisc.text) ?? 0,
          yearManufacture: isChangeDropDownCars1 ?? 0,
          locale: context.locale,
          voltage: selectedVoltage ?? 'A 40',
          carIds: carIds.map((e) => e.id ?? 0).toSet().toList(),
          images: _uploadedImages,
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
                  LocaleKeys.addBattery.tr(),
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
          LocaleKeys.sku.tr(),
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
          name: LocaleKeys.sku.tr(),
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

  _typesWidget() {
    return SizedBox(
      height: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "",
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

  _types(String? name, String? value) {
    return CardVoltages(
      name: name ?? '',
      value: value,
      selectedValue: _tupe,
      onChanged: _onType,
    );
  }

  void _onType(String? type) async {
    setState(() {
      _tupe = type;
    });
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

  Widget buildDropDownBrands() {
    return FutureBuilder<TiresBrandsModel>(
      future: MiscellaneousApi.getBrands(
        locale: context.locale,
      ),
      builder: (context, brand) {
        if (brand.data != null &&
            (brand.data?.data?.brands?.isNotEmpty ?? false)) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.batteriesBrand.tr(),
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
                    tiresSizes = null;
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
              if (newValue != null) {
                print('\n\n======== CAR SELECTED ========');
                print('Selected car ID: ${newValue.id}');
                print('Selected car details: ${newValue.model?.brand?.name} ${newValue.year} - ${newValue.engine}');
                print('===============================\n\n');
                
                setState(() {
                  // Check if car already exists in the list to avoid duplicates
                  if (!carIds.any((car) => car.id == newValue.id)) {
                    carIds.add(newValue);
                  }
                  
                  // This is the critical line - set the selected variable to the car ID
                  selected = newValue.id;
                  isChangeDropDownCarsEng = newValue;
                  
                  print('Updated selected to: $selected');
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
              "",
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

  String idImg = '';
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
