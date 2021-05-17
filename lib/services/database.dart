import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const DB_NAME = 'bike_angle_database.db';
const INIT_SQL_FILE = 'init.sql';

class DatabaseService {

  /// Database instance
  Database _database;

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

  /// Read sql file as string from assets
  Future<String> _readSqlFile(String fileName) async {
    return await rootBundle.loadString('assets/$fileName');
  }
}
