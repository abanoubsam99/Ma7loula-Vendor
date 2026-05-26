import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/services/secure_storage/secure_storage_keys.dart.dart';
import '../../../core/services/secure_storage/secure_storage_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../controller/user_provider.dart';
import '../../../core/generated/locale_keys.g.dart';
import '../../../core/services/http/apis/miscellaneous_api.dart';
import '../../../core/utils/assets_manager.dart';
import '../../../core/utils/colors_palette.dart';
import '../../../core/utils/font.dart';
import '../../../core/utils/snackbars.dart';
import '../../../core/utils/util_values.dart';
import '../../../core/widgets/form_widgets/text_input_field.dart';
import '../../../core/widgets/loading_widget.dart';
import '../main_screen/main_screen.dart';

class WinchNationalIDCapture extends StatefulWidget {
  final String phone;
  final String password;
  final String name;
  final String mail;
  final String passwordConfirmation;
  final String otp;
  final String? idImg;
  final String? idImgLic;
  final String? carCode;
  final String? companyCode;
  final String? address;
  final String? licenceExDate;
  final String? licenceDrivingExDate;
  final String? licenceNo;
  final String? licenceCarNo;
  final double? late;
  final double? long;
  final File? image;
  final File? imageLic;

  const WinchNationalIDCapture({
    super.key,
    required this.phone,
    required this.password,
    required this.name,
    required this.mail,
    required this.passwordConfirmation,
    required this.otp,
    this.late,
    this.long,
    this.image,
    this.imageLic,
    this.idImg,
    this.idImgLic,
    this.carCode,
    this.companyCode,
    this.address,
    this.licenceExDate,
    this.licenceDrivingExDate,
    this.licenceNo,
    this.licenceCarNo,
  });

  @override
  _WinchNationalIDCaptureState createState() => _WinchNationalIDCaptureState();
}

class _WinchNationalIDCaptureState extends State<WinchNationalIDCapture> {
  @override
  void initState() {
    // TODO: implement initState
    _fetch();
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();

  var _licenceNo = TextEditingController();
  var _licenceCarNo = TextEditingController();
  String? _licenceExDate;
  String? _licenceDrivingExDate;

  var _companyCode = TextEditingController();
  var _carCode = TextEditingController();
  var _vendorIdController = TextEditingController(text: '61'); // Default vendor ID for winch

  var _address = TextEditingController();

  bool _loading = false;
  bool _isLoading = false;
  bool _isLoadingBTN = false;

  File? _image;
  File? _imageLic;
  File? _driverImageLic;
  File? _driverCImageLic;
  final ImagePicker _picker = ImagePicker();
  final ImagePicker _pickerLic = ImagePicker();
  final ImagePicker _driverPickerLic = ImagePicker();
  final ImagePicker _driverCPickerLic = ImagePicker();

  Future<void> _checkPermission() async {
    try {
      await Permission.camera.request();
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _checkStoragePermission() async {
    try {
      final status = await Permission.storage.request();
      if (status.isDenied) {
        // If permission is denied, show a message to the user
        showSnackbar(
          context: context,
          status: SnackbarStatus.error,
          message: "Storage permission is required",
        );
      }
    } catch (e) {
      print('Permission Error: $e');
    }
  }

  Future<void> _captureImage() async {
    await _checkPermission();

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null) {
        setState(() {
          _image = File(image.path);
        });
      }
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
    } catch (e) {
      print('خطأ في التقاط الصورة: $e');
      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: e.toString().replaceAll('ApiException: ', ''),
      );
    }
  }

