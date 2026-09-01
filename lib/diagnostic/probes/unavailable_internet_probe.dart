import '../contracts/internet_probe.dart';
import '../models/diagnostic_fact.dart';
import '../models/latency_aggregate.dart';
import '../session/cancellation_scope.dart';

/// Internet probe stub: unavailable, no HTTPS I/O (D-04, D-10).
class UnavailableInternetProbe implements InternetProbe {
  const UnavailableInternetProbe();

  @override
  Future<ProbeOutcome> probe({
    required int runId,
    required CancellationScope scope,
  }) async {
    return const ProbeOutcome(
      samples: [],
      aggregate: LatencyAggregate.empty,
      summary: DiagnosticFact(
        status: DiagnosticFactStatus.unavailable,
        message: 'Probe de internet indisponível',
      ),
    );
  }
}
