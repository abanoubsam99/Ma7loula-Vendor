import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ma7lola_vendor/controller/user_provider.dart';
import 'package:ma7lola_vendor/core/utils/helpers.dart';
import 'package:ma7lola_vendor/core/widgets/custom_card.dart';
import 'package:ma7lola_vendor/view/screens/main_screen/tabs/profile_tab/edit_address_screen.dart';
// Email editing functionality removed
// import 'package:ma7lola_vendor/view/screens/main_screen/tabs/profile_tab/edit_email_screen.dart';
import 'package:ma7lola_vendor/view/screens/main_screen/tabs/profile_tab/update_password_screen.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/generated/locale_keys.g.dart';
import '../../../../../core/utils/assets_manager.dart';
import '../../../../../core/utils/colors_palette.dart';
import '../../../../../core/utils/font.dart';
import '../../../../../core/utils/snackbars.dart';
import '../../../../../core/utils/util_values.dart';
import '../../../../../core/widgets/custom_app_bar.dart';
import '../../../../../core/services/secure_storage/secure_storage_keys.dart.dart';
import '../../../../../core/services/secure_storage/secure_storage_service.dart';

class EditProfileScreen extends StatefulWidget {
  static const routeName = '/edit-profile';

  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  int? _vendorId;

  @override
  void initState() {
    super.initState();
    _checkVendorType();
  }

  Future<void> _checkVendorType() async {
    final storedVendorId = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.vendorID);
    setState(() {
      _vendorId = int.tryParse(storedVendorId ?? '0');
    });
  }
  
  // Check if the vendor type is winch (ID 3) or emergency (ID 4)
  bool _isWinchOrEmergency() {
    return _vendorId == 3 || _vendorId == 4 || _vendorId == 61 || _vendorId == 62;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    return Scaffold(
      appBar: AppBarApp(),
      body: SingleChildScrollView(
        child: Padding(
          padding: UtilValues.padding16,
          child: FormBuilder(
            key: _formKey,
            child: Column(
              children: [
                SvgPicture.asset(
                  AssetsManager.userPic,
                  width: 80,
                ),
                UtilValues.gap8,
                Text(
                  userProvider.user != null
                      ? '${userProvider.user?.data?.user?.name}'
                      : LocaleKeys.userName.tr(),
                  style: const TextStyle(
                      color: ColorsPalette.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: ZainTextStyles.font),
                ),
                UtilValues.gap32,
                // Only show company license number, tax number, and company license for vendors that are not winch or emergency
                if (!_isWinchOrEmergency()) ...[                
                  _customCard(
                      LocaleKeys.licenceID.tr(),
                      '${userProvider.user?.data?.user?.vendor?.companyLicenceNo}',
                      AssetsManager.idbadge,
                      null,
                      () {}),
                  UtilValues.gap12,
                  _customCard(
                      LocaleKeys.taxNo.tr(),
                      '${userProvider.user?.data?.user?.vendor?.taxNo}',
                      AssetsManager.newspaper,
                      null,
                      () {}),
                  UtilValues.gap12,
                  _customCard(
                      LocaleKeys.licenceNo.tr(),
                      (userProvider.user?.data?.user?.vendor
                                      ?.companyLicenceImage !=
                                  null &&
                              (userProvider.user?.data?.user?.vendor
                                      ?.companyLicenceImage?.isNotEmpty ??
                                  false))
                          ? 'تم ارفاق الملف'
                          : "لم يتم ارفاق ملف",
                      AssetsManager.idCard,
                      null,
                      () {}),
                  UtilValues.gap12,
                ],
                // Only show address for vendors that are not winch or emergency
                if (!_isWinchOrEmergency()) ...[                
                  _customCard(
                      LocaleKeys.address.tr(),
                      '${userProvider.user?.data?.user?.vendor?.address}',
                      AssetsManager.location2,
                      null,
                      null),
                  UtilValues.gap12,
                ],
                _customCard(
                    LocaleKeys.mail.tr(),
                    userProvider.user?.data?.user?.email ?? '',
                    AssetsManager.email,
                    null,
                    null),
                UtilValues.gap12,
                _customCard(
                    LocaleKeys.phone.tr(),
                    '+2${userProvider.user?.data?.user?.phone}',
                    AssetsManager.phone,
                    null,
                    () {}),
                UtilValues.gap12,
                _customCard(LocaleKeys.password.tr(), null, AssetsManager.lock,
                    AssetsManager.angleLeft1, () {
                  Navigator.pushNamed(context, UpdatePasswordScreen.routeName);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _editProfile(BuildContext context) async {
    try {
      final formState = _formKey.currentState!;
      if (formState.saveAndValidate()) {
        final formData = Map<String, String>.from(formState.value);

        final userProvider = context.read<UserProvider>();

        setState(() => _isLoading = true);

        // await userProvider.editProfile(
        //   name: formData['name']!,
        //   email: formData['email']!,
        // );

        showSnackbar(
          context: context,
          status: SnackbarStatus.success,
          message: LocaleKeys.profileUpdatedSuccessfully.tr(),
        );

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

  _customCard(String name, String? data, String firstIcon, String? forwardIcon,
      Function()? onTap) {
    return InkWell(
      onTap: onTap,
      child: CustomCard(
        padding: EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorsPalette.extraDarkGrey),
        color: ColorsPalette.white,
        child: Row(
          children: [
            SvgPicture.asset(
              firstIcon,
              color: ColorsPalette.black,
            ),
            UtilValues.gap12,
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                      color: ColorsPalette.default2,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      fontFamily: ZainTextStyles.font),
                ),
                if (data != null)
                  Text(
                    data,
                    style: TextStyle(
                        color: ColorsPalette.black,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: ZainTextStyles.font),
                  ),
              ],
            )),
            if (Helpers.isArabic(context) && forwardIcon != null)
              SvgPicture.asset(forwardIcon)
            else if (forwardIcon != null)
              Transform(
                transform: Matrix4.rotationY(180 * 3.1415927 / 180),
                alignment: Alignment.center,
                child: SvgPicture.asset(forwardIcon),
              ),
          ],
        ),
      ),
    );
  }
}
