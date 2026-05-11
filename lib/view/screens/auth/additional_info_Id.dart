import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ma7lola_vendor/controller/user_provider.dart';
import 'package:ma7lola_vendor/core/services/http/apis/miscellaneous_api.dart';
import 'package:ma7lola_vendor/view/screens/main_screen/main_screen.dart';
import 'package:ma7lola_vendor/view/screens/map/map_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../core/generated/locale_keys.g.dart';
import '../../../core/utils/assets_manager.dart';
import '../../../core/utils/colors_palette.dart';
import '../../../core/utils/font.dart';
import '../../../core/utils/snackbars.dart';
import '../../../core/utils/util_values.dart';
import '../../../core/widgets/form_widgets/text_input_field.dart';
import '../../../core/widgets/loading_widget.dart';

class NationalIDCapture extends StatefulWidget {
  final String phone;
  final String password;
  final String name;
  final String mail;
  final String passwordConfirmation;
  final String otp;
  final String? idImg;
  final String? idImgLic;
  final String? taxNo;
  final String? address;
  final String? licenceExDate;
  final String? licenceNo;
  final double? late;
  final double? long;
  final File? image;
  final File? imageLic;

  const NationalIDCapture({
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
    this.taxNo,
    this.address,
    this.licenceExDate,
    this.licenceNo,
  });

  @override
  _NationalIDCaptureState createState() => _NationalIDCaptureState();
}

class _NationalIDCaptureState extends State<NationalIDCapture> {
  // Add this field at the class level
  DateTime _selectedDate = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    _fetch();
    
    // Initialize license expiration date to tomorrow by default
    final tomorrow = DateTime.now().add(Duration(days: 1));
    _licenceExDate = DateFormat('yyyy-MM-dd').format(tomorrow);
    _selectedDate = tomorrow;
    
