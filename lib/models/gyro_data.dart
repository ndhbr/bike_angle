import 'package:sensors/sensors.dart';

class GyroData {
  /// Contructs an instance with the given [x], [y], and [z] values.
  GyroData(this.x, this.y, this.z);

  /// Rate of rotation around the x axis measured in rad/s.
  ///
  /// When the device is held upright, this can also be thought of as describing
  /// "pitch". The top of the device will tilt towards or away from the
  /// user as this value changes.
  final double x;

  /// Rate of rotation around the y axis measured in rad/s.
  ///
  /// When the device is held upright, this can also be thought of as describing
  /// "yaw". The lengthwise edge of the device will rotate towards or away from
  /// the user as this value changes.
  final double y;

  /// Rate of rotation around the z axis measured in rad/s.
  ///
  /// When the device is held upright, this can also be thought of as describing
  /// "roll". When this changes the face of the device should remain facing
  /// forward, but the orientation will change from portrait to landscape and so
  /// on.
  final double z;

  factory GyroData.fromGyroscopeEvent(GyroscopeEvent gyroscopeEvent) {
    return GyroData(gyroscopeEvent.x, gyroscopeEvent.y, gyroscopeEvent.z);
  }

  factory GyroData.fromAccelerometerEvent(
      AccelerometerEvent accelerometerEvent) {
    return GyroData(
        accelerometerEvent.x, accelerometerEvent.y, accelerometerEvent.z);
  }

  factory GyroData.fromUserAccelerometerEvent(
      UserAccelerometerEvent userAccelerometerEvent) {
    return GyroData(userAccelerometerEvent.x, userAccelerometerEvent.y,
        userAccelerometerEvent.z);
  }

  @override
  String toString() => '[GyroData (x: $x, y: $y, z: $z)]';
}
