import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/socket/socket_manager.dart';
import 'tracking_event.dart';
import 'tracking_state.dart';

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  final SocketManager _socketManager = SocketManager.instance;

  TrackingBloc() : super(TrackingInitial()) {
    on<StartTracking>(_onStartTracking);
    on<RiderLocationUpdated>(_onRiderLocationUpdated);
    on<StopTracking>(_onStopTracking);
  }

  void _onStartTracking(StartTracking event, Emitter<TrackingState> emit) {
    // Initial state (starting location, maybe from order details)
    emit(TrackingActive(latitude: 0, longitude: 0, orderId: event.orderId));

    // Register socket listener
    _socketManager.onDriverLocationUpdate((data) {
      // Assuming data contains { 'orderId': '...', 'latitude': ..., 'longitude': ... }
      if (data['orderId'] == event.orderId) {
        add(RiderLocationUpdated(
          (data['latitude'] as num).toDouble(),
          (data['longitude'] as num).toDouble(),
        ));
      }
    });
  }

  void _onRiderLocationUpdated(RiderLocationUpdated event, Emitter<TrackingState> emit) {
    if (state is TrackingActive) {
      final currentState = state as TrackingActive;
      emit(TrackingActive(
        latitude: event.latitude,
        longitude: event.longitude,
        orderId: currentState.orderId,
      ));
    }
  }

  void _onStopTracking(StopTracking event, Emitter<TrackingState> emit) {
    _socketManager.unregisterEvent('driverLocationUpdate');
    emit(TrackingStopped());
  }

  @override
  Future<void> close() {
    _socketManager.unregisterEvent('driverLocationUpdate');
    return super.close();
  }
}
