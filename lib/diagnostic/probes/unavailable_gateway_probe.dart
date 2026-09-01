import '../contracts/gateway_probe.dart';
import '../models/diagnostic_fact.dart';
import '../models/latency_aggregate.dart';
import '../session/cancellation_scope.dart';

/// Gateway probe stub: unavailable, no socket I/O (D-04, D-10).
class UnavailableGatewayProbe implements GatewayProbe {
  const UnavailableGatewayProbe();

  @override
  Future<ProbeOutcome> probe({
    required String gatewayIpv4,
    required int runId,
    required CancellationScope scope,
  }) async {
    return const ProbeOutcome(
      samples: [],
      aggregate: LatencyAggregate.empty,
      summary: DiagnosticFact(
        status: DiagnosticFactStatus.unavailable,
        message: 'Probe de gateway indisponível',
      ),
    );
  }
}