  Future<void> _captureImageLic() async {
    await _checkPermission();

    try {
      final XFile? image = await _pickerLic.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null) {
        setState(() {
          _imageLic = File(image.path);
        });
      }
      final img = await ImageCompressor.compressImage(_imageLic!);
      final d = await MiscellaneousApi.uploadImage(
          image: img, locale: context.locale);
      setState(() {
        idImgLic = d.data?.images?.first.filename ?? '';
      });
      setState(() => _loading = true);

      showSnackbar(
        context: context,
        status: SnackbarStatus.success,
        message: LocaleKeys.done.tr(),
      );
    } catch (e) {
      print('خطأ في التقاط الصورة: $e');
      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: e.toString().replaceAll('ApiException: ', ''),
      );
    }
  }

  Future<void> _driverCaptureImageLic() async {
    await _checkPermission();

    try {
      final XFile? image = await _driverPickerLic.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null) {
        setState(() {
          _driverImageLic = File(image.path);
        });
      }
      final img = await ImageCompressor.compressImage(_driverImageLic!);
      final d = await MiscellaneousApi.uploadImage(
          image: img, locale: context.locale);
      setState(() {
        driverImgLic = d.data?.images?.first.filename ?? '';
      });
      setState(() => _loading = true);

      showSnackbar(
        context: context,
        status: SnackbarStatus.success,
        message: LocaleKeys.done.tr(),
      );
    } catch (e) {
      print('خطأ في التقاط الصورة: $e');
      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: e.toString().replaceAll('ApiException: ', ''),
      );
    }
  }

  Future<void> _driverCCaptureImageLic() async {
    // Request storage permission instead of camera permission
    await _checkStoragePermission();

    try {
      final XFile? image = await _driverCPickerLic.pickImage(
        source: ImageSource.gallery, // Changed from camera to gallery
        imageQuality: 100,
      );

      if (image != null) {
        setState(() {
          _driverCImageLic = File(image.path);
        });
        
        final img = await ImageCompressor.compressImage(_driverCImageLic!);
        final d = await MiscellaneousApi.uploadImage(
            image: img, locale: context.locale);
        setState(() {
          driverCImgLic = d.data?.images?.first.filename ?? '';
          _loading = true;
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
        message: 'خطأ في اختيار الصورة: $e',
      );
    }
  }

  Future<void> _checkPermissionLoc() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        // _locationMessage =
        //     'Location services are disabled. Please enable them.';
      });
      return;
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          // _locationMessage = 'Location permission denied';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        // _locationMessage =
        //     'Location permissions permanently denied. Please enable in settings.';
      });
      return;
    }
  }

  _fetch() {
    idImg = widget.idImg ?? '';
    idImgLic = widget.idImgLic ?? '';
    driverImgLic = widget.idImgLic ?? '';
    _image = _image;
    _imageLic = _imageLic;
    _carCode.text = widget.carCode ?? '';
    _companyCode.text = widget.companyCode ?? '';
    _licenceExDate = widget.licenceExDate ?? null;
    _licenceDrivingExDate = widget.licenceDrivingExDate ?? null;
    _licenceNo.text = widget.licenceNo ?? '';
    _licenceCarNo.text = widget.licenceCarNo ?? '';
    _address.text = widget.address ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: ColorsPalette.lighttGrey,
            image: DecorationImage(
              fit: BoxFit.fill,
              colorFilter: ColorFilter.mode(
                  ColorsPalette.light.withOpacity(.9), BlendMode.lighten),
              image: AssetImage(AssetsManager.backgroundLogo),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  UtilValues.gap48,
                  Center(
                    child: Text(
                      LocaleKeys.accountDetails.tr(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: ZainTextStyles.font,
                          fontSize: 22.sp),
                    ),
                  ),
                  UtilValues.gap12,
                  if (_image != null)
                    scannerWithImgField(LocaleKeys.idImg.tr(),
                        LocaleKeys.idImgScan.tr(), _captureImage, _image!)
                  else
                    scannerField(
                        LocaleKeys.idImg.tr(),
                        LocaleKeys.idImgScan.tr(),
                        _captureImage,
                        AssetsManager.scanner),
                  UtilValues.gap16,
                  if (_imageLic != null)
                    scannerWithImgField(
                        LocaleKeys.scanDrivingId.tr(),
                        LocaleKeys.licenceNoScan.tr(),
                        _captureImageLic,
                        _imageLic!)
                  else
                    scannerField(
                        LocaleKeys.scanDrivingId.tr(),
                        LocaleKeys.licenceNoScan.tr(),
                        _captureImageLic,
                        AssetsManager.scanner),
                  UtilValues.gap6,
                  licenceNoFormField(),
                  UtilValues.gap16,
                  if (_driverImageLic != null)
                    scannerWithImgField(
                        LocaleKeys.scanCarId.tr(),
                        LocaleKeys.licenceNoScan.tr(),
                        _driverCaptureImageLic,
                        _driverImageLic!)
                  else
                    scannerField(
                        LocaleKeys.scanCarId.tr(),
                        LocaleKeys.licenceNoScan.tr(),
                        _driverCaptureImageLic,
                        AssetsManager.scanner),
                  UtilValues.gap6,
                  driverLicenceNoFormField(),
                  UtilValues.gap16,
                  companyCodeFormField(),
                  UtilValues.gap16,
                  carCodeFormField(),
                  UtilValues.gap16,
                  vendorIdFormField(),
                  UtilValues.gap16,
                  if (_driverCImageLic != null)
                    scannerWithImgField(
                        LocaleKeys.fishFile.tr(),
                        LocaleKeys.fishFileDesc.tr(),
                        _driverCCaptureImageLic,
                        _driverCImageLic!)
                  else
                    scannerField(
                        LocaleKeys.fishFile.tr(),
                        LocaleKeys.fishFileDesc.tr(),
                        _driverCCaptureImageLic,
                        AssetsManager.scanner),
                  UtilValues.gap16,
                  _changePasswordButton()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _changePasswordButton() {
    return Container(
      // padding: EdgeInsets.symmetric(vertical: 2.h),
      margin: EdgeInsets.all(1.sp),
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
          child: _isLoadingBTN
              ? const LoadingWidget(
                  color: ColorsPalette.white,
                )
              : Text(
                  LocaleKeys.createAccount.tr(),
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

  Widget companyCodeFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.companyCode.tr(),
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
          controller: _companyCode,
          inputType: TextInputType.name,
          name: LocaleKeys.companyCodeNo.tr(),
          key: const ValueKey('companyCodeNo'),
          hint: LocaleKeys.companyCodeNo.tr(),
          validator: FormBuilderValidators.required(),
        ),
      ],
    );
  }

  Widget carCodeFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.carCode.tr(),
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
          controller: _carCode,
          inputType: TextInputType.name,
          name: LocaleKeys.carCodeNo.tr(),
          key: const ValueKey('carCodeNo'),
          hint: LocaleKeys.carCodeNo.tr(),
          validator: FormBuilderValidators.required(),
        ),
      ],
    );
  }

  Widget vendorIdFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vendor ID', 
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
          controller: _vendorIdController,
          inputType: TextInputType.number,
          name: 'vendor_id',
          key: const ValueKey('vendorId'),
          hint: 'Enter vendor ID (default: 61)',
          validator: FormBuilderValidators.required(),
        ),
      ],
    );
  }

  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    // Get current date without time component
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    
    // Set initial date to today if current selected date is before today
    DateTime initialDate = _selectedDate.isBefore(today) ? today : _selectedDate;
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today, // Start from today
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _licenceExDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  DateTime _selectedDrivingDate = DateTime.now();

  Future<void> _selectDrivingDate(BuildContext context) async {
    // Get current date without time component
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    
    // Set initial date to today if current selected date is before today
    DateTime initialDate = _selectedDrivingDate.isBefore(today) ? today : _selectedDrivingDate;
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today, // Start from today
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDrivingDate) {
      setState(() {
        _selectedDrivingDate = picked;
        _licenceDrivingExDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Widget licenceNoFormField() {
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
              controller: _licenceNo,
              inputType: TextInputType.number,
              name: LocaleKeys.drivingNo.tr(),
              key: const ValueKey('drivingNo'),
              hint: LocaleKeys.drivingNo.tr(),
              validator: FormBuilderValidators.required(),
            ),
          ),
          UtilValues.gap2,
          Expanded(
            child: InkWell(
              onTap: () => _selectDrivingDate(context),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: ColorsPalette.white,
                  border: Border.all(color: ColorsPalette.extraDarkGrey),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.centerRight,
                child: Text(
                  _licenceDrivingExDate ?? LocaleKeys.licenceDateEx.tr(),
                  style: TextStyle(
                      color: ColorsPalette.customGrey,
                      fontWeight: FontWeight.w400,
                      fontFamily: ZainTextStyles.font,
                      fontSize: 12.sp),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget driverLicenceNoFormField() {
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
              controller: _licenceCarNo,
              inputType: TextInputType.number,
              name: LocaleKeys.carNo.tr(),
              key: const ValueKey('carNo'),
              hint: LocaleKeys.carNo.tr(),
              validator: FormBuilderValidators.required(),
            ),
          ),
          UtilValues.gap2,
          Expanded(
            child: InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: ColorsPalette.white,
                  border: Border.all(color: ColorsPalette.extraDarkGrey),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.centerRight,
                child: Text(
                  _licenceExDate ?? LocaleKeys.licenceDateEx.tr(),
                  style: TextStyle(
                      color: ColorsPalette.customGrey,
                      fontWeight: FontWeight.w400,
                      fontFamily: ZainTextStyles.font,
                      fontSize: 12.sp),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget scannerField(String scanText, String scanHint, onTap, String icon) {
    return InkWell(
      onTap: _isLoading ? () {} : onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            scanText,
            style: TextStyle(
                color: ColorsPalette.black,
                fontWeight: FontWeight.w400,
                fontFamily: ZainTextStyles.font,
                fontSize: 14.sp),
          ),
          _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: ColorsPalette.primaryColor,
                  ),
                )
              : Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: ColorsPalette.white,
                    border: Border.all(color: ColorsPalette.extraDarkGrey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Text(
                        scanHint,
                        style: TextStyle(
                            color: ColorsPalette.black,
                            fontWeight: FontWeight.w600,
                            fontFamily: ZainTextStyles.font,
                            fontSize: 14.sp),
                      ),
                      Spacer(),
                      SvgPicture.asset(
                        icon,
                        fit: BoxFit.scaleDown,
                        width: 4.w,
                        height: 4.h,
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget scannerWithImgField(
      String scanText, String scanHint, onTap, File img) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            scanText,
            style: TextStyle(
                color: ColorsPalette.black,
                fontWeight: FontWeight.w400,
                fontFamily: ZainTextStyles.font,
                fontSize: 14.sp),
          ),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: ColorsPalette.white,
              border: Border.all(color: ColorsPalette.extraDarkGrey),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Text(
                  scanHint,
                  style: TextStyle(
                      color: ColorsPalette.black,
                      fontWeight: FontWeight.w600,
                      fontFamily: ZainTextStyles.font,
                      fontSize: 14.sp),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Image.file(
                    img,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void changePassword() async {
    try {
      final formState = _formKey.currentState ?? _formKey.currentState;

      // Log validation status of each field
      print('WINCH REGISTRATION VALIDATION STATUS:');
      print('_image != null: ${_image != null}');
      print('_imageLic != null: ${_imageLic != null}');
      print('_driverCImageLic != null: ${_driverCImageLic != null}');
      print('_driverImageLic != null: ${_driverImageLic != null}');
      print('idImg.isNotEmpty: ${idImg.isNotEmpty}, value: "$idImg"');
      print('idImgLic.isNotEmpty: ${idImgLic.isNotEmpty}, value: "$idImgLic"');
      print('driverCImgLic.isNotEmpty: ${driverCImgLic.isNotEmpty}, value: "$driverCImgLic"');
      print('driverImgLic.isNotEmpty: ${driverImgLic.isNotEmpty}, value: "$driverImgLic"');
      print('_licenceNo.text.isNotEmpty: ${_licenceNo.text.isNotEmpty}, value: "${_licenceNo.text}"');
      print('_licenceCarNo.text.isNotEmpty: ${_licenceCarNo.text.isNotEmpty}, value: "${_licenceCarNo.text}"');
      print('_licenceExDate != null: ${_licenceExDate != null}, value: "$_licenceExDate"');
      print('_licenceDrivingExDate != null: ${_licenceDrivingExDate != null}, value: "$_licenceDrivingExDate"');
      print('_carCode.text.isNotEmpty: ${_carCode.text.isNotEmpty}, value: "${_carCode.text}"');
      print('_companyCode.text.isNotEmpty: ${_companyCode.text.isNotEmpty}, value: "${_companyCode.text}"');
      
      // Check stored vendor ID before registration
      final storedVendorId = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.vendorID);
      print('STORED VENDOR ID: "$storedVendorId"');

      if (formState!.validate() &&
          _image != null &&
          _imageLic != null &&
          _driverCImageLic != null &&
          _driverImageLic != null &&
          (idImg.isNotEmpty) &&
          (idImgLic.isNotEmpty) &&
          (driverCImgLic.isNotEmpty) &&
          (driverImgLic.isNotEmpty) &&
          _licenceNo.text.isNotEmpty &&
          _licenceCarNo.text.isNotEmpty &&
          _licenceExDate != null &&
          _licenceDrivingExDate != null &&
          _carCode.text.isNotEmpty &&
          _companyCode.text.isNotEmpty) {
        setState(() => _isLoadingBTN = true);

        // Log all API parameters being passed
        print('WINCH REGISTRATION API PARAMETERS:');
        print('password: ${widget.password.replaceAll(RegExp(r'.'), '*')}'); // Mask password for security
        print('name: ${widget.name}');
        print('mail: ${widget.mail}');
        print('phone: ${widget.phone}');
        print('otp: ${int.tryParse(widget.otp) ?? 0}');
        print('idImg: $idImg');
        print('carLicenceNo: ${_licenceCarNo.text}');
        print('carPlateNo: ${_licenceNo.text}');
        print('carLicenceExDate: ${_licenceExDate ?? '2024-11-11'}');
        print('carLicenceImage: $idImgLic');
        print('criminalRecordImage: $driverImgLic');
        print('driverLicenceExDate: ${_licenceDrivingExDate ?? '2024-11-11'}');
        print('driverLicenceImage: $driverCImgLic');
        // print('vendorId: ${widget.vendorId}');
        print('companyCode: ${_companyCode.text}');
        print('carCode: ${_carCode.text}');

        // Register the winch vendor - explicitly set vendorId to 3
        await context.read<UserProvider>().registerWinch(
              password: widget.password,
              name: widget.name,
              passwordConfirmation: widget.passwordConfirmation,
              mail: widget.mail,
              phone: widget.phone,
              otp: int.tryParse(widget.otp) ?? 0,
              locale: context.locale,
              idImg: idImg,
              carLicenceNo: _licenceCarNo.text,
              carPlateNo: _licenceNo.text,
              carLicenceExDate: _licenceExDate ?? '2024-11-11',
              carLicenceImage: idImgLic,
              criminalRecordImage: driverImgLic,
              driverLicenceExDate: _licenceDrivingExDate ?? '2024-11-11',
              driverLicenceImage: driverCImgLic,
              vendorId: int.tryParse(_vendorIdController.text) ?? 61, // Use user input vendor ID or default to 61
              companyCode: _companyCode.text,
              carCode: _carCode.text,
            );
        setState(() => _isLoadingBTN = true);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MainScreen(
                    index: 0,
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
      setState(() => _isLoadingBTN = false);
    } finally {
      setState(() => _isLoadingBTN = false);
    }
  }

  String idImg = '';
  String idImgLic = '';
  String driverImgLic = '';
  String driverCImgLic = '';
  void uploadImg() async {
    try {
      setState(() => _loading = true);

      final d = await MiscellaneousApi.uploadImage(
          image: _image!, locale: context.locale);
      setState(() {
        idImg = d.data?.images?.first.filename ?? '';
      });
      setState(() => _loading = true);

      showSnackbar(
        context: context,
        status: SnackbarStatus.success,
        message: LocaleKeys.done.tr(),
      );
    } catch (e) {
      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: e.toString(),
      );
      setState(() => _loading = false);
    } finally {
      setState(() => _loading = false);
    }
  }
}
