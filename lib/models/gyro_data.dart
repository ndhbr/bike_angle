import 'package:sensors/sensors.dart';

class GyroData {
  GyroData(this.x, this.y, this.z);

  /// Rate of rotation around the x axis measured in rad/s
  final double x;

  /// Rate of rotation around the y axis measured in rad/s
  final double y;

  /// Rate of rotation around the z axis measured in rad/s
  final double z;

  /// Constructs GyroData by GyroscopeEvent
  factory GyroData.fromGyroscopeEvent(GyroscopeEvent gyroscopeEvent) {
    return GyroData(gyroscopeEvent.x, gyroscopeEvent.y, gyroscopeEvent.z);
  }

  /// Constructs GyroData by AccelerometerEvent
  factory GyroData.fromAccelerometerEvent(
      AccelerometerEvent accelerometerEvent) {
    return GyroData(
        accelerometerEvent.x, accelerometerEvent.y, accelerometerEvent.z);
  }

  /// Constructs GyroData by UserAccelerometerEvent
  factory GyroData.fromUserAccelerometerEvent(
      UserAccelerometerEvent userAccelerometerEvent) {
    return GyroData(userAccelerometerEvent.x, userAccelerometerEvent.y,
        userAccelerometerEvent.z);
  }

  @override
  String toString() => '[GyroData (x: $x, y: $y, z: $z)]';
}
