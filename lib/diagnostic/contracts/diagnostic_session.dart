import 'package:flutter/foundation.dart';

import '../models/diagnostic_run_state.dart';

/// Contract 6 (D-05): the orchestration boundary the UI observes. One run at a
/// time; the UI reads immutable state and never sees Dio/Socket (D-06, D-08).
abstract class DiagnosticSession {
  ValueListenable<DiagnosticRunState> get listenable;
  DiagnosticRunState get state;
  Future<void> start();
  Future<void> cancel();
  Future<void> refreshSnapshotOnly();
  void dispose();
}
