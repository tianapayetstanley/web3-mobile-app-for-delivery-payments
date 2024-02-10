import 'package:equatable/equatable.dart';

class Checkpoint extends Equatable {
  final int id;
  final double lat;
  final double lng;
  final int timestamp;

  const Checkpoint(
      {required this.id,
      required this.lat,
      required this.lng,
      required this.timestamp});

  @override
  List<Object?> get props => [id, lat, lng, timestamp];
}
