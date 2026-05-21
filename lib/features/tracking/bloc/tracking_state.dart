import 'package:equatable/equatable.dart';

abstract class TrackingState extends Equatable {
  const TrackingState();

  @override
  List<Object?> get props => [];
}

class TrackingInitial extends TrackingState {}

class TrackingActive extends TrackingState {
  final double latitude;
  final double longitude;
  final String orderId;

  const TrackingActive({
    required this.latitude,
    required this.longitude,
    required this.orderId,
  });

  @override
  List<Object?> get props => [latitude, longitude, orderId];
}

class TrackingStopped extends TrackingState {}

class TrackingError extends TrackingState {
  final String message;

  const TrackingError(this.message);

  @override
  List<Object?> get props => [message];
}
