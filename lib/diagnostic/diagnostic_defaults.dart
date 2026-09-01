import 'aggregation/latency_aggregator.dart';
import 'contracts/diagnostic_session.dart';
import 'gateway/snapshot_default_gateway_source.dart';
import 'local/snapshot_local_ipv4_source.dart';
import 'platform/unsupported_network_snapshot_source.dart';
import 'probes/unavailable_gateway_probe.dart';
import 'probes/unavailable_internet_probe.dart';
import 'public_ip/unavailable_public_ip_source.dart';
import 'session/diagnostic_session_impl.dart';

/// Production composition root for the diagnostic session.
///
/// In this slice it wires only stub adapters (unavailable/unsupported). Real
/// Android snapshot, Dio public IP and TCP/HTTPS probes are wired in 03-06.
class DiagnosticDefaults {
  const DiagnosticDefaults._();

  static DiagnosticSession createSession() {
    return DiagnosticSessionImpl(
      snapshotSource: const UnsupportedNetworkSnapshotSource(),
      localIpv4Source: const SnapshotLocalIpv4Source(),
      gatewaySource: const SnapshotDefaultGatewaySource(),
      publicIpSource: const UnavailablePublicIpSource(),
      gatewayProbe: const UnavailableGatewayProbe(),
      internetProbe: const UnavailableInternetProbe(),
      aggregator: const LatencyAggregator(),
    );
  }
}
