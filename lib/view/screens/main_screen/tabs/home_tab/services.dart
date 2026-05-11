import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/utils/colors_palette.dart';
import '../../../../../core/utils/font.dart';

class Services extends StatefulWidget {
  String? image;
  String title;
  double? height;
  final VoidCallback onTap;

  Services(
      {Key? key,
      required this.image,
      required this.title,
      this.height,
      required this.onTap})
      : super(key: key);

  @override
  State<Services> createState() => _ServicesState();
}

class _ServicesState extends State<Services> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          margin: EdgeInsets.only(
            left: 4.sp,
            right: 4.sp,
          ),
          // padding: EdgeInsets.only(left: 5.sp, right: 5.sp,),
          child: Stack(
            children: [
              InkResponse(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: widget.image ??
                        'https://i.ibb.co/Hz0q8H9/Rectangle-40-1.png',
                    fit: BoxFit.cover,
                    height: widget.height ?? 15.h,
                    width: double.maxFinite,
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        ColorsPalette.black.withOpacity(0.7),
                        ColorsPalette.black.withOpacity(0.7),
                        ColorsPalette.primaryColor.withOpacity(.7)
                      ],
                    ),
                  ),
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      widget.title,
                      style: TextStyle(
                          color: ColorsPalette.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: ZainTextStyles.font,
                          fontSize: 13.sp),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
