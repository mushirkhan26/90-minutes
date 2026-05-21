import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'logger_service.dart';

class LocationService {
  static final LocationService instance = LocationService._internal();
  LocationService._internal();

  final LoggingService _logger = LoggingService.instance;

  // ✅ Cache: last known position
  Position? _cachedPosition;
  DateTime? _cacheTime;
  static const _cacheDuration = Duration(minutes: 2);

  StreamSubscription<Position>? _locationSubscription;
  final StreamController<Position> _locationStreamController =
      StreamController<Position>.broadcast();

  // ─────────────────────────────────────────
  // PERMISSION HANDLING
  // ─────────────────────────────────────────

  Future<LocationPermission> handlePermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      _logger.info('Location', 'Permission status: $permission');
      return permission;
    } catch (e) {
      _logger.error('Location', 'handlePermission failed', error: e);
      return LocationPermission.denied;
    }
  }

  bool isPermissionGranted(LocationPermission permission) {
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  // ─────────────────────────────────────────
  // GET POSITION
  // ─────────────────────────────────────────

  /// ✅ Main method — cache + last known fallback + permission guard
  Future<Position?> getCurrentLocation({bool forceRefresh = false}) async {
    try {
      // 1. Check service
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _logger.warning('Location', 'Service disabled');
        return null;
      }

      // 2. Check permission before fetching
      final permission = await Geolocator.checkPermission();
      if (!isPermissionGranted(permission)) {
        _logger.warning('Location', 'Permission not granted: $permission');
        return null;
      }

      // 3. Return cache if fresh enough
      if (!forceRefresh && _isCacheValid()) {
        _logger.info('Location', 'Returning cached position');
        return _cachedPosition;
      }

      // 4. Try last known first (fast, no GPS spin-up)
      if (!forceRefresh) {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          _logger.info('Location', 'Using last known position');
          _updateCache(lastKnown);
          
          // Fetch fresh in background
          _refreshInBackground();
          return lastKnown;
        }
      }

      // 5. Fresh GPS fetch
      return await _fetchFreshPosition();

    } catch (e) {
      _logger.error('Location', 'getCurrentLocation failed', error: e);
      return _cachedPosition; // Return stale cache on error
    }
  }

  Future<Position?> _fetchFreshPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: AndroidSettings(
          accuracy: LocationAccuracy.high,
          forceLocationManager: false,
        ),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('GPS timeout'),
      );

      _updateCache(position);
      _logger.info('Location', 'Fresh position fetched');
      return position;
    } on TimeoutException {
      _logger.warning('Location', 'GPS timed out, using cache');
      return _cachedPosition;
    }
  }

  void _refreshInBackground() {
    Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    ).then(_updateCache).catchError((e) {
      _logger.warning('Location', 'Background refresh failed: $e');
    });
  }

  // ─────────────────────────────────────────
  // STREAM — for live delivery tracking
  // ─────────────────────────────────────────

  /// ✅ Blinkit-style: broadcast stream with error recovery
  Stream<Position> getLocationStream({
    int distanceFilter = 10,
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) {
    _startLocationStream(distanceFilter: distanceFilter, accuracy: accuracy);
    return _locationStreamController.stream;
  }

  void _startLocationStream({
    required int distanceFilter,
    required LocationAccuracy accuracy,
  }) {
    _locationSubscription?.cancel();

    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    ).listen(
      (position) {
        _updateCache(position);
        _locationStreamController.add(position);
      },
      onError: (error) {
        _logger.error('Location', 'Stream error', error: error);
        // ✅ Auto-retry after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          _startLocationStream(
            distanceFilter: distanceFilter,
            accuracy: accuracy,
          );
        });
      },
      cancelOnError: false, // ✅ Stream alive rehta hai error pe bhi
    );
  }

  void stopLocationStream() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  // ─────────────────────────────────────────
  // UTILS
  // ─────────────────────────────────────────

  /// ✅ Input validation added
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    if ([startLat, startLng, endLat, endLng]
        .any((v) => v.isNaN || v.isInfinite)) {
      _logger.warning('Location', 'Invalid coordinates for distance calc');
      return 0.0;
    }
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// Returns distance as human-readable string
  String formatDistance(double meters) {
    if (meters < 1000) return '${meters.toStringAsFixed(0)}m';
    return '${(meters / 1000).toStringAsFixed(1)}km';
  }

  Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();

  Future<bool> openSettings() async {
    try {
      return await ph.openAppSettings();
    } catch (e) {
      _logger.error('Location', 'openSettings failed', error: e);
      return false;
    }
  }

  // ─────────────────────────────────────────
  // CACHE INTERNALS
  // ─────────────────────────────────────────

  bool _isCacheValid() {
    if (_cachedPosition == null || _cacheTime == null) return false;
    return DateTime.now().difference(_cacheTime!) < _cacheDuration;
  }

  void _updateCache(Position position) {
    _cachedPosition = position;
    _cacheTime = DateTime.now();
  }

  void clearCache() {
    _cachedPosition = null;
    _cacheTime = null;
  }

  // ─────────────────────────────────────────
  // DISPOSE
  // ─────────────────────────────────────────

  void dispose() {
    _locationSubscription?.cancel();
    _locationStreamController.close();
  }
}
