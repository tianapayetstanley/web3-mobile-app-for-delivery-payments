import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:web3_delivery_payments/features/navigation/bloc/navigation_bloc.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late GoogleMapController _mapController;
  final Completer<GoogleMapController> _controller = Completer();

  Future<void> _goToTheCurrentPositon(
      BuildContext context, LatLng position) async {
    _mapController = await _controller.future;
    _mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 15)));
    if (context.read<NavigationBloc>().state.latLngBounds !=
        LatLngBounds(
            southwest: const LatLng(0, 0), northeast: const LatLng(0, 0))) {
      _mapController.animateCamera(CameraUpdate.newLatLngBounds(
          context.read<NavigationBloc>().state.latLngBounds, 70));
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return GoogleMap(
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          myLocationEnabled: true,
          markers: state.markers,
          initialCameraPosition: CameraPosition(
            target: LatLng(
              state.currentUserPosition!.latitude,
              state.currentUserPosition!.longitude,
            ),
            zoom: 16,
          ),
          onMapCreated: (controller) async {
            setState(() {
              _mapController = controller;
            });
            _goToTheCurrentPositon(
                context,
                LatLng(state.currentUserPosition!.latitude,
                    state.currentUserPosition!.longitude));
          },
          polylines: context.read<NavigationBloc>().state.polyLines,
        );
      },
    );
  }
}
