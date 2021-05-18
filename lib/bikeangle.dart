library bikeangle;

import 'dart:async';
import 'dart:collection';

import 'package:bikeangle/device_rotation.dart';
import 'package:bikeangle/gyro_data.dart';
import 'package:bikeangle/services/database.dart';
import 'package:sensors/sensors.dart';

/// Bike Angle Library
class BikeAngle {
  /// Singleton instance
  static final BikeAngle _instance = BikeAngle._init();
  factory BikeAngle() => _instance;

  /// Database
  DatabaseService _database;

  /// Stream
  StreamSubscription _gyroscopeStream;
  StreamController<DeviceRotation> _interpolatedGyroscopeStream;
  List<DeviceRotation> _lastValues;

  BikeAngle._init() {
    _database = DatabaseService();
    _database.initialize();
  }

  Future<Stream<DeviceRotation>> startAngleRecording() async {
    _interpolatedGyroscopeStream = StreamController<DeviceRotation>();

    _lastValues = [];

    _gyroscopeStream = accelerometerEvents
        .map((event) => GyroData.fromAccelerometerEvent(event))
        .map((event) => DeviceRotation.fromGyroData(event))
        .listen((event) {
      _lastValues.add(event);

      if (_lastValues.length > 6) {
        _lastValues.removeAt(0);
      }

      // interpolation
      if (_lastValues.length == 6) {
        // median
        double medianPitch = _median(_lastValues.map((e) => e.pitch).toList());
        double medianRoll = _median(_lastValues.map((e) => e.roll).toList());

        _lastValues[2] =
            DeviceRotation(medianPitch, medianRoll, _lastValues[2].capturedAt);

        // average
        double avgPitch = _average(_lastValues.map((e) => e.pitch).toList());
        double avgRoll = _average(_lastValues.map((e) => e.roll).toList());

        _lastValues[2] =
            DeviceRotation(avgPitch, avgRoll, _lastValues[2].capturedAt);

        // send
        _interpolatedGyroscopeStream.add(_lastValues[2]);
      }
    });

    return _interpolatedGyroscopeStream.stream;
  }

  Future<void> stopAngleRecording() async {
    if (_gyroscopeStream != null) {
      await _gyroscopeStream.cancel();
      _gyroscopeStream = null;
    }

    if (_interpolatedGyroscopeStream != null) {
      await _interpolatedGyroscopeStream.close();
      _interpolatedGyroscopeStream = null;
    }
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
