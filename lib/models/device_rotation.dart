import 'dart:math';

import 'package:bikeangle/models/gyro_data.dart';
import 'package:bikeangle/services/database/controller.dart';

class DeviceRotation {
  final double pitch;
  final double roll;
  final int capturedAt;

  DeviceRotation(this.pitch, this.roll, this.capturedAt);

  /// Generates device rotation object by GyroData
  factory DeviceRotation.fromGyroData(GyroData gyroData) {
    // rotation on Y axis
    double pitch = atan2(-gyroData.x, gyroData.z) * 180 / pi;
    // rotation on X axis
    double roll = atan2(-gyroData.y, gyroData.z) * 180 / pi;

    return DeviceRotation(pitch, roll, DateTime.now().millisecondsSinceEpoch);
  }

  factory DeviceRotation.fromDatabase(Map<String, Object> data) {
    double pitch = 0.0;
    double roll = 0.0;

    if (data[Columns.dr_pitch] is int) {
      pitch = (data[Columns.dr_pitch] as int).toDouble();
    } else {
      pitch = data[Columns.dr_pitch] ?? 0.0;
    }

    if (data[Columns.dr_roll] is int) {
      roll = (data[Columns.dr_roll] as int).toDouble();
    } else {
      roll = data[Columns.dr_roll] ?? 0.0;
    }

    return DeviceRotation(
      pitch,
      roll,
      data[Columns.dr_captured_at] ?? 0,
    );
  }

  /// Returns map representation for usage in database
  Map<String, dynamic> toMap() {
    return {
      Columns.dr_pitch: pitch ?? 0.0,
      Columns.dr_roll: roll ?? 0.0,
      Columns.dr_captured_at:
          capturedAt ?? DateTime.now().millisecondsSinceEpoch,
    };
  }
}
