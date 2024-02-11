part of 'navigation_bloc.dart';

@immutable
abstract class NavigationEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetCurrentPosition extends NavigationEvent {}

class DriverPositionChanged extends NavigationEvent {
  final Position driverPosition;
  DriverPositionChanged({required this.driverPosition});
}

class CompleteDelivery extends NavigationEvent {}
