library bikeangle;

import 'dart:async';

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

  BikeAngle._init() {
    _database = DatabaseService();
    _database.initialize();
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
