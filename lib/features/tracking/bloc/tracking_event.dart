import 'package:equatable/equatable.dart';

abstract class TrackingEvent extends Equatable {
  const TrackingEvent();

  @override
  List<Object?> get props => [];
}

class StartTracking extends TrackingEvent {
  final String orderId;

  const StartTracking(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class RiderLocationUpdated extends TrackingEvent {
  final double latitude;
  final double longitude;

  const RiderLocationUpdated(this.latitude, this.longitude);

  @override
  List<Object?> get props => [latitude, longitude];
}

class StopTracking extends TrackingEvent {}
