import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:ma7lola_vendor/controller/user_provider.dart';
import 'package:ma7lola_vendor/model/user.dart'; // Add UserModel import
import 'package:ma7lola_vendor/core/services/http/apis/user_api.dart'; // Add UserApi import
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/generated/locale_keys.g.dart';
import '../../../../../core/utils/colors_palette.dart';
import '../../../../../core/utils/font.dart';
import '../../../../../core/utils/snackbars.dart';
import '../../../../../core/utils/util_values.dart';
import '../../../../../core/widgets/custom_app_bar.dart';
import '../../../../../core/widgets/form_widgets/text_input_field.dart';
import '../../../../../core/widgets/loading_widget.dart';

class EditEmailScreen extends StatefulWidget {
  static const routeName = '/edit-email';

  const EditEmailScreen({Key? key}) : super(key: key);

  @override
  State<EditEmailScreen> createState() => _EditEmailScreenState();
}

class _EditEmailScreenState extends State<EditEmailScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    _emailController = TextEditingController(
      text: userProvider.user?.data?.user?.email ?? '',
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarApp(
        title: LocaleKeys.editEmail.tr(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.mail.tr(),
                  style: TextStyle(
                    color: ColorsPalette.black,
                    fontWeight: FontWeight.w400,
                    fontFamily: ZainTextStyles.font,
                    fontSize: 14.sp,
                  ),
                ),
                UtilValues.gap8,
                TextInputField(
                  padding: EdgeInsets.all(11.sp),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: UtilValues.borderRadius10,
                    borderSide: const BorderSide(
                      color: ColorsPalette.extraDarkGrey,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: UtilValues.borderRadius10,
                    borderSide: BorderSide(
                      color: ColorsPalette.extraDarkGrey,
                      width: 1,
                    ),
                  ),
                  color: ColorsPalette.darkGrey,
                  backgroundColor: ColorsPalette.white,
                  controller: _emailController,
                  inputType: TextInputType.emailAddress,
                  name: 'email',
                  key: const ValueKey('email'),
                  hint: 'example@example.com',
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.email(),
                  ]),
                ),
                UtilValues.gap32,
                SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _updateEmail(context),
                    style: ButtonStyle(
                      textStyle: MaterialStateProperty.all<TextStyle>(
                        TextStyle(
                          fontSize: 14.sp,
                          fontFamily: ZainTextStyles.font,
                        ),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: ColorsPalette.primaryColor,
                          ),
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(
                        ColorsPalette.primaryColor,
                      ),
                    ),
                    child: Center(
                      child: _isLoading
                          ? const LoadingWidget(color: ColorsPalette.white)
                          : Text(
                              LocaleKeys.save.tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ColorsPalette.white,
                                fontFamily: ZainTextStyles.font,
                                fontSize: 12.sp,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateEmail(BuildContext context) async {
    try {
      final formState = _formKey.currentState!;
      if (formState.saveAndValidate()) {
        setState(() => _isLoading = true);
        
        final userProvider = context.read<UserProvider>();
        
        // Update the email using the UserProvider's updateProfile method
        await userProvider.updateProfile(
          name: userProvider.user?.data?.user?.name ?? '',
          mail: _emailController.text,
          phone: userProvider.user?.data?.user?.phone ?? '',
          idImg: userProvider.user?.data?.user?.vendor?.idImage ?? '',
          companyLicenceImg: userProvider.user?.data?.user?.vendor?.companyLicenceImage ?? '',
          companyLicenceNo: userProvider.user?.data?.user?.vendor?.companyLicenceNo ?? '',
          companyLicenceExDate: userProvider.user?.data?.user?.vendor?.companyLicenceExpireDate ?? '',
          taxiNo: userProvider.user?.data?.user?.vendor?.taxNo ?? '',
          companyName: userProvider.user?.data?.user?.vendor?.name ?? '', // Use vendor.name instead of vendor.companyName
          address: userProvider.user?.data?.user?.vendor?.address ?? '',
          lat: double.tryParse(userProvider.user?.data?.user?.vendor?.lat ?? '0') ?? 0.0,
          long: double.tryParse(userProvider.user?.data?.user?.vendor?.lon ?? '0') ?? 0.0,
          locale: context.locale,
        );
        
        // Fetch fresh user data from the server to ensure all fields are updated
        final UserModel freshUserData = await UserApi.getUser(locale: context.locale);
        userProvider.user = freshUserData;
        userProvider.notifyListeners(); // Explicitly notify listeners to update UI

        showSnackbar(
          context: context,
          status: SnackbarStatus.success,
          message: LocaleKeys.profileUpdatedSuccessfully.tr(),
        );
        
        // Add a slight delay before navigation to ensure the user sees the success message
        await Future.delayed(const Duration(milliseconds: 500));
        
        Navigator.of(context).pop();
      }
    } catch (error) {
      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: error.toString(),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
