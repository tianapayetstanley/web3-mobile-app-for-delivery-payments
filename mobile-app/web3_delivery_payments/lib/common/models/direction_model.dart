import 'package:equatable/equatable.dart';

class Direction extends Equatable {
  final double distance;
  final double duration;
  final List<dynamic> lineString;

  const Direction(
      {required this.distance,
      required this.duration,
      required this.lineString});

  @override
  List<Object?> get props => [distance, duration, lineString];

  factory Direction.fromJson(Map<String, dynamic> json) {
    return Direction(
      distance:
          (json['features'][0]['properties']['summary']['distance'] ?? 0.0)
              .toDouble(),
      duration:
          (json['features'][0]['properties']['summary']['duration'] ?? 0.0)
              .toDouble(),
      lineString: json['features'][0]['geometry']['coordinates'] ?? [],
    );
  }
}
