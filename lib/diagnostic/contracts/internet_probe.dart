import '../models/diagnostic_fact.dart';
import '../models/latency_aggregate.dart';
import '../session/cancellation_scope.dart';

/// The result of running a probe: raw samples, an aggregate, and a summary fact.
class ProbeOutcome {
  const ProbeOutcome({
    required this.samples,
    required this.aggregate,
    required this.summary,
  });

  final List<DiagnosticFact> samples;
  final LatencyAggregate aggregate;
  final DiagnosticFact summary;
}

/// Contract 5b (D-05): HTTPS reachability/latency probe against an approved,
/// injectable target. Labelled 'HTTPS', never 'ping' (D-10, D-12).
abstract class InternetProbe {
  Future<ProbeOutcome> probe({
    required int runId,
    required CancellationScope scope,
  });
}
