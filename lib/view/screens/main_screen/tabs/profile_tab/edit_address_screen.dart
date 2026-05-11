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

class EditAddressScreen extends StatefulWidget {
  static const routeName = '/edit-address';

  const EditAddressScreen({Key? key}) : super(key: key);

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    _addressController = TextEditingController(
      text: userProvider.user?.data?.user?.vendor?.address ?? '',
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarApp(
        title: LocaleKeys.editAddress.tr(),
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
                  LocaleKeys.address.tr(),
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
                  controller: _addressController,
                  inputType: TextInputType.streetAddress,
                  maxLines: 3,
                  name: 'address',
                  key: const ValueKey('address'),
                  hint: LocaleKeys.enterYourAddress.tr(),
                  validator: FormBuilderValidators.required(),
                ),
                UtilValues.gap16,
                // Map option
                GestureDetector(
                  onTap: () {
                    _openMap(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.sp),
                    decoration: BoxDecoration(
                      color: ColorsPalette.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: ColorsPalette.extraDarkGrey),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.map, color: ColorsPalette.primaryColor),
                        SizedBox(width: 10),
                        Text(
                          LocaleKeys.chooseFromMap.tr(),
                          style: TextStyle(
                            color: ColorsPalette.primaryColor,
                            fontWeight: FontWeight.w500,
                            fontFamily: ZainTextStyles.font,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                UtilValues.gap32,
                SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _updateAddress(context),
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

  void _openMap(BuildContext context) {
    // Here you would navigate to your map screen to allow the user to select a location
    // Since map_screen.dart is already implemented in your project, you could adapt it for this purpose
    // Navigator.pushNamed(context, MapScreen.routeName);
    
    // For this example, we'll just show a message that this feature will be available soon
    showSnackbar(
      context: context,
      status: SnackbarStatus.info,
      message: 'Map selection will be available soon',
    );
  }

  void _updateAddress(BuildContext context) async {
    try {
      final formState = _formKey.currentState!;
      if (formState.saveAndValidate()) {
        setState(() => _isLoading = true);
        
        final userProvider = context.read<UserProvider>();
        
        // Use the dedicated updateAddress method which is simpler and more targeted
        await userProvider.updateAddress(
          address: _addressController.text,
          lat: double.tryParse(userProvider.user?.data?.user?.vendor?.lat ?? '0') ?? 0.0,
          long: double.tryParse(userProvider.user?.data?.user?.vendor?.lon ?? '0') ?? 0.0,
          locale: context.locale,
        );
        
        // The updateAddress method already updates the UserModel and calls notifyListeners()

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
