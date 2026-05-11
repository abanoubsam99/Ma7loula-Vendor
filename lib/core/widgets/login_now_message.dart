import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ma7lola_vendor/core/generated/locale_keys.g.dart';
import 'package:ma7lola_vendor/core/widgets/message_widget.dart';

import '../../view/screens/auth/choose_vendor_type.dart';
import '../utils/colors_palette.dart';

class LoginNowMessage extends StatelessWidget {
  const LoginNowMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return MessageWidget(
      iconColor: ColorsPalette.darkGrey,
      icon: Icons.person_pin,
      message: LocaleKeys.loginToStartManagingOrders.tr(),
      actionButtonLabel: LocaleKeys.login.tr(),
      onActionButtonTapped: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ChooseVendorType(
            isIntroScreen: true,
          );
        }));
      },
    );
  }
}
