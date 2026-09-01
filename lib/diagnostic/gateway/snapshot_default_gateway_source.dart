import '../contracts/default_gateway_source.dart';
import '../models/diagnostic_fact.dart';
import '../models/network_snapshot.dart';

/// Reads the default-route gateway IPv4 from the snapshot. Null → unavailable;
/// never assumes 192.168.x.1 (DIAG-04, D-05).
class SnapshotDefaultGatewaySource implements DefaultGatewaySource {
  const SnapshotDefaultGatewaySource();

  @override
  DiagnosticFact fromSnapshot(NetworkSnapshot snapshot) {
    final gw = snapshot.gatewayIpv4;
    if (gw == null || gw.isEmpty) {
      return const DiagnosticFact(
        status: DiagnosticFactStatus.unavailable,
        message: 'Gateway indisponível',
      );
    }
    return DiagnosticFact(status: DiagnosticFactStatus.success, value: gw);
  }
}
