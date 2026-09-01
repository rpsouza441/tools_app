import '../contracts/local_ipv4_source.dart';
import '../models/diagnostic_fact.dart';
import '../models/network_snapshot.dart';

/// Reads the active-network IPv4 from the snapshot. Null → unavailable;
/// never writes 192.168.1.1 (DIAG-03, D-05).
class SnapshotLocalIpv4Source implements LocalIpv4Source {
  const SnapshotLocalIpv4Source();

  @override
  DiagnosticFact fromSnapshot(NetworkSnapshot snapshot) {
    final ip = snapshot.localIpv4;
    if (ip == null || ip.isEmpty) {
      return const DiagnosticFact(
        status: DiagnosticFactStatus.unavailable,
        message: 'IPv4 local indisponível',
      );
    }
    return DiagnosticFact(status: DiagnosticFactStatus.success, value: ip);
  }
}
