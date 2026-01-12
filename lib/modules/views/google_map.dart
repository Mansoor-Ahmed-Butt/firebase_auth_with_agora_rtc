import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sign_in_google_with_agora/modules/controllers/google_map_controller.dart';
import 'package:sign_in_google_with_agora/widgets/common/custom_text_field.dart';

class MapView extends GetView<MapController> {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => Padding(
          padding: const EdgeInsets.all(8.0),
          child: controller.currentPosition.value == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(target: controller.currentPosition.value ?? const LatLng(0, 0), zoom: 15),
                      onMapCreated: controller.onMapCreated,
                      onTap: (position) => controller.getLatAndLongFromTap(position),
                      markers: {
                        Marker(
                          markerId: const MarkerId('currentLocation'),
                          position: controller.currentPosition.value!,
                          infoWindow: const InfoWindow(title: 'You are here'),
                        ),
                        if (controller.searchedPosition.value != null)
                          Marker(
                            markerId: const MarkerId('searchedLocation'),
                            position: controller.searchedPosition.value!,
                            infoWindow: const InfoWindow(title: 'Searched location'),
                          ),
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: true,
                      mapType: MapType.terrain,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CustomAppTextField(
                        borderSideColor: Colors.grey,
                        onSubmitted: (value) async {
                          if (value.isEmpty) return;
                          final locations = await locationFromAddress(value);
                          if (locations.isEmpty) return;
                          final l = locations.first;
                          final latLng = LatLng(l.latitude, l.longitude);
                          await controller.moveToSearchedLocation(latLng);
                        },

                        fillColor: Colors.grey.shade200,
                        controller: controller.searchLocationController,
                        hint: 'Address or lat,lng',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16, // or wherever you want
                      child: FloatingActionButton(
                        backgroundColor: Colors.grey.shade200,
                        onPressed: () {
                          controller.goToCurrentLocation();
                        },
                        child: Icon(Icons.my_location, color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
