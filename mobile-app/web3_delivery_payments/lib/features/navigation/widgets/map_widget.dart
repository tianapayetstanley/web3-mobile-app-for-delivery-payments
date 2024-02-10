import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late GoogleMapController _mapController;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      myLocationEnabled: true,
      // markers: markers.toSet(),
      initialCameraPosition: CameraPosition(
        target: LatLng(37.42796133580664, -122.085749655962),
        zoom: 16,
      ),
      onMapCreated: (controller) async {
        setState(() {
          _mapController = controller;
        });
        // added to remove black color happening on the map when
        // it initializes
        if (Platform.isAndroid) {
          await Future.delayed(const Duration(milliseconds: 150));
        }
        if (mounted) {
          // context
          //     .read<NavigationBloc>()
          //     .add(const SetIsMapReady(isMapReady: true));
        }
      },
      onCameraMove: (CameraPosition cp) {},
      onCameraIdle: () async {},
    );
  }
}
