-- Initialize bike angle sqlite database
CREATE TABLE recordings(id INTEGER PRIMARY KEY, started_recording INTEGER, stopped_recording INTEGER);
CREATE TABLE device_rotations(
    recording_id INTEGER,
    pitch INTEGER,
    roll INTEGER,
    captured_at INTEGER,
    FOREIGN KEY(recording_id) REFERENCES recordings(id)
);
