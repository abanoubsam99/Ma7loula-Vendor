import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:ma7lola_vendor/core/utils/font.dart';
import 'package:ma7lola_vendor/core/widgets/loading_widget.dart';
import 'package:ma7lola_vendor/view/screens/auth/emergency_additional_info.dart';
import 'package:ma7lola_vendor/view/screens/auth/winch_additional_info.dart';
import 'package:sizer/sizer.dart';

import '../../../core/generated/locale_keys.g.dart';
import '../../../core/services/secure_storage/secure_storage_keys.dart.dart';
import '../../../core/services/secure_storage/secure_storage_service.dart';
import '../../../core/utils/assets_manager.dart';
import '../../../core/utils/colors_palette.dart';
import '../../../core/utils/util_values.dart';
import '../../../core/widgets/form_widgets/text_input_field.dart';
import '../loca_widgets/PasswordRequirementStep.dart';
import 'additional_info_Id.dart';

class AccountDetails extends StatefulWidget {
  static const String routeName = '/accountDetails';
  final String phone;
  final String otp;
  AccountDetails({Key? key, required this.phone, required this.otp})
      : super(key: key);

  @override
  State<AccountDetails> createState() => _AccountDetailsState();
}

class _AccountDetailsState extends State<AccountDetails> {
  final _formKey = GlobalKey<FormState>();

  var _userNameController = TextEditingController();
  var _userMailController = TextEditingController();

  var _passwordController = TextEditingController();

  var _confirmPasswordController = TextEditingController();

  bool showSniper = false;

  bool showPass = true;
  bool showConPass = true;
  bool _loading = false;

  String? password;
  
  // Password validation function
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    
    // Check minimum length
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    // Check for uppercase letters
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    
    // Check for numbers
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    
    // Check for special characters
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    
    return null;
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    nameFormField(),
                    UtilValues.gap8,
                    mailFormField(),
                    UtilValues.gap8,
                    passwordFormField(),
                    UtilValues.gap8,
                    confirmPasswordFormField(),
                    UtilValues.gap16,
                    Text(
                      LocaleKeys.passwordTerms.tr(),
                      style: TextStyle(
                          color: ColorsPalette.passwordRequirementGrey,
                          fontWeight: FontWeight.w600,
                          fontFamily: ZainTextStyles.font,
                          fontSize: 10.sp),
                    ),
                    PasswordRequirementStep(LocaleKeys.conOne.tr()),
                    PasswordRequirementStep(LocaleKeys.conTwo.tr()),
                    PasswordRequirementStep(LocaleKeys.conThree.tr()),
                    UtilValues.gap20,
                    _changePasswordButton(),
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  void changePassword() async {
    final formState = _formKey.currentState ?? _formKey.currentState;

    final storedVendorId = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.vendorID);

    final id = int.tryParse(storedVendorId ?? '');

    if (_userMailController.text.isEmpty) {
      setState(() {
        _userMailController.text = _userNameController.text;
      });
    }

    if (formState!.validate() &&
        _passwordController.text.isNotEmpty &&
        _userNameController.text.isNotEmpty &&
        _userMailController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty) {
      if (id == 1 || id == 2) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return NationalIDCapture(
            password: _passwordController.text,
            name: _userNameController.text,
            passwordConfirmation: _confirmPasswordController.text,
            mail: _userMailController.text,
            phone: widget.phone ?? '',
            otp: widget.otp ?? '',
          );
        }));
      } else if (id == 3) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return WinchNationalIDCapture(
            password: _passwordController.text,
            name: _userNameController.text,
            passwordConfirmation: _confirmPasswordController.text,
            mail: _userMailController.text,
            phone: widget.phone ?? '',
            otp: widget.otp ?? '',
          );
        }));
      } else if (id == 4) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return EmergencyNationalIDCapture(
            password: _passwordController.text,
            name: _userNameController.text,
            passwordConfirmation: _confirmPasswordController.text,
            mail: _userMailController.text,
            phone: widget.phone ?? '',
            otp: widget.otp ?? '',
          );
        }));
      }
    }
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
          child: _loading
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
          hint: '',
          validator: FormBuilderValidators.required(),
        ),
      ],
    );
  }

  Widget mailFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.mail.tr(),
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
          inputType: TextInputType.emailAddress,
          name: LocaleKeys.mail.tr(),
          key: const ValueKey('mail'),
          hint: '',
          validator: FormBuilderValidators.email(),
        ),
      ],
    );
  }

  Widget passwordFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.password.tr(),
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
          controller: _passwordController,
          inputType: TextInputType.name,
          obscured: showPass,
          name: LocaleKeys.password.tr(),
          key: const ValueKey('password'),
          hint: '',
          validator: validatePassword,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                showPass = !showPass;
              });
            },
            icon: showPass
                ? Icon(
                    Icons.remove_red_eye,
                    color: ColorsPalette.primaryColor,
                  )
                : Icon(
                    Icons.remove_red_eye_outlined,
                    color: ColorsPalette.primaryColor,
                  ),
          ),
        ),
      ],
    );
  }

  Widget confirmPasswordFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.confirmPassword.tr(),
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
          controller: _confirmPasswordController,
          inputType: TextInputType.name,
          obscured: showConPass,
          name: LocaleKeys.password,
          key: const ValueKey('confirmPassword'),
          hint: '',
          validator: (value) {
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                showConPass = !showConPass;
              });
            },
            icon: showConPass
                ? Icon(
                    Icons.remove_red_eye,
                    color: ColorsPalette.primaryColor,
                  )
                : Icon(
                    Icons.remove_red_eye_outlined,
                    color: ColorsPalette.primaryColor,
                  ),
          ),
        ),
      ],
    );
  }
}
