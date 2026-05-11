import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ma7lola_vendor/core/generated/locale_keys.g.dart';
import 'package:ma7lola_vendor/core/utils/colors_palette.dart';
import 'package:ma7lola_vendor/core/widgets/form_widgets/primary_button/simple_primary_button.dart';
import 'package:ma7lola_vendor/view/screens/auth/additional_info_Id.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

// ignore: must_be_immutable
class MapScreen extends StatefulWidget {
  static String routeName = '/map';
  MapScreen({
    Key? key,
    required this.phone,
    required this.password,
    required this.name,
    required this.mail,
    required this.passwordConfirmation,
    required this.otp,
    required this.idImg,
    required this.idImgLic, 
    required this.taxNo,
    required this.address,
    required this.licenceExDate,
    required this.licenceNo,
    required this.image,
    required this.imageLic,
  }) : super(key: key);

  final String phone;
  final String password;
  final String name;
  final String mail;
  final String passwordConfirmation;
  final String otp;
  final String idImg;
  final String idImgLic;
  final String taxNo;
  final String address;
  final String? licenceExDate;
  final String licenceNo;
  final File? image;
  final File? imageLic;

  var latitude = 30.033333;
  var longitude = 31.233334;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  
  // Add a set of markers to track both current position and selected position
  final Set<Marker> _markers = {};
  
  // Track the center of the map as the selected position
  LatLng _selectedPosition = const LatLng(30.0444, 31.2357); // Cairo default

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    // Request location permission
    final status = await Permission.location.request();

    if (status.isGranted) {
      try {
        // Get current position
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        setState(() {
          _currentPosition = position;
          _selectedPosition = LatLng(position.latitude, position.longitude);
        });

        // Update the markers with the new position
        _updateMarkers();

        // Animate camera to current position if controller is available
        if (_mapController != null) {
          await _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 15.0,
              ),
            ),
          );
        }
      } catch (e) {
        print("Error getting location: $e");
      }
    }
  }
  
  // Helper method to update markers based on current and selected positions
  void _updateMarkers() {
    setState(() {
      _markers.clear();
      
      // Add marker for the selected position (center of map)
      _markers.add(
        Marker(
          markerId: const MarkerId('selectedPosition'),
          position: _selectedPosition,
          infoWindow: InfoWindow(
            title: "Selected Location",
            snippet: '${_selectedPosition.latitude}, ${_selectedPosition.longitude}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
      
      // Add marker for the current position (only if different from selected)
      if (_currentPosition != null) {
        final currentLatLng = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
        if (currentLatLng.latitude != _selectedPosition.latitude || 
            currentLatLng.longitude != _selectedPosition.longitude) {
          _markers.add(
            Marker(
              markerId: const MarkerId('currentPosition'),
              position: currentLatLng,
              infoWindow: InfoWindow(
                title: "Current Location",
                snippet: '${_currentPosition!.latitude}, ${_currentPosition!.longitude}',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            ),
          );
        }
      }
    });
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isDenied) {
      // Handle the case where the user denies permission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission is required')),
      );
    }
  }

  Future<bool> _doubleBackToExit(BuildContext context) async {
    Navigator.pop(context);
    return true;
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _doubleBackToExit(context),
      child: Scaffold(
        backgroundColor: ColorsPalette.white,
        body: SafeArea(
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _selectedPosition,
                  zoom: 15,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                  if (_currentPosition != null) {
                    _selectedPosition = LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    );
                    
                    controller.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: _selectedPosition,
                          zoom: 15,
                        ),
                      ),
                    );
                    
                    // Add marker for current position
                    _updateMarkers();
                  }
                },
                // Listen for camera movement to update the selected position
                onCameraMove: (CameraPosition position) {
                  setState(() {
                    _selectedPosition = position.target;
                  });
                },
                onCameraIdle: () {
                  // Update markers when camera stops moving
                  _updateMarkers();
                },
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
              ),
              Align(
                alignment: AlignmentDirectional.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 5.h,
                  ),
                  child: SimplePrimaryButton(
                    label: LocaleKeys.selectAddress.tr(),
                    width: 200.w,
                    height: 40,
                    onPressed: () {
                      // Always use the selected position from the map center
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return NationalIDCapture(
                            phone: widget.phone,
                            password: widget.password,
                            name: widget.name,
                            mail: widget.mail,
                            passwordConfirmation: widget.passwordConfirmation,
                            otp: widget.otp,
                            // Use the selected position instead of current position
                            long: _selectedPosition.longitude,
                            late: _selectedPosition.latitude,
                            idImg: widget.idImg,
                            idImgLic: widget.idImgLic,
                            taxNo: widget.taxNo,
                            address: widget.address,
                            licenceExDate: widget.licenceExDate,
                            licenceNo: widget.licenceNo,
                            image: widget.image,
                            imageLic: widget.imageLic,
                          );
                        }),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 5.h,
                right: 5.w,
                left: 5.w,
                child: Align(
                  alignment: AlignmentDirectional.topStart,
                  child: Card(
                    elevation: 5,
                    color: Colors.white,
                    child: IconButton(
                      onPressed: _getCurrentLocation,
                      icon: const Icon(
                        Icons.my_location,
                        color: ColorsPalette.darkGrey,
                      ),
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
