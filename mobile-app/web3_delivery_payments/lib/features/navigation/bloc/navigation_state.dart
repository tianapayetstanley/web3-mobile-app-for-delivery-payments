// ignore_for_file: public_member_api_docs, sort_constructors_first

part of 'navigation_bloc.dart';

enum NavigationStatus { initial, loading, loaded, error }

enum GeoStatus {
  initial,
  loading,
  loaded,
  serviceDisabled,
  permissionDenied,
  permissionDeniedPermanently
}

@immutable
class NavigationState extends Equatable {
  final NavigationStatus status;
  final Failure failure;
  final GeoStatus geoStatus;
  final Set<Marker> markers;
  final Position? currentUserPosition;
  final Set<Polyline> polyLines;
  final List<LatLng> polyPoints;
  final LatLngBounds latLngBounds;
  final List<Checkpoint> checkpoints;
  final List<Checkpoint> passedCheckpoints;

  const NavigationState({
    required this.status,
    required this.geoStatus,
    required this.markers,
    required this.currentUserPosition,
    required this.failure,
    required this.polyLines,
    required this.polyPoints,
    required this.latLngBounds,
    required this.checkpoints,
    required this.passedCheckpoints,
  });

  factory NavigationState.initial() {
    return NavigationState(
      status: NavigationStatus.initial,
      geoStatus: GeoStatus.initial,
      markers: const {},
      currentUserPosition: null,
      failure: const Failure(),
      polyLines: const {},
      polyPoints: const [],
      latLngBounds: LatLngBounds(
          southwest: const LatLng(0, 0), northeast: const LatLng(0, 0)),
      checkpoints: const [],
      passedCheckpoints: const [],
    );
  }

  @override
  List<Object?> get props => [
        status,
        geoStatus,
        markers,
        currentUserPosition,
        failure,
        polyLines,
        polyPoints,
        latLngBounds,
        checkpoints,
        passedCheckpoints,
      ];

  NavigationState copyWith({
    NavigationStatus? status,
    GeoStatus? geoStatus,
    Set<Marker>? markers,
    Position? currentUserPosition,
    Failure? failure,
    Set<Polyline>? polyLines,
    List<LatLng>? polyPoints,
    LatLngBounds? latLngBounds,
    List<Checkpoint>? checkpoints,
    List<Checkpoint>? passedCheckpoints,
  }) {
    return NavigationState(
      status: status ?? this.status,
      geoStatus: geoStatus ?? this.geoStatus,
      markers: markers ?? this.markers,
      currentUserPosition: currentUserPosition ?? this.currentUserPosition,
      failure: failure ?? this.failure,
      polyLines: polyLines ?? this.polyLines,
      polyPoints: polyPoints ?? this.polyPoints,
      latLngBounds: latLngBounds ?? this.latLngBounds,
      checkpoints: checkpoints ?? this.checkpoints,
      passedCheckpoints: passedCheckpoints ?? this.passedCheckpoints,
    );
  }
}
