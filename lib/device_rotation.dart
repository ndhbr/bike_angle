import 'dart:math';

import 'package:bikeangle/gyro_data.dart';

class DeviceRotation {
  DeviceRotation(this.pitch, this.roll);

  final double pitch;
  final double roll;

  factory DeviceRotation.fromGyroData(GyroData gyroData) {
    // rotation on Y axis
    double pitch = atan2(-gyroData.x, gyroData.z) * 180 / pi;
    // rotation on X axis
    double roll = atan2(-gyroData.y, gyroData.z) * 180 / pi;

    return DeviceRotation(pitch, roll);
  }
}
