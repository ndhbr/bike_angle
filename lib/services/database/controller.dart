library database_service;

import 'package:bikeangle/models/device_rotation.dart';
import 'package:bikeangle/models/recording.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

part 'tables.dart';
part 'columns.dart';
part 'queries.dart';

const DB_NAME = 'bike_angle_database.db';

class Controller {
  /// Database instance
  Database _database;

  /// Returns wether the database is initialized or
  bool isInitialized() {
    return _database != null;
  }

  /// Initialize database "connection"
  Future<bool> initialize() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), DB_NAME),
      onCreate: (db, version) async {
        print('Trying to create database');

        await db.execute(Queries.createRecordingsTable);
        await db.execute(Queries.createDeviceRotationsTable);
      },
      version: 1,
    );

    return true;
    // Debug: Clear whole db
    // await dropDatabase();
    // await _database.execute(Queries.createRecordingsTable);
    // await _database.execute(Queries.createDeviceRotationsTable);
  }

  /// Drop both tables -> clear/drop database
  Future<void> dropDatabase() async {
    return await _database.rawQuery(Queries.dropDb);
  }

  /// Adds new recording entry
  Future<int> startRecording() async {
    if (_database == null) {
      throw 'Database not initialized';
    }

    Recording recording = Recording(
      startedRecordingTimestamp: DateTime.now().millisecondsSinceEpoch,
    );

    int id = await _database.insert(
      Tables.recordings,
      recording.toMap(),
    );

    return id;
  }

  /// Updates recording entry with stopped timestamp
  Future<int> stopRecording(int recordingId) async {
    if (_database == null) {
      throw 'Database not initialized';
    }

    int changes = await _database.update(Tables.recordings, {
      Columns.re_stopped_recording: DateTime.now().millisecondsSinceEpoch,
    });

    return changes;
  }

  /// Insert device rotation to existing recording
  Future<void> insertDeviceRotation(
      int recordingId, DeviceRotation rotation) async {
    if (_database == null) {
      throw 'Database not initialized';
    }

    Map<String, dynamic> insertData = rotation.toMap();

    insertData.addAll({Columns.dr_recording_id: recordingId});

    await _database.insert(Tables.deviceRotations, insertData);
  }

  Future<List<Recording>> getRecordings({int startAfter}) async {
    List<Map<String, Object>> rawData =
        await _database.query(Tables.recordings, limit: 32);
    List<Recording> recordings =
        rawData.map((e) => Recording.fromDatabase(e)).toList();

    return recordings;
  }

  Future<List<DeviceRotation>> getRecordedAngles(int recordingId) async {
    List<Map<String, Object>> rawData = await _database.query(
      Tables.deviceRotations,
      where: '${Columns.dr_recording_id} = $recordingId',
      orderBy: '${Columns.dr_captured_at} DESC',
    );
    List<DeviceRotation> deviceRotations =
        rawData.map((e) => DeviceRotation.fromDatabase(e)).toList();

    return deviceRotations;
  }
}
