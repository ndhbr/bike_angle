import 'dart:math';

import 'package:bikeangle/models/gyro_data.dart';
import 'package:bikeangle/services/database/controller.dart';

class DeviceRotation {
  double pitch;
  double roll;
  double x;
  double y;
  double z;
  int capturedAt;

  DeviceRotation(this.pitch, this.roll, this.capturedAt,
      {this.x, this.y, this.z});

  /// Calculates exact bike angle
  double get bikeAngle {
    double rollRad = roll * pi / 180;
    double pitchRad = roll * pi / 180;
    double tilt = sqrt(pow(rollRad, 2) + pow(pitchRad, 2));

    return tilt * 180 / pi;
  }

  double get bikeAngle5 {
    double rollRad = roll * pi / 180;
    double pitchRad = roll * pi / 180;
    double tilt = atan(sqrt(pow(tan(rollRad), 2) + pow(tan(pitchRad), 2)));

    return tilt * 180 / pi;
  }

  double get bikeAngle2 {
    double inner = x / sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2));
    double tilt = atan(inner);
    return tilt * 180 / pi;
  }

  double get bikeAngle3 {
    double zaehler = sqrt(pow(x, 2) + pow(y, 2));
    double nenner = z;
    double tilt = atan(zaehler / nenner);

    // double roll = atan(x / (sqrt(pow(y, 2) + pow(z, 2))));
    // double pitch = atan(y / (sqrt(pow(x, 2) + pow(z, 2))));

    return tilt * 180 / pi;
  }

  double get bikeAngle4 {
    double tilt = tan(-x / (sqrt(pow(y, 2) + pow(x, 2))));

    return tilt * 180 / pi;
  }

  double get bikeAngle6 {
    double tilt = atan(x/y);

    return tilt * 180 / pi;
  }

  /// Generates device rotation object by GyroData
  factory DeviceRotation.fromGyroData(GyroData gyroData) {
    // rotation on Y axis
    double pitch = atan2(-gyroData.x, gyroData.z) * 180 / pi;
    // rotation on X axis
    double roll = atan2(-gyroData.y, gyroData.z) * 180 / pi;

    double x = gyroData.x;
    double y = gyroData.y;
    double z = gyroData.z;

    return DeviceRotation(pitch, roll, DateTime.now().millisecondsSinceEpoch,
        x: x, y: y, z: z);
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
