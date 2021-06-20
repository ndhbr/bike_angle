library bikeangle;

import 'dart:async';
import 'package:async/async.dart';

import 'package:bikeangle/models/device_rotation.dart';
import 'package:bikeangle/models/gyro_data.dart';
import 'package:bikeangle/models/recording.dart';
import 'package:sensors/sensors.dart';
import 'package:bikeangle/services/database/controller.dart' as DatabaseService;
import 'package:sqflite/sqflite.dart';

/// Bike Angle Library
class BikeAngle {
  /// Singleton instance
  static final BikeAngle _instance = BikeAngle._init();
  factory BikeAngle({bool debug}) {
    _instance._debug = debug ?? false;

    return _instance;
  }

  /// Memoizer to prevent future builder to trigger the stream
  /// more than once
  final AsyncMemoizer _memoizer = AsyncMemoizer();

  /// Database
  DatabaseService.Controller _database;

  /// Stream
  StreamSubscription _gyroscopeStream;
  StreamController<DeviceRotation> _interpolatedGyroscopeStream;
  DeviceRotation a, b, c;

  /// Recording
  int _recordingId;
  Batch _batch;

  /// State
  bool _isInitialized;
  bool _debug;

  BikeAngle._init() {
    _isInitialized = false;
    _database = DatabaseService.Controller();
    _database.initialize().then((value) => _isInitialized = value);
  }

  /// Retrieves initialization state of the bike angle library
  bool get initialized => _isInitialized;

  /// Starts and returns a bike angle stream with device rotations
  Future<Stream<DeviceRotation>> getBikeAngle() async {
    return await this._memoizer.runOnce(() async {
      _interpolatedGyroscopeStream = StreamController<DeviceRotation>();
      double medianX, medianY, medianZ, avgX, avgY, avgZ;

      _interpolatedGyroscopeStream = StreamController<DeviceRotation>();

      _gyroscopeStream = accelerometerEvents
          .map((event) => GyroData.fromAccelerometerEvent(event))
          .map((event) => DeviceRotation.fromGyroData(event))
          .listen(
        (event) async {
          if (a == null || b == null || c == null) {
            a = event;
            b = event;
            c = event;
          } else {
            a = b;
            b = c;
            c = event;
          }

          // interpolation
          // median
          medianX = _median([a, b, c].map((e) => e.x).toList());
          medianY = _median([a, b, c].map((e) => e.y).toList());
          medianZ = _median([a, b, c].map((e) => e.z).toList());

          b.x = medianX;
          b.y = medianY;
          b.z = medianZ;

          // average
          avgX = _average([a, b, c].map((e) => e.x).toList());
          avgY = _average([a, b, c].map((e) => e.y).toList());
          avgZ = _average([a, b, c].map((e) => e.z).toList());

          b.x = avgX;
          b.y = avgY;
          b.z = avgZ;

          if (_batch != null && _recordingId != null && _recordingId > 0) {
            _database.insertDeviceRotation(
              _recordingId,
              b,
              batch: _batch,
            );
          }

          _interpolatedGyroscopeStream.add(b);

          int timeDifference = c.capturedAt - b.capturedAt;

          if (timeDifference > 0) {
            int part = (timeDifference / 6).round();
            int i;
            double accPart;

            for (i = 1; i <= 2; i++) {
              await Future.delayed(Duration(milliseconds: part * i));

              accPart = (part / timeDifference) * i;

              _interpolatedGyroscopeStream.add(
                DeviceRotation(
                  b.capturedAt + part,
                  x: b.x + ((c.x - b.x) * accPart),
                  y: b.y + ((c.y - b.y) * accPart),
                  z: b.z + ((c.z - b.z) * accPart),
                ),
              );
            }
          }
        },
      );

      return _interpolatedGyroscopeStream.stream.asBroadcastStream();
    });
  }

  /// Stops the started bike angle stream
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

  /// Starts recording of the bike angle stream (only working, if the stream is active)
  Future<void> startRecording() async {
    if (!isRecording()) {
      _recordingId = await _database.startRecording();
      _batch = _database.batch();

      debugPrint('[BIKE_ANGLE] Started recording with ID: $_recordingId');
    }
  }

  /// Stop running recording (if recording is running)
  Future<void> stopRecording() async {
    if (isRecording()) {
      if (_batch != null) {
        await _batch.commit(noResult: true);
      }
      await _database.stopRecording(_recordingId);

      debugPrint('[BIKE_ANGLE] Stopped recording with ID: $_recordingId');

      _recordingId = null;
    }
  }

  /// Check wether library is currently recording
  bool isRecording() {
    return _recordingId != null;
  }

  /// Get stored recordings
  Future<List<Recording>> getRecordings({int startAfter}) async {
    return _database.getRecordings(startAfter: startAfter);
  }

  /// Get recorded angles by recordingId
  Future<List<DeviceRotation>> getRecordedAngles(int recordingId) async {
    return _database.getRecordedAngles(recordingId);
  }

  /// Set title of recording
  Future<void> setRecordingTitle(int recordingId, String title) async {
    return await _database.setRecordingTitle(recordingId, title);
  }

  /// Remove recording by recording id
  Future<void> removeRecording(int recordingId) async {
    return await _database.removeRecording(recordingId);
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
