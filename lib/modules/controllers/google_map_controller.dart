import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapController extends GetxController {
  final Rxn<LatLng> currentPosition = Rxn<LatLng>();
  final Rxn<LatLng> searchedPosition = Rxn<LatLng>();
  GoogleMapController? mapController;
  final searchLocationController = TextEditingController();
  @override
  void onInit() {
    super.onInit();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;
    final Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition.value = LatLng(position.latitude, position.longitude);

    if (mapController != null && currentPosition.value != null) {
      await mapController!.animateCamera(CameraUpdate.newLatLngZoom(currentPosition.value!, 15));
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;

    // If we already have a position, move camera immediately
    if (currentPosition.value != null) {
      mapController!.animateCamera(CameraUpdate.newLatLngZoom(currentPosition.value!, 15));
    } else {
      _getCurrentLocation();
    }
  }

  void getLatAndLongFromTap(LatLng latLng) async {
    // You can use the latLng parameter to get the latitude and longitude of the tapped location
    debugPrint('Tapped location: Latitude: ${latLng.latitude}, Longitude: ${latLng.longitude}');
    await placemarkFromCoordinates(latLng.latitude, latLng.longitude).then((place) {
      debugPrint('Address: @@@@@@@@@@@@@@@@@@@@\n\n\n\n${place.first.street}, ${place.first.locality}, ${place.first.country}');
    });
  }

  Future<void> moveToSearchedLocation(LatLng latLng) async {
    searchedPosition.value = latLng;

    if (mapController != null) {
      await mapController!.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15), duration: const Duration(seconds: 1));
    }
  }

  Future<void> goToCurrentLocation() async {
    if (mapController != null && currentPosition.value != null) {
      await mapController!.animateCamera(CameraUpdate.newLatLngZoom(currentPosition.value!, 15));
    } else {
      await _getCurrentLocation();
    }
  }
}
