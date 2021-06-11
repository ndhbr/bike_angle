library database_service;

import 'package:bikeangle/models/device_rotation.dart';
import 'package:bikeangle/models/recording.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

part 'tables.dart';
part 'columns.dart';
part 'queries.dart';

const DB_NAME = 'bike_angle_database.db';
const PAGINATION_LIMIT = 10;

/// SQLite database controller
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
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      version: 1,
    );

    return true;
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

    int changes = await _database.update(
      Tables.recordings,
      {Columns.re_stopped_recording: DateTime.now().millisecondsSinceEpoch},
      where: '${Columns.re_id} = $recordingId',
    );

    return changes;
  }

  /// Insert device rotation to existing recording
  Future<void> insertDeviceRotation(int recordingId, DeviceRotation rotation,
      {Batch batch}) async {
    if (_database == null) {
      throw 'Database not initialized';
    }

    Map<String, dynamic> insertData = rotation.toMap();

    insertData.addAll({Columns.dr_recording_id: recordingId});

    if (batch != null) {
      batch.insert(Tables.deviceRotations, insertData);
    } else {
      await _database.insert(Tables.deviceRotations, insertData);
    }
  }

  /// Retrieves a paginated list of recordings
  Future<List<Recording>> getRecordings({int startAfter}) async {
    List<Map<String, Object>> rawData = await _database.query(
      Tables.recordings,
      limit: PAGINATION_LIMIT,
      orderBy: '${Columns.re_started_recording} DESC',
      where: (startAfter != null) ? '${Columns.re_started_recording} < $startAfter' : null,
    );
    List<Recording> recordings =
        rawData.map((e) => Recording.fromDatabase(e)).toList();

    return recordings;
  }

  /// Retrieves a list of all recorded bike angles of the recording
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

  /// Remove recording from database by recording id
  Future<void> removeRecording(int recordingId) async {
    return await _database.delete(Tables.recordings,
        where: '${Columns.re_id} = $recordingId');
  }

  /// Set title of recording
  Future<void> setRecordingTitle(int recordingId, String title) async {
    return await _database.update(Tables.recordings, {Columns.re_title: title},
        where: '${Columns.re_id} = $recordingId');
  }

  /// Return a new batch instance
  Batch batch() {
    return _database.batch();
  }
}
