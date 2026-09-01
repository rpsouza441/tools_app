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

/// Contract 5a (D-05): TCP-connect probe against the default gateway. Only
/// invoked when a gateway IPv4 exists (DIAG-06). Labelled 'TCP connect',
/// never 'ping' (D-10).
abstract class GatewayProbe {
  Future<ProbeOutcome> probe({
    required String gatewayIpv4,
    required int runId,
    required CancellationScope scope,
  });
}
