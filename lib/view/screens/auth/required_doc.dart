import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:ma7lola_vendor/core/utils/font.dart';
import 'package:ma7lola_vendor/core/widgets/custom_card.dart';
import 'package:ma7lola_vendor/view/screens/auth/SignUpForm.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher_string.dart' show launchUrlString, canLaunchUrlString;
import '../../../core/services/secure_storage/secure_storage_keys.dart.dart';
import '../../../core/services/secure_storage/secure_storage_service.dart';

import '../../../core/generated/locale_keys.g.dart';
import '../../../core/services/http/apis/miscellaneous_api.dart';
import '../../../core/utils/assets_manager.dart';
import '../../../core/utils/colors_palette.dart';
import '../../../core/utils/util_values.dart';
import '../../../core/widgets/form_widgets/ternary_button.dart';
import '../../../model/requirements_doc_model.dart';

class RequiredDoc extends StatefulWidget {
  static const String routeName = '/RequiredDoc';

  RequiredDoc({Key? key}) : super(key: key);

  @override
  State<RequiredDoc> createState() => _RequiredDocState();
}

class _RequiredDocState extends State<RequiredDoc> {
  // Variable to store the vendor type
  int? _vendorType;
  
  @override
  void initState() {
    super.initState();
    _checkVendorType();
  }

  // Check which vendor type is selected
  Future<void> _checkVendorType() async {
    final storedVendorId = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.vendorID);
    
    setState(() {
      _vendorType = int.tryParse(storedVendorId ?? '0');
    });
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: ColorsPalette.lighttGrey,
            image: DecorationImage(
              fit: BoxFit.fill,
              colorFilter: ColorFilter.mode(ColorsPalette.light.withOpacity(.9), BlendMode.lighten),
              image: AssetImage(AssetsManager.backgroundLogo),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
              UtilValues.gap24,
              Center(
                child: Text(
                  LocaleKeys.requiredDoc.tr(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontFamily: ZainTextStyles.font, fontSize: 22.sp),
                ),
              ),
              UtilValues.gap32,

              Expanded(
                child: FutureBuilder<RequirementsDoc>(
                    future: MiscellaneousApi.getRequirementsDoc(locale: context.locale),
                    builder: (context, snapshot) {
                      if (snapshot.data == null) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: ColorsPalette.primaryColor,
                          ),
                        );
                      }
                      final reqDoc = snapshot.data!;

                      if (reqDoc.data == null) {
                        return SizedBox.shrink();
                      }
                      // Create a list that will hold all requirements
                      final requirements = List<Widget>.from(
                        (reqDoc.data?.requirements ?? []).map(
                          (doc) => _requiredDocCard(doc.title ?? '', doc.body ?? ''),
                        ),
                      );
                          
                      // For vendor type 3 (Rescue Winch), add special requirements
                      if (_vendorType == 3) {
                        final isEnglish = context.locale.languageCode == 'en';
                        
                        // 1. Company Code requirement
                        final companyCodeTitle = isEnglish 
                            ? "Company Code" 
                            : "كود الشركة";
                        
                        final companyCodeDescription = isEnglish
                            ? "You must provide your company code to work as a winch driver. This code is obtained by registering with an authorized winch service company."
                            : "يجب تقديم كود الشركة الخاص بك للعمل كسائق سطحة. يتم الحصول على هذا الكود من خلال التسجيل في شركة معتمدة لخدمات السطحات.";
                        
                        // 2. Car License Plate Number requirement
                        final carPlateTitle = isEnglish
                            ? "Car License Plate Number"
                            : "رقم لوحة السيارة";
                            
                        final carPlateDescription = isEnglish
                            ? "You must provide your vehicle's license plate number for registration. This helps us verify that your vehicle meets the requirements for winch service."
                            : "يجب تقديم رقم لوحة سيارتك للتسجيل. يساعدنا ذلك في التحقق من أن سيارتك تلبي متطلبات خدمة السطحة.";

                        // 3. Criminal Record File requirement
                        final criminalRecordTitle = isEnglish
                            ? "Criminal Record File"
                            : "ملف الفيش";
                            
                        final criminalRecordDescription = isEnglish
                            ? "You must provide a recent criminal record document (background check). This is required to ensure the safety and security of our customers."
                            : "يجب تقديم مستند فيش جنائي حديث. هذا مطلوب لضمان سلامة وأمن عملائنا.";

                        // Add all special requirements for Winch
                        requirements.add(_requiredDocCard(companyCodeTitle, companyCodeDescription));
                        requirements.add(_requiredDocCard(carPlateTitle, carPlateDescription));
                        requirements.add(_requiredDocCard(criminalRecordTitle, criminalRecordDescription));
                      }
                      
                      return ListView.separated(
                        separatorBuilder: (context, index) {
                          return UtilValues.gap12;
                        },
                        itemCount: requirements.length,
                        itemBuilder: (context, index) {
                          return requirements[index];
                        },
                      );
                    }),
              ),
              // Spacer(),
              _changePasswordButton(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    LocaleKeys.didntHaveDoc.tr(),
                    style: TextStyle(
                        color: ColorsPalette.black,
                        fontWeight: FontWeight.w600,
                        fontFamily: ZainTextStyles.font,
                        fontSize: 10.sp),
                  ),
                  TernaryButton(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      label: LocaleKeys.contactUs.tr(),
                      underLine: true,
                      onTap: () async {
                        // Format: https://wa.me/<phone_number_with_country_code>
                        // For Egypt: +20 + phone number without leading 0
                        final phoneNumber = "01114051954";
                        final formattedNumber = phoneNumber.startsWith("0") ? 
                            "20${phoneNumber.substring(1)}" : "20$phoneNumber";
                        
                        final whatsappUrl = "https://wa.me/$formattedNumber";
                        if (await canLaunchUrlString(whatsappUrl)) {
                          await launchUrlString(whatsappUrl);
                        } else {
                          // Fallback to regular phone call if WhatsApp can't be launched
                          await launchUrlString("tel://$phoneNumber");
                        }
                      }),
                ],
              ),
              UtilValues.gap16
            ]),
          ),
        ),
      ),
    );
  }

  _changePasswordButton() {
    return Container(
      margin: EdgeInsets.all(1.sp),
      height: 6.h,
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, RegisterScreen.routeName),
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
          backgroundColor: MaterialStateProperty.all<Color>(ColorsPalette.primaryColor),
        ),
        child: Center(
          child: Text(
            LocaleKeys.createAccount.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: ColorsPalette.white, fontFamily: ZainTextStyles.font, fontSize: 12.sp),
          ),
        ),
      ),
    );
  }

  _requiredDocCard(String title, String description) {
    return CustomCard(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        color: ColorsPalette.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                  color: ColorsPalette.black, fontWeight: FontWeight.w700, fontFamily: ZainTextStyles.font, fontSize: 12.sp),
            ),
            Text(
              description,
              style: TextStyle(
                  color: ColorsPalette.customGrey, fontWeight: FontWeight.w500, fontFamily: ZainTextStyles.font, fontSize: 10.sp),
            ),
          ],
        ));
  }
}