    // Pre-fill from widget if available
    if (widget.licenceExDate != null && widget.licenceExDate!.isNotEmpty) {
      _licenceExDate = widget.licenceExDate;
      try {
        _selectedDate = DateFormat('yyyy-MM-dd').parse(widget.licenceExDate!);
      } catch (e) {
        // If parsing fails, keep the default
      }
    }
  }

  // Add focus nodes for text fields
  final FocusNode _licenceNoFocus = FocusNode();
  final FocusNode _taxNoFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();

  @override
  void dispose() {
    _licenceNoFocus.dispose();
    _taxNoFocus.dispose();
    _addressFocus.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  var _licenceNo = TextEditingController();
  String? _licenceExDate;

  var _taxNo = TextEditingController();

  var _address = TextEditingController();

  bool _loading = false;
  bool _isLoading = false;
  bool _isLoadingBTN = false;

  File? _image;
  File? _imageLic;
  final ImagePicker _picker = ImagePicker();
  final ImagePicker _pickerLic = ImagePicker();

  Future<void> _checkPermission() async {
    final status = await Permission.camera.status;
    if (status.isDenied) {
      await Permission.camera.request();
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
        _loading = true;
      });

      showSnackbar(
        context: context,
        status: SnackbarStatus.success,
        message: LocaleKeys.done.tr(),
      );
      
      // Ensure the form is rebuilt and text fields are re-rendered
      if (mounted) {
        setState(() {});
        // Give a slight delay to ensure UI is updated
        Future.delayed(Duration(milliseconds: 500), () {
          _formKey.currentState?.reset();
        });
      }
    } catch (e) {
      print('خطأ في التقاط الصورة: $e');
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
        _loading = true;
      });

      showSnackbar(
        context: context,
        status: SnackbarStatus.success,
        message: LocaleKeys.done.tr(),
      );
      
      // Ensure input is available after scanning
      if (mounted) {
        // Force rebuild UI
        setState(() {});
        // Slight delay to ensure UI update
        Future.delayed(Duration(milliseconds: 500), () {
          _formKey.currentState?.reset();
        });
      }
    } catch (e) {
      print('خطأ في التقاط الصورة: $e');
      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: e.toString(),
      );
    }
  }

  _fetch() {
    // Properly initialize from widget properties
    idImg = widget.idImg ?? '';
    idImgLic = widget.idImgLic ?? '';
    
    // Check if images are passed in from widget
    if (widget.image != null) {
      _image = widget.image;
    }
    
    if (widget.imageLic != null) {
      _imageLic = widget.imageLic;
    }
    
    // Set the text fields
    _taxNo.text = widget.taxNo ?? '';
    
    // Set a default date if none is provided
    if (widget.licenceExDate != null && widget.licenceExDate!.isNotEmpty) {
      _licenceExDate = widget.licenceExDate;
    } else {
      // Set default date to one year from now
      final now = DateTime.now();
      final nextYear = DateTime(now.year + 1, now.month, now.day);
      _licenceExDate = DateFormat('yyyy-MM-dd').format(nextYear);
    }
    
    _licenceNo.text = widget.licenceNo ?? '';
    _address.text = widget.address ?? '';
    
    // Ensure UI updates after initialization
    if (mounted) setState(() {});
  }

  Future<void> _getCurrentLocation() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return MapScreen(
        phone: widget.phone,
        password: widget.password,
        name: widget.name,
        mail: widget.mail,
        passwordConfirmation: widget.passwordConfirmation,
        otp: widget.otp,
        idImg: idImg,
        idImgLic: idImgLic,
        taxNo: _taxNo.text,
        address: _address.text,
        licenceExDate: _licenceExDate,
        licenceNo: _licenceNo.text,
        image: _image,
        imageLic: _imageLic,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      LocaleKeys.accountDetails.tr(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: ZainTextStyles.font,
                          fontSize: 22.sp),
                    ),
                  ),
                  UtilValues.gap32,
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
                        LocaleKeys.licenceNo.tr(),
                        LocaleKeys.licenceNoScan.tr(),
                        _captureImageLic,
                        _imageLic!)
                  else
                    scannerField(
                        LocaleKeys.licenceNo.tr(),
                        LocaleKeys.licenceNoScan.tr(),
                        _captureImageLic,
                        AssetsManager.scanner),
                  UtilValues.gap6,
                  licenceNoFormField(focusNode: _licenceNoFocus),
                  UtilValues.gap16,
                  taxNoFormField(focusNode: _taxNoFocus),
                  UtilValues.gap16,
                  scannerField(
                      LocaleKeys.location.tr(),
                      (widget.late != null && widget.long != null)
                          ? '${widget.late} - ${widget.long}'
                          : LocaleKeys.locationEnter.tr(),
                      _getCurrentLocation,
                      AssetsManager.locationD),
                  UtilValues.gap16,
                  addressFormField(focusNode: _addressFocus),
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

  Widget taxNoFormField({FocusNode? focusNode}) {
    return TextInputField(
      controller: _taxNo,
      name: LocaleKeys.taxNo.tr(),
      hint: LocaleKeys.taxNoEnter.tr(),
      focusNode: focusNode,
      validator: FormBuilderValidators.required(),
      inputType: TextInputType.text,
      maxLines: 1,
    );
  }

  Widget addressFormField({FocusNode? focusNode}) {
    return TextInputField(
      controller: _address,
      name: LocaleKeys.address.tr(),
      hint: LocaleKeys.address.tr(),
      focusNode: focusNode,
      validator: FormBuilderValidators.required(),
      inputType: TextInputType.text,
      maxLines: 1,
    );
  }

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

  Widget licenceNoFormField({FocusNode? focusNode}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        // key: UniqueKey(),
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
              name: LocaleKeys.licenceID.tr(),
              key: const ValueKey('licenceID'),
              hint: LocaleKeys.licenceID.tr(),
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
      
      // Check individual fields and provide specific feedback
      String errorMessage = LocaleKeys.pleaseSelectAllOptions.tr();
      
      if (_image == null) {
        errorMessage = "${LocaleKeys.idImg.tr()} ${LocaleKeys.pleaseSelectAllOptions.tr()}";
      } else if (_imageLic == null) {
        errorMessage = "${LocaleKeys.licenceNo.tr()} ${LocaleKeys.pleaseSelectAllOptions.tr()}";
      } else if (idImg.isEmpty) {
        errorMessage = "${LocaleKeys.idImg.tr()} ${LocaleKeys.pleaseSelectAllOptions.tr()}";
      } else if (idImgLic.isEmpty) {
        errorMessage = "${LocaleKeys.licenceNo.tr()} ${LocaleKeys.pleaseSelectAllOptions.tr()}";
      } else if (_licenceNo.text.isEmpty) {
        errorMessage = "${LocaleKeys.licenceNo.tr()} ${LocaleKeys.pleaseSelectAllOptions.tr()}";
      } else if (_licenceExDate == null) {
        errorMessage = "${LocaleKeys.licenceNo.tr()} ${LocaleKeys.pleaseSelectAllOptions.tr()}";
      } else if (_taxNo.text.isEmpty) {
        errorMessage = "${LocaleKeys.taxNo.tr()} ${LocaleKeys.pleaseSelectAllOptions.tr()}";
      } else if (_address.text.isEmpty) {
        errorMessage = "${LocaleKeys.address.tr()} ${LocaleKeys.pleaseSelectAllOptions.tr()}";
      }

      if (formState!.validate() &&
          _image != null &&
          _imageLic != null &&
          (idImg.isNotEmpty) &&
          (idImgLic.isNotEmpty) &&
          _licenceNo.text.isNotEmpty &&
          _licenceExDate != null &&
          _taxNo.text.isNotEmpty &&
          _address.text.isNotEmpty) {
        
        // Set loading state only once
        setState(() => _isLoadingBTN = true);

        try {
          await context.read<UserProvider>().register(
                password: widget.password,
                name: widget.name,
                passwordConfirmation: widget.passwordConfirmation,
                mail: widget.mail,
                phone: widget.phone,
                otp: int.tryParse(widget.otp) ?? 0,
                locale: context.locale,
                idImg: idImg,
                companyName: widget.name,
                companyLicenceNo: _licenceNo.text,
                companyLicenceExDate: _licenceExDate ?? '2024-11-11',
                lat: widget.late ?? 30.033333,
                long: widget.long ?? 31.233334,
                address: _address.text,
                taxiNo: _taxNo.text,
                companyLicenceImg: idImgLic,
              );
          
          // Turn off loading state before navigation
          setState(() => _isLoadingBTN = false);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => MainScreen(
                      index: 0,
                    )),
          );
        } catch (e) {
          // Handle API errors
          setState(() => _isLoadingBTN = false);
          showSnackbar(
            context: context,
            status: SnackbarStatus.error,
            message: e.toString(),
          );
        }
      } else {
        showSnackbar(
          context: context,
          status: SnackbarStatus.error,
          message: errorMessage,
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
