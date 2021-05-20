library bikeangle;

import 'dart:async';

import 'package:bikeangle/models/device_rotation.dart';
import 'package:bikeangle/models/gyro_data.dart';
import 'package:bikeangle/models/recording.dart';
import 'package:sensors/sensors.dart';
import 'package:bikeangle/services/database/controller.dart' as DatabaseService;

/// Bike Angle Library
class BikeAngle {
  /// Singleton instance
  static final BikeAngle _instance = BikeAngle._init();
  factory BikeAngle({bool debug}) {
    _instance._debug = debug ?? false;

    return _instance;
  }

  /// Database
  DatabaseService.Controller _database;

  /// Stream
  StreamSubscription _gyroscopeStream;
  StreamController<DeviceRotation> _interpolatedGyroscopeStream;
  List<DeviceRotation> _lastValues;

  /// Recording
  int _recordingId;

  /// State
  bool _isInitialized;
  bool _debug;

  BikeAngle._init() {
    _isInitialized = false;
    _database = DatabaseService.Controller();
    _database.initialize().then((value) => _isInitialized = value);
  }

  bool get initialized => _isInitialized;

  Future<Stream<DeviceRotation>> getBikeAngle() async {
    _interpolatedGyroscopeStream = StreamController<DeviceRotation>();

    _lastValues = [];

    _gyroscopeStream = accelerometerEvents
        .map((event) => GyroData.fromAccelerometerEvent(event))
        .map((event) => DeviceRotation.fromGyroData(event))
        .listen((event) async {
      _lastValues.add(event);

      if (_lastValues.length > 3) {
        _lastValues.removeAt(0);
      }

      // interpolation
      if (_lastValues.length == 3) {
        // median
        double medianPitch = _median(_lastValues.map((e) => e.pitch).toList());
        double medianRoll = _median(_lastValues.map((e) => e.roll).toList());

        _lastValues[1] =
            DeviceRotation(medianPitch, medianRoll, _lastValues[1].capturedAt);

        // average
        double avgPitch = _average(_lastValues.map((e) => e.pitch).toList());
        double avgRoll = _average(_lastValues.map((e) => e.roll).toList());

        _lastValues[1] =
            DeviceRotation(avgPitch, avgRoll, _lastValues[1].capturedAt);

        // send
        _interpolatedGyroscopeStream.add(_lastValues[1]);

        if (_recordingId != null && _recordingId > 0) {
          await _database.insertDeviceRotation(_recordingId, _lastValues[1]);
        }
      }
    });

    return _interpolatedGyroscopeStream.stream;
  }

  Future<void> stopBikeAngleStream() async {
    if (_gyroscopeStream != null) {
      await _gyroscopeStream.cancel();
      _gyroscopeStream = null;
    }

    if (_interpolatedGyroscopeStream != null) {
      await _interpolatedGyroscopeStream.close();
      _interpolatedGyroscopeStream = null;
    }
  }

  Future<void> startRecording() async {
    _recordingId = await _database.startRecording();
    debugPrint('[BIKE_ANGLE] Started recording with ID: $_recordingId');
  }

  void stopRecording() {
    debugPrint('[BIKE_ANGLE] Stopped recording with ID: $_recordingId');
    _recordingId = null;
  }

  bool isRecording() {
    return _recordingId != null;
  }

  Future<List<Recording>> getRecordings({int startAfter}) async {
    return _database.getRecordings(startAfter: startAfter);
  }

  Future<List<DeviceRotation>> getRecordedAngles(int recordingId) async {
    return _database.getRecordedAngles(recordingId);
  }

  /// Calculates average value of list values
  double _average(List<double> list) {
    double sum = 0.0;

    for (double item in list) {
      sum += item;
    }

    return sum / list.length;
  }

  /// Calculates median value of list values
  double _median(List<double> a) {
    int middle = a.length ~/ 2;

    if (a.length % 2 == 1) {
      return a[middle];
    } else {
      return (a[middle - 1] + a[middle]) / 2.0;
    }
  }

  /// Debug print, only if debug flag is set
  void debugPrint(Object object) {
    if (_debug) {
      print(object);
    }
  }

  /// Listen to device rotation
  Stream<DeviceRotation> listenToDeviceRotationEvents() {
    return listenToAccelerometerEvents()
        .map((event) => DeviceRotation.fromGyroData(event));
  }

  /// Listen to accelerometer events
  Stream<GyroData> listenToAccelerometerEvents() {
    return accelerometerEvents
        .map((event) => GyroData.fromAccelerometerEvent(event));
  }

  /// Listen to user accelerometer events
  Stream<GyroData> listenToUserAccelerometerEvents() {
    return userAccelerometerEvents
        .map((event) => GyroData.fromUserAccelerometerEvent(event));
  }

  /// Listen to gyroscope events
  Stream<GyroData> listenToGyroscopeEvents() {
    return gyroscopeEvents.map((event) => GyroData.fromGyroscopeEvent(event));
  }
}
