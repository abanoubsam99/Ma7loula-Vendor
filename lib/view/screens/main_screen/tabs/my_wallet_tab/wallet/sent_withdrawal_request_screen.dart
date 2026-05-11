import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../controller/user_provider.dart';
import '../../../../../../core/generated/locale_keys.g.dart';
import '../../../../../../core/services/http/apis/miscellaneous_api.dart';
import '../../../../../../core/utils/assets_manager.dart';
import '../../../../../../core/utils/colors_palette.dart';
import '../../../../../../core/utils/font.dart';
import '../../../../../../core/utils/helpers.dart';
import '../../../../../../core/utils/snackbars.dart';
import '../../../../../../core/utils/util_values.dart';
import '../../../../../../core/widgets/custom_app_bar.dart';
import '../../../../../../core/widgets/form_widgets/text_input_field.dart';
import '../../../../../../model/winch/my_transactions_model.dart';
import '../../../../../../model/winch/withdrawal_methods_model.dart';
import '../../../main_screen.dart';

class SentWithdrawalRequestScreen extends StatefulWidget {
  SentWithdrawalRequestScreen({
    Key? key,
  }) : super(key: key);
  @override
  State<SentWithdrawalRequestScreen> createState() =>
      _SentWithdrawalRequestScreenState();
}

class _SentWithdrawalRequestScreenState
    extends State<SentWithdrawalRequestScreen> {
  final _numberOfPostsPerRequest = 20;
  var _valueController = TextEditingController();
  String? _isChangeDropDownBrands;
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          Helpers.isArabic(context) ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBarApp(
          title: LocaleKeys.sentWithdrawalRequest.tr(),
        ),
        backgroundColor: ColorsPalette.lightGrey,
        bottomNavigationBar: _btn(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: ColorsPalette.primaryLightColor,
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  SvgPicture.asset(
                    AssetsManager.wallet,
                    color: ColorsPalette.primaryColor,
                    width: 15,
                    height: 15,
                  ),
                  UtilValues.gap8,
                  Text(
                    LocaleKeys.currentBalance.tr(),
                    style: TextStyle(
                        color: ColorsPalette.black,
                        fontWeight: FontWeight.w400,
                        fontFamily: ZainTextStyles.font,
                        fontSize: 12.sp),
                  ),
                  Spacer(),
                  FutureBuilder<MyTransactionsModel>(
                      future: MiscellaneousApi.getMyTransactions(
                        locale: context.locale,
                        page: 1,
                        perPage: _numberOfPostsPerRequest,
                      ),
                      builder: (context, snapshot) {
                        final userProvider = context.read<UserProvider>();

                        if (!userProvider.isLoggedIn) {
                          return const SizedBox.shrink();
                        }
                        if (snapshot.data == null) {
                          return const SizedBox.shrink();
                        }

                        final banners = snapshot.data!;

                        if (banners.data == null) {
                          return const SizedBox.shrink();
                        }

                        return Text(
                          '${banners.data?.balance.toString()} ${LocaleKeys.le.tr()}',
                          style: TextStyle(
                              color: ColorsPalette.black,
                              fontWeight: FontWeight.w400,
                              fontFamily: ZainTextStyles.font,
                              fontSize: 12.sp),
                        );
                      }),
                ],
              ),
            ),
            UtilValues.gap12,
            _valueWidget(),
            UtilValues.gap12,
            _buildDropDownBrands()
          ],
        ),
      ),
    );
  }

  _valueWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.requiredValue.tr(),
            style: TextStyle(
                color: ColorsPalette.black,
                fontWeight: FontWeight.w400,
                fontFamily: ZainTextStyles.font,
                fontSize: 12.sp),
          ),
          UtilValues.gap2,
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
            controller: _valueController,
            inputType: TextInputType.number,
            name: LocaleKeys.enterDesiredValue.tr(),
            key: const ValueKey('name'),
            hint: LocaleKeys.enterDesiredValue.tr(),
            validator: FormBuilderValidators.required(),
          ),
        ],
      ),
    );
  }

  Widget _buildDropDownBrands() {
    return FutureBuilder<WithdrawalMethodsModel>(
      future: MiscellaneousApi.getWithdrawalMethods(locale: context.locale),
      builder: (context, brand) {
        if (brand.data != null &&
            (brand.data?.data?.methods?.isNotEmpty ?? false)) {
          // Validate if current value exists in the items list
          final methods = brand.data?.data?.methods ?? [];
          if (_isChangeDropDownBrands != null &&
              !methods.contains(_isChangeDropDownBrands)) {
            _isChangeDropDownBrands = null; // Reset if value is invalid
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.withdrawalMethod.tr(),
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
                  child: DropdownButtonFormField<String>(
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
                      color: ColorsPalette.primaryColor,
                    ),
                    alignment: Alignment.center,
                    hint: Text(
                      LocaleKeys.choose.tr(),
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
                    onChanged: (String? newValue) {
                      setState(() {
                        _isChangeDropDownBrands = newValue;
                      });
                    },
                    items: methods.map((String method) {
                      return DropdownMenuItem<String>(
                        value: method,
                        child: Text(
                          method,
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
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  _btn() {
    return Container(
      margin: EdgeInsets.all(10.sp),
      height: 6.h,
      child: ElevatedButton(
        onPressed: () async {
          final userProvider = context.read<UserProvider>();
          if (userProvider.isLoggedIn) {
            try {
              if (_valueController.text.isNotEmpty &&
                  _isChangeDropDownBrands != null &&
                  (_isChangeDropDownBrands?.isNotEmpty ?? false))
                await MiscellaneousApi.sentWithdrawalMethod(
                    locale: context.locale,
                    amount: int.tryParse(_valueController.text) ?? 0,
                    method: _isChangeDropDownBrands ?? '');
              showSnackbar(
                context: context,
                status: SnackbarStatus.success,
                message: LocaleKeys.done.tr(),
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MainScreen(
                          index: 1,
                          myWalletIndex: 1,
                        )),
              );
            } catch (e) {
              showSnackbar(
                  context: context,
                  status: SnackbarStatus.error,
                  message: e.toString());
            }
            // Navigator.pushNamed(context, AddCarPartScreen.routeName);
          } else {
            showSnackbar(
              context: context,
              status: SnackbarStatus.info,
              message: LocaleKeys.shouldLogin.tr(),
            );
          }
        },
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
          child: Text(
            LocaleKeys.submit.tr(),
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
}
