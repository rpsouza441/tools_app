import '../contracts/network_snapshot_source.dart';
import '../models/network_snapshot.dart';

/// Non-Android / test stub: reports no active network and all-null fields.
/// Never invents zero or a fake gateway (D-04, QUAL-05).
class UnsupportedNetworkSnapshotSource implements NetworkSnapshotSource {
  const UnsupportedNetworkSnapshotSource();

  @override
  Future<NetworkSnapshot> current() async {
    return const NetworkSnapshot(
      hasActiveNetwork: false,
      transports: [],
      hasInternet: null,
      validated: null,
      captivePortal: null,
      notMetered: null,
      localIpv4: null,
      gatewayIpv4: null,
      networkHandle: null,
    );
  }

  @override
  Future<void> startWatching(
    void Function(NetworkSnapshot snapshot) onChanged,
  ) async {}

  @override
  Future<void> stopWatching() async {}
}
