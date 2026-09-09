import 'diagnostic_fact.dart';
import 'latency_aggregate.dart';

/// Independent samples and statistics for one gateway TCP port.
class TcpPortResult {
  const TcpPortResult({
    required this.port,
    required this.samples,
    required this.aggregate,
    required this.summary,
  });

  final int port;
  final List<DiagnosticFact> samples;
  final LatencyAggregate aggregate;
  final DiagnosticFact summary;
}
