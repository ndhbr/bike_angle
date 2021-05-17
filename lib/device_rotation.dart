import 'dart:math';

import 'package:bikeangle/gyro_data.dart';

class DeviceRotation {
  final double pitch;
  final double roll;
  final DateTime capturedAt;

  DeviceRotation(this.pitch, this.roll, this.capturedAt);

  /// Generates device rotation object by GyroData
  factory DeviceRotation.fromGyroData(GyroData gyroData) {
    // rotation on Y axis
    double pitch = atan2(-gyroData.x, gyroData.z) * 180 / pi;
    // rotation on X axis
    double roll = atan2(-gyroData.y, gyroData.z) * 180 / pi;

    return DeviceRotation(pitch, roll, DateTime.now());
  }

  /// Returns map representation for usage in database
  Map<String, dynamic> toMap() {
    return {
      'pitch': pitch ?? 0.0,
      'roll': roll ?? 0.0,
      'captured_at': capturedAt ?? DateTime.now()
    };
  }
}
