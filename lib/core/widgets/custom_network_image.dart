import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';

class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final bool enableFullScreenViewer;

  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.enableFullScreenViewer = false,
  });

  // Helper method to ensure the URL is correctly formatted
  String _getValidImageUrl() {
    // For empty URLs, return placeholder
    if (imageUrl.isEmpty) {
      return 'https://via.placeholder.com/150';
    }
    
    // Create a copy of the URL to work with
    String processedUrl = imageUrl;
    
    try {
      // Special handling for product image URLs that are known to have issues
      if (processedUrl.contains('products/') && processedUrl.contains('.jpg')) {
        // Check if it's a full URL or relative path
        String baseUrl = '';
        String imagePath = processedUrl;
        
        if (processedUrl.startsWith('http')) {
          // Extract the domain and path parts
          final uri = Uri.parse(processedUrl);
          baseUrl = '${uri.scheme}://${uri.host}';
          imagePath = uri.path.startsWith('/') ? uri.path.substring(1) : uri.path;
        }
        
        // Get just the filename part
        final parts = imagePath.split('/');
        final filename = parts.last;
        
        // Check if the filename appears twice (e.g., in path and again at the end)
        int filenameCount = 0;
        for (final part in parts) {
          if (part == filename) filenameCount++;
        }
        
        if (filenameCount > 1 || imagePath.contains('$filename/$filename')) {
          // Reconstruct the correct path - find the path up to the storage/products part
          String correctPath = '';
          
          if (imagePath.contains('storage/products/')) {
            final pathParts = imagePath.split('storage/products/');
            if (pathParts.length > 1) {
              // Get just the filename without any duplicated path
              final filenameParts = pathParts[1].split('/');
              correctPath = 'storage/products/${filenameParts.last}';
            }
          } else if (imagePath.startsWith('products/')) {
            final pathParts = imagePath.split('products/');
            if (pathParts.length > 1) {
              // Get just the filename without any duplicated path
              final filenameParts = pathParts[1].split('/');
              correctPath = 'products/${filenameParts.last}';
            }
          }
          
          // If we successfully extracted a correct path
          if (correctPath.isNotEmpty) {
            if (baseUrl.isNotEmpty) {
              // Full URL case
              processedUrl = '$baseUrl/$correctPath';
            } else {
              // Relative path case
              processedUrl = correctPath;
            }
            print('Fixed URL: "$processedUrl" (was: "$imageUrl")');
          }
        }
      }
      // General case for any URL with extension duplication
      else if (processedUrl.startsWith('http://') || processedUrl.startsWith('https://')) {
        final Uri uri = Uri.parse(processedUrl);
        final String path = uri.path;
        
        for (final ext in ['.jpg', '.png', '.jpeg', '.gif']) {
          if (path.contains('$ext/')) {
            // Get the part after the extension
            final parts = path.split('$ext/');  
            if (parts.length > 1 && parts[1].isNotEmpty) {
              // If there's duplication, remove the duplicate part
              final correctedPath = path.substring(0, path.indexOf('$ext/') + ext.length);
              processedUrl = '${uri.origin}$correctedPath';
              print('Fixed URL: "$processedUrl" (was: "$imageUrl")');
              break;
            }
          }
        }
      }
      // Relative path without domain
      else if (!processedUrl.startsWith('http')) {
        // Check for extension duplication in relative paths
        for (final ext in ['.jpg', '.png', '.jpeg', '.gif']) {
          if (processedUrl.contains('$ext/')) {
            // Get the part after the extension
            final parts = processedUrl.split('$ext/');  
            if (parts.length > 1 && parts[1].isNotEmpty) {
              // If there's duplication, remove the duplicate part
              processedUrl = processedUrl.substring(0, processedUrl.indexOf('$ext/') + ext.length);
              print('Fixed relative URL: "$processedUrl" (was: "$imageUrl")');
              break;
            }
          }
        }
        
        // Add domain if it's just a filename/path
        processedUrl = 'https://api.ma7loula.com/storage/$processedUrl';
      }
    } catch (e) {
      print('Error fixing URL "$imageUrl": $e');
      // In case of any error, return the original URL
      return imageUrl;
    }
    
    return processedUrl;
  }

  @override
  Widget build(BuildContext context) {
    final validUrl = _getValidImageUrl();
    
    return GestureDetector(
      onTap: enableFullScreenViewer
          ? () {
        showImageViewer(
          context,
          CachedNetworkImageProvider(validUrl),
        );
      }
          : null,
      child: CachedNetworkImage(
        imageUrl: validUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
        ),
      ),
    );
  }
}
