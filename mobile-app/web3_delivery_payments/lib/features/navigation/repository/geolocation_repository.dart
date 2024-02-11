import 'dart:async';

import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:web3_delivery_payments/common/models/direction_model.dart';
import 'package:web3_delivery_payments/env/env.dart';

class GeoLocationRepository {
  StreamController<Position>? _driverPositionStreamController;
  StreamSubscription? _driverPositionStream;

  Future<Position> getUserCurrentPosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // happens if permission is denied when asked for first time
        throw const PermissionDeniedException('Denied Temporarily');
      }
      if (permission == LocationPermission.deniedForever) {
        // happens if permission is denied when asked for 2nd time
        throw const PermissionDeniedException('Denied Permanently');
      }
    }

    // getting last known position
    var position = await Geolocator.getLastKnownPosition();

    // position can be null if there is no record of last known position
    // in that case perform a latest current position request
    if (position == null) {
      return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    }

    // check if last updated position time is more than an hour ago
    // if true update to latest current position
    if (position.timestamp != null &&
        position.timestamp!.millisecondsSinceEpoch <
            DateTime.now().millisecondsSinceEpoch - 3600000) {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    }

    return position;
  }

  Stream<Position> getUserCurrentPositionStream() async* {
    _driverPositionStreamController = StreamController<Position>();

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 50, // 50 meters
    );
    _driverPositionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      if (position != null) {
        _driverPositionStreamController?.add(position);
      }
    });
    yield* _driverPositionStreamController!.stream;
  }

  double calculateDistance({
    required double initialLatitude,
    required double initialLongitude,
    required double finalLatitude,
    required double finalLongitude,
  }) {
    return Geolocator.distanceBetween(
      initialLatitude,
      initialLongitude,
      finalLatitude,
      finalLongitude,
    );
  }

  Future<Direction> getDirection(
      LatLng startLocation, LatLng endLocation) async {
    var response = await Dio().get(
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=${Env.routeAPIKey}&start=${startLocation.longitude},${startLocation.latitude}&end=${endLocation.longitude},${endLocation.latitude}');

    Direction direction = Direction.fromJson(response.data);
    return direction;
  }

  Future<void> stopRealtimeDriverPositionUpdates() async {
    await _driverPositionStream?.cancel();
    await _driverPositionStreamController?.close();
  }
}
