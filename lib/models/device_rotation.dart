import 'dart:math';

import 'package:bikeangle/models/gyro_data.dart';
import 'package:bikeangle/services/database/controller.dart';

class DeviceRotation {
  double x;
  double y;
  double z;
  int capturedAt;

  DeviceRotation(this.capturedAt, {this.x, this.y, this.z});

  /// Calculates exact bike angle
  // double get bikeAngle {
  //   double rollRad = roll * pi / 180;
  //   double pitchRad = roll * pi / 180;
  //   double tilt = sqrt(pow(rollRad, 2) + pow(pitchRad, 2));

  //   return tilt * 180 / pi;
  // }

  // double get bikeAngle5 {
  //   double rollRad = roll * pi / 180;
  //   double pitchRad = roll * pi / 180;
  //   double tilt = atan(sqrt(pow(tan(rollRad), 2) + pow(tan(pitchRad), 2)));

  //   return tilt * 180 / pi;
  // }

  // double get bikeAngle2 {
  //   double inner = x / sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2));
  //   double tilt = atan(inner);
  //   return tilt * 180 / pi;
  // }

  // double get bikeAngle3 {
  //   double zaehler = sqrt(pow(x, 2) + pow(y, 2));
  //   double nenner = z;
  //   double tilt = atan(zaehler / nenner);

  //   // double roll = atan(x / (sqrt(pow(y, 2) + pow(z, 2))));
  //   // double pitch = atan(y / (sqrt(pow(x, 2) + pow(z, 2))));

  //   return tilt * 180 / pi;
  // }

  // double get bikeAngle4 {
  //   double tilt = tan(-x / (sqrt(pow(y, 2) + pow(x, 2))));

  //   return tilt * 180 / pi;
  // }

  /// Calculates exact bike angle in rad
  double get bikeAngleRad {
    double tilt = atan(x / y);

    return tilt;
  }

  /// Calculates exact bike angle
  double get bikeAngle {
    return bikeAngleRad * 180 / pi;
  }

  /// Calculates wether the recorded angle can be a correct one
  bool get valid {
    double pitch = atan(y / (sqrt(pow(x, 2) + pow(z, 2))));
    
    return (pitch >= 0.35 && pitch <= 0.9);
  }

  /// Generates device rotation object by GyroData
  factory DeviceRotation.fromGyroData(GyroData gyroData) {
    double x = gyroData.x;
    double y = gyroData.y;
    double z = gyroData.z;

    return DeviceRotation(
      DateTime.now().millisecondsSinceEpoch,
      x: x,
      y: y,
      z: z,
    );
  }

  factory DeviceRotation.fromDatabase(Map<String, Object> data) {
    double x = 0.0;
    double y = 0.0;
    double z = 0.0;

    if (data[Columns.dr_x] is int) {
      x = (data[Columns.dr_x] as int).toDouble();
    } else {
      x = data[Columns.dr_x] ?? 0.0;
    }

    if (data[Columns.dr_y] is int) {
      y = (data[Columns.dr_y] as int).toDouble();
    } else {
      y = data[Columns.dr_y] ?? 0.0;
    }

    if (data[Columns.dr_z] is int) {
      z = (data[Columns.dr_z] as int).toDouble();
    } else {
      z = data[Columns.dr_z] ?? 0.0;
    }

    return DeviceRotation(
      data[Columns.dr_captured_at] ?? 0,
      x: x,
      y: y,
      z: z,
    );
  }

  /// Returns map representation for usage in database
  Map<String, dynamic> toMap() {
    return {
      Columns.dr_captured_at:
          capturedAt ?? DateTime.now().millisecondsSinceEpoch,
      Columns.dr_x: x ?? 0.0,
      Columns.dr_y: y ?? 0.0,
      Columns.dr_z: z ?? 0.0,
    };
  }
}
