import 'package:bikeangle/device_rotation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const DB_NAME = 'bike_angle_database.db';
const INIT_SQL_FILE = 'init.sql';
const TABLE_DEVICE_ROTATIONS = 'device_rotations';

class DatabaseService {
  /// Database instance
  Database _database;

  /// Returns wether the database is initialized or
  bool isInitialized() {
    return _database != null;
  }

  /// Initialize database "connection"
  Future<void> initialize() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), DB_NAME),
      onCreate: (db, version) async {
        try {
          String initQuery = await _readSqlFile(INIT_SQL_FILE);
          return db.execute(initQuery);
        } catch (e) {
          print(e);
        }
      },
      version: 1,
    );
  }

  Future<void> insertDeviceRotation(
      int recordingId, DeviceRotation rotation) async {
    Map<String, dynamic> insertData = rotation.toMap();

    if (_database == null) {
      throw 'Database not initialized';
    }

    insertData.addAll({'recording_id': recordingId});

    await _database.insert(TABLE_DEVICE_ROTATIONS, insertData);
  }

  /// Read sql file as string from assets
  Future<String> _readSqlFile(String fileName) async {
    return await rootBundle.loadString('sql/$fileName');
  }
}
