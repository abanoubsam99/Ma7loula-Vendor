import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'dart:convert';

import '../../../../../../controller/products_provider.dart';
import '../../../../../../core/generated/locale_keys.g.dart';
import '../../../../../../core/utils/assets_manager.dart';
import '../../../../../../core/utils/colors_palette.dart';
import '../../../../../../core/utils/font.dart';
import '../../../../../../core/utils/util_values.dart';
import '../../../../../../core/widgets/custom_app_bar.dart';
import '../../../../../../core/widgets/custom_network_image.dart';
import '../../../../../../core/widgets/form_widgets/primary_button/simple_primary_button.dart';
import '../../../../../../model/products_model.dart';

class ProductDetailsScreen extends StatefulWidget {
  Products product;
  ProductDetailsScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProductDetailsScreenState();
  }
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  // Completely revised helper method to get clean product image URLs
  String _getCleanProductImageUrl(String url) {
    if (url.isEmpty) return url;
    
    try {
      // Handle full URLs (with http/https protocol)
      if (url.startsWith('http')) {
        // Extract the filename - this is the most important part
        final Uri uri = Uri.parse(url);
        final String path = uri.path;
        
        // For product image URLs, get just the filename
        if (path.contains('/products/')) {
          final String filename = path.split('/').last;
          
          // Create a completely new clean URL with just the base domain and filename
          final String baseUrl = '${uri.scheme}://${uri.host}';
          final String cleanUrl = '$baseUrl/storage/products/$filename';
          
          return cleanUrl;
        }
        return url; // Return original URL if not a product URL
      } 
      // Handle relative paths
      else if (url.contains('products/')) {
        // Extract just the filename
        final String filename = url.split('/').last;
        
        // Create a clean path
        return 'products/$filename';
      }
    } catch (e) {
      print('Product Details - Error cleaning image URL: $e');
    }
    
    return url;
  }
  
  // Original helper method - keep for legacy support
  String _fixImageUrl(String url) {
    return _getCleanProductImageUrl(url);
  }
  
  @override
  void initState() {
    super.initState();
    // Print all product details for debugging
    print('\n\n======== PRODUCT DETAILS DEBUG ========');
    print('Product ID: ${widget.product.id}');
    print('Product Name: ${widget.product.name}');
    print('Product Description: ${widget.product.description}');
    print('Product SKU: ${widget.product.description}'); // Currently using description as SKU
    print('Product Stock: ${widget.product.stock}');
    print('Product Status: ${widget.product.status}');
    print('Product Price: ${widget.product.price}');
    print('Product Price Before Discount: ${widget.product.priceBeforeDiscount}');
    print('Product Brand: ${widget.product.brand?.name}');
    print('Product Category: ${widget.product.category?.name}');
    print('Product Vendor: ${widget.product.vendor?.name}');
    print('Product Images Count: ${widget.product.images?.length ?? 0}');
    print('Product Thumbnail: ${widget.product.thumbnail?.url}');
    print('======================================\n\n');
    
    // Print the complete product object for debugging
    print('\n\n======== COMPLETE PRODUCT OBJECT ========');
    print(widget.product.toJson());
    print('======================================\n\n');
    
    // Try to get more diagnostic info by printing JSON representation
    try {
      print('\n\n======== RAW JSON REPRESENTATION ========');
      print(jsonEncode(widget.product.toJson()));
      print('======================================\n\n');
    } catch (e) {
      print('Error converting product to JSON: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductsProvider>();

    return Scaffold(
      appBar: AppBarApp(
        title: widget.product.name ?? '',
        actions: [
          // UtilValues.gap8,
          // SvgPicture.asset(AssetsManager.share),
          // UtilValues.gap8,
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _images(widget.product.images ?? []),
            UtilValues.gap16,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.product.brand?.name ?? '-',
                  style: const TextStyle(
                      color: ColorsPalette.customGrey,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: ZainTextStyles.font),
                ),
                Spacer(),
              ],
            ),
            UtilValues.gap8,
            Text(
              widget.product.name ?? '',
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: ColorsPalette.black,
                  fontFamily: ZainTextStyles.font),
              textAlign: TextAlign.center,
              //maxLines: 3,
            ),
            UtilValues.gap8,
            Row(
              children: [
                if (widget.product.priceBeforeDiscount > 0) ...[
                  Text(
                    widget.product.priceBeforeDiscount.toString(),
                    style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        decorationColor: ColorsPalette.red,
                        color: ColorsPalette.red,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: ZainTextStyles.font),
                  ),
                ],
                UtilValues.gap4,
                Text(
                  widget.product.price.toString(),
                  style: TextStyle(
                    color: ColorsPalette.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                UtilValues.gap4,
                Text(
                  LocaleKeys.le.tr(),
                  style: TextStyle(
                    color: ColorsPalette.customGrey,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            UtilValues.gap12,
            Text(
              widget.product.description ?? "-----",
              style: TextStyle(
                  color: ColorsPalette.customGrey,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  fontFamily: ZainTextStyles.font),
            ),
            UtilValues.gap12,
            Divider(),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              margin: EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: ColorsPalette.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: ColorsPalette.primaryColor, size: 20),
                        SizedBox(width: 8),
                        Text('Product Details',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                              color: ColorsPalette.primaryColor,
                            )),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    child: Column(
                      children: _buildProductDetailRows(),
                    ),
                  ),
                ],
              ),
            ),
            // Removed UtilValues.gap8 after the Card



            
            Spacer(),
            // Row(
//   children: [
//     Expanded(
//       child: SimplePrimaryButton(
//         borderRadius: BorderRadius.circular(5),
//         label: LocaleKeys.requestToEdit.tr(),
//         onPressed: () {},
//       ),
//     ),
//     UtilValues.gap8,
//     Expanded(
//       child: SimplePrimaryButton(
//         borderRadius: BorderRadius.circular(5),
//         label: LocaleKeys.requestToDelete.tr(),
//         backgroundColor: ColorsPalette.lightGrey,
//         labelColor: ColorsPalette.customGrey,
//         onPressed: () {},
//       ),
//     ),
//     SizedBox(
//       height: 100,
//     )
//   ],
// )
          ],
        ),
      ),
    );
  }

  List<Widget> _buildProductDetailRows() {
    final List<Widget> rows = [];
    void addRow(String label, String? value) {
      if (value != null && value.isNotEmpty) {
        if (rows.isNotEmpty) rows.add(Divider(height: 18));
        rows.add(_detailRow(label, value));
      }
    }
    addRow('ID', widget.product.id?.toString());
    addRow('SKU', widget.product.description);
    addRow('Stock', widget.product.stock?.toString());
    addRow('Status', widget.product.status);
    addRow('Category', widget.product.category?.name);
    addRow('Vendor', widget.product.vendor?.name);
    return rows;
  }

  Widget _detailRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5.sp, color: ColorsPalette.customGrey),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 12.5.sp, color: ColorsPalette.darkGrey),
          ),
        ),
      ],
    );
  }

  _images(List<Thumbnail> sliders) {
    if (sliders.isEmpty) {
      return SizedBox(
        height: 30.h,
        child: Center(child: Text('No image available')),
      );
    }
    
    // If there's only one image, show it directly
    if (sliders.length == 1) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 4.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: CachedNetworkImage(
                  imageUrl: _fixImageUrl(sliders.first.url ?? ''),
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    // If there are multiple images, use carousel slider
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 30.h,
              viewportFraction: 0.9,
              initialPage: 0,
              enableInfiniteScroll: sliders.length > 1,
              reverse: false,
              autoPlay: sliders.length > 1,
              autoPlayInterval: Duration(seconds: 5),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: true,
              scrollDirection: Axis.horizontal,
            ),
            items: sliders.map((item) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: CachedNetworkImage(
                        imageUrl: _fixImageUrl(item.url ?? ''),
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
          // Indicator dots for the carousel
          if (sliders.length > 1)
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: sliders.asMap().entries.map((entry) {
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorsPalette.primaryColor.withOpacity(
                        entry.key == 0 ? 0.9 : 0.4, // Start with first slide highlighted
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
}
