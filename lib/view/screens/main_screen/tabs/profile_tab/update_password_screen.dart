import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:ma7lola_vendor/core/utils/font.dart';
import 'package:ma7lola_vendor/core/widgets/loading_widget.dart';
import 'package:ma7lola_vendor/view/screens/main_screen/main_screen.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../../../controller/user_provider.dart';
import '../../../../../core/generated/locale_keys.g.dart';
import '../../../../../core/utils/colors_palette.dart';
import '../../../../../core/utils/snackbars.dart';
import '../../../../../core/utils/util_values.dart';
import '../../../../../core/widgets/custom_app_bar.dart';
import '../../../../../core/widgets/form_widgets/text_input_field.dart';
import '../../../loca_widgets/PasswordRequirementStep.dart';

class UpdatePasswordScreen extends StatefulWidget {
  static const String routeName = '/updatePassword';

  UpdatePasswordScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  var _oldPasswordController = TextEditingController();
  var _passwordController = TextEditingController();

  var _confirmPasswordController = TextEditingController();

  bool showSniper = false;

  bool showPass = true;
  bool showOldPass = true;
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
      appBar: AppBarApp(
        title: LocaleKeys.changePassword.tr(),
      ),
      bottomNavigationBar: _changePasswordButton(),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            height: MediaQuery.of(context).size.height,
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
                    oldPasswordFormField(),
                    UtilValues.gap16,
                    passwordFormField(),
                    UtilValues.gap16,
                    confirmPasswordFormField(),
                    UtilValues.gap12,
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
      if (formState!.validate()) {
        setState(() => _loading = true);
        await context.read<UserProvider>().updatePassword(
            currentPassword: _oldPasswordController.text,
            password: _passwordController.text,
            passwordConfirmation: _confirmPasswordController.text,
            locale: context.locale);
        
        // Show a more descriptive success message
        showSnackbar(
          context: context,
          status: SnackbarStatus.success,
          message: LocaleKeys.changePassword.tr() + ' ' + LocaleKeys.done.tr(),
        );
        
        // Correct loading state
        setState(() => _loading = false);
        
        // Add a slight delay before navigation to ensure the user sees the message
        await Future.delayed(const Duration(milliseconds: 1500));
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MainScreen(
                    index: 3,
                  )),
        );
      }
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
          child: _loading
              ? const LoadingWidget(
                  color: ColorsPalette.white,
                )
              : Text(
                  LocaleKeys.changePassword.tr(),
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

  Widget oldPasswordFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.oldPassword.tr(),
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
          controller: _oldPasswordController,
          inputType: TextInputType.name,
          obscured: showOldPass,
          name: LocaleKeys.oldPassword,
          key: const ValueKey('oldPassword'),
          hint: '',
          validator: FormBuilderValidators.minLength(8),
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                showOldPass = !showOldPass;
              });
            },
            icon: showOldPass
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

  Widget passwordFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.newPassword.tr(),
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
          name: LocaleKeys.password,
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
          LocaleKeys.newPasswordConfirm.tr(),
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
          name: LocaleKeys.newPasswordConfirm,
          key: const ValueKey('confirmPassword'),
          hint: '',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
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
