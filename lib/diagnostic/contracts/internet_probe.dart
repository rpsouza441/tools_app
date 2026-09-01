import 'gateway_probe.dart' show ProbeOutcome;
import '../session/cancellation_scope.dart';

export 'gateway_probe.dart' show ProbeOutcome;

/// Contract 5b (D-05): HTTPS reachability/latency probe against an approved,
/// injectable target. Labelled 'HTTPS', never 'ping' (D-10, D-12).
abstract class InternetProbe {
  Future<ProbeOutcome> probe({
    required int runId,
    required CancellationScope scope,
  });
}
