import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
import 'package:web3_delivery_payments/common/models/checkpoint_model.dart';
import 'package:web3_delivery_payments/common/models/direction_model.dart';
import 'package:web3_delivery_payments/common/models/failure_model.dart';
import 'package:web3_delivery_payments/common/repositories/smart_contract_repository.dart';
import 'package:web3_delivery_payments/features/navigation/repository/geolocation_repository.dart';
import 'package:web3_delivery_payments/utils/helper_functions.dart';
import 'package:web3_delivery_payments/utils/image_util.dart';

part 'navigation_event.dart';
part 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  final GeoLocationRepository _geoLocationRepository;
  final SmartContractRepository _smartContractRepository;

  Uint8List? driverIcon;

  NavigationBloc(
      {GeoLocationRepository? geoLocationRepository,
      SmartContractRepository? smartContractRepository})
      : _geoLocationRepository =
            geoLocationRepository ?? GeoLocationRepository(),
        _smartContractRepository =
            smartContractRepository ?? SmartContractRepository(),
        super(NavigationState.initial()) {
    on<GetCurrentPosition>(_onGetCurrentPosition);
    on<DriverPositionChanged>(_onDriverPositionChanged);
    on<CompleteDelivery>(_onCompleteDelivery);
  }
  Future<void> _onGetCurrentPosition(
    GetCurrentPosition event,
    Emitter<NavigationState> emit,
  ) async {
    try {
      emit(
        state.copyWith(geoStatus: GeoStatus.loading),
      );
      var geoLocationError = '';
      late Position position;

      final markers = <Marker>{};

      var geoStatus = GeoStatus.initial;

      try {
        position = await _geoLocationRepository.getUserCurrentPosition();
      } catch (e) {
        if (e is LocationServiceDisabledException) {
          geoLocationError =
              'Location service is disabled. Please enable location service'
              " so that we can show you where you need to go";
          geoStatus = GeoStatus.serviceDisabled;
        } else if (e is PermissionDeniedException) {
          if (e.message == 'Denied Permanently') {
            geoLocationError =
                'Location service is disabled. Please enable location service'
                " so that we can show you where you need to go";
            geoStatus = GeoStatus.permissionDeniedPermanently;
          } else {
            geoLocationError =
                'Location service is disabled. Please enable location service'
                " so that we can show you where you need to go";
            geoStatus = GeoStatus.permissionDenied;
          }
        } else {
          geoLocationError = e.toString();
          geoStatus = GeoStatus.permissionDenied;
        }
      }
      LatLngBounds? myLatLongBounds;
      List<LatLng> myPolyPoints = [];
      Set<Polyline> myPolyLines = {};
      List<Checkpoint> checkpoints = [];
      // if there is no error meaning location has been fetched,
      // continue to get nearby prayer places
      if (geoLocationError.isEmpty) {
        driverIcon ??= await getBytesFromAsset('assets/icons/truck.png', 410);
        markers.add(
          Marker(
            markerId: const MarkerId('Driver'),
            position: LatLng(
              position.latitude,
              position.longitude,
            ),
            icon: BitmapDescriptor.fromBytes(driverIcon!),
            infoWindow: const InfoWindow(title: 'Current Location'),
            rotation: position.heading,
            anchor: const Offset(0.5, 0.5),
            zIndex: 2,
          ),
        );

        checkpoints = await _smartContractRepository.fetchCheckpoints();
        if (checkpoints.isNotEmpty) {
          // - set the place name according to the user's locale
          // - if no value found for the user's locale,
          //   set the place name to english name by default
          for (final checkpoint in checkpoints) {
            markers.add(
              Marker(
                onTap: () {},
                markerId: MarkerId(checkpoint.id.toString()),
                position: LatLng(
                  checkpoint.lat,
                  checkpoint.lng,
                ),
                infoWindow: InfoWindow(
                  title: 'Checkpoint ${checkpoint.id}',
                ),
              ),
            );
          }
          final lastCheckpoint = checkpoints.last;
          Direction direction = await _geoLocationRepository.getDirection(
              LatLng(position.latitude, position.longitude),
              LatLng(lastCheckpoint.lat, lastCheckpoint.lng));

          for (int i = 0; i < direction.lineString.length; i++) {
            myPolyPoints.add(
                LatLng(direction.lineString[i][1], direction.lineString[i][0]));
          }
          Polyline polyline = Polyline(
            polylineId: PolylineId("polyline"),
            color: Colors.black,
            width: 5,
            jointType: JointType.round,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            points: myPolyPoints,
            geodesic: true,
          );
          myPolyLines.add(polyline);

          if (position.latitude > lastCheckpoint.lat &&
              position.longitude > lastCheckpoint.lng) {
            myLatLongBounds = LatLngBounds(
                southwest: LatLng(lastCheckpoint.lat, lastCheckpoint.lng),
                northeast: LatLng(position.latitude, position.longitude));
          } else if (position.longitude > lastCheckpoint.lng) {
            myLatLongBounds = LatLngBounds(
                southwest: LatLng(position.latitude, lastCheckpoint.lng),
                northeast: LatLng(lastCheckpoint.lat, position.longitude));
          } else if (position.latitude > lastCheckpoint.lat) {
            myLatLongBounds = LatLngBounds(
                southwest: LatLng(lastCheckpoint.lat, position.longitude),
                northeast: LatLng(position.latitude, lastCheckpoint.lng));
          } else {
            myLatLongBounds = LatLngBounds(
                southwest: LatLng(position.latitude, position.longitude),
                northeast: LatLng(lastCheckpoint.lat, lastCheckpoint.lng));
          }
        }
      }
      emit(
        state.copyWith(
          checkpoints: checkpoints,
          status: NavigationStatus.loaded,
          geoStatus: geoLocationError.isEmpty ? GeoStatus.loaded : geoStatus,
          failure: geoLocationError.isEmpty
              ? const Failure()
              : Failure(message: geoLocationError),
          currentUserPosition: geoLocationError.isEmpty ? position : null,
          markers: markers,
          polyLines: myPolyLines,
          polyPoints: myPolyPoints,
          latLngBounds: myLatLongBounds,
        ),
      );

      _geoLocationRepository.getUserCurrentPositionStream().listen((event) {
        add(DriverPositionChanged(driverPosition: event));
      });
    } catch (e) {
      final errorMessage = decodeErrorResponse(e);
      emit(
        state.copyWith(
          status: NavigationStatus.error,
          failure: Failure(message: errorMessage),
        ),
      );
    }
  }

  void _onDriverPositionChanged(
    DriverPositionChanged event,
    Emitter<NavigationState> emit,
  ) {
    final driverMarker = Marker(
      markerId: const MarkerId('Driver'),
      position: LatLng(
        event.driverPosition.latitude,
        event.driverPosition.longitude,
      ),
      icon: BitmapDescriptor.fromBytes(driverIcon!),
      infoWindow: const InfoWindow(title: 'Current Location'),
      rotation: event.driverPosition.heading,
      anchor: const Offset(0.5, 0.5),
      zIndex: 2,
    );

    Set<Marker> markers = Set.from(state.markers);
    markers.removeWhere((marker) => marker.markerId.value == 'Driver');

    markers.add(driverMarker);
    emit(state.copyWith(
        currentUserPosition: event.driverPosition, markers: markers));

    final checkpointsNotPassed = state.checkpoints
        .where((checkpoint) => !state.passedCheckpoints.contains(checkpoint))
        .toList();

    // check if the driver position is within the specified checkpoint distance,
    // and if so send a call to smart contract
    for (int i = 0; i < checkpointsNotPassed.length; i++) {
      final checkpoint = checkpointsNotPassed[i];
      final distanceBetweenDriverPositionAndCheckpoint =
          _geoLocationRepository.calculateDistance(
              initialLatitude: event.driverPosition.latitude,
              initialLongitude: event.driverPosition.longitude,
              finalLatitude: checkpoint.lat,
              finalLongitude: checkpoint.lng);
      if (distanceBetweenDriverPositionAndCheckpoint <= checkpoint.distance) {
        // it means the driver is within the specified checkpoint distance
        _smartContractRepository.sendTelemetry(
          checkpoint.id,
          int.parse(
              (event.driverPosition.latitude * 100000).toStringAsFixed(0)),
          int.parse(
              (event.driverPosition.longitude * 100000).toStringAsFixed(0)),
          distanceBetweenDriverPositionAndCheckpoint.toInt(),
          DateTime.now().millisecondsSinceEpoch,
        );

        int numberOfPassedCheckpoints = state.passedCheckpoints.length;

        emit(state.copyWith(
            passedCheckpoints: List.from(state.passedCheckpoints)
              ..add(checkpoint)));
        // delivery completed
        if (numberOfPassedCheckpoints + 1 == state.checkpoints.length) {
          add(CompleteDelivery());
        }
      }
    }
  }

  void _onCompleteDelivery(
    CompleteDelivery event,
    Emitter<NavigationState> emit,
  ) {
    emit(state.copyWith(status: NavigationStatus.completed));
  }

  @override
  Future<void> close() {
    _geoLocationRepository.stopRealtimeDriverPositionUpdates();
    return super.close();
  }
}
