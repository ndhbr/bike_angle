part of database_service;

class Queries {
  /// Create recordings table
  static final String createRecordingsTable = '''
    -- Recordings tables
     CREATE TABLE ${Tables.recordings}(
        ${Columns.re_id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Columns.re_title} TEXT,
        ${Columns.re_started_recording} INTEGER,
        ${Columns.re_stopped_recording} INTEGER
    );
  ''';

  /// Create device rotations table
  static final String createDeviceRotationsTable = '''
    -- Create device rotations table
    CREATE TABLE ${Tables.deviceRotations}(
        ${Columns.dr_id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Columns.dr_recording_id} INTEGER,
        ${Columns.dr_x} INTEGER,
        ${Columns.dr_y} INTEGER,
        ${Columns.dr_z} INTEGER,
        ${Columns.dr_captured_at} INTEGER,
        FOREIGN KEY(${Columns.dr_recording_id}) REFERENCES ${Tables.recordings}(${Columns.re_id}) ON DELETE CASCADE
    );
  ''';

  /// Drop recordings and device rotations table
  static final String dropDb = '''
    -- Drop both tables
    DROP TABLE ${Tables.recordings};
    DROP TABLE ${Tables.deviceRotations};
  ''';
}
