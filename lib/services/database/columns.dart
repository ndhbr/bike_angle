part of database_service;

class Columns {
  /// Recordings table
  static const String re_id = 'id';
  static const String re_started_recording = 'started_recording';
  static const String re_stopped_recording = 'stopped_recording';

  /// Device Rotation Table
  static const String dr_id = 'id';
  static const String dr_recording_id = 'recording_id';
  static const String dr_x = 'x';
  static const String dr_y = 'y';
  static const String dr_z = 'z';
  static const String dr_captured_at = 'captured_at';
}