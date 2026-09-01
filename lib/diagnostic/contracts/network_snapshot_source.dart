import '../models/network_snapshot.dart';

/// Contract 1 (D-05): reads the active-network snapshot. Backed by an Android
/// platform adapter in production; a stub elsewhere. Never a NetworkService.
abstract class NetworkSnapshotSource {
  Future<NetworkSnapshot> current();
  Future<void> startWatching(void Function(NetworkSnapshot snapshot) onChanged);
  Future<void> stopWatching();
}
