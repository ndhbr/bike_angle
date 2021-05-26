import 'package:bikeangle/services/database/controller.dart';

class Recording {
  int id;
  String title;
  int startedRecordingTimestamp;
  int stoppedRecordingTimestamp;

  Recording({
    this.id,
    this.title,
    this.startedRecordingTimestamp,
    this.stoppedRecordingTimestamp,
  });

  factory Recording.fromDatabase(Map<String, Object> data) {
    return Recording(
      id: data[Columns.re_id] ?? 0,
      title: data[Columns.re_title] ?? 'Fahrt #${data[Columns.re_id] ?? 0}',
      startedRecordingTimestamp: data[Columns.re_started_recording] ?? 0,
      stoppedRecordingTimestamp: data[Columns.re_stopped_recording] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Columns.re_started_recording: this.startedRecordingTimestamp,
      Columns.re_stopped_recording: this.stoppedRecordingTimestamp ?? null,
    };
  }
}
