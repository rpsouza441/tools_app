import '../models/diagnostic_fact.dart';
import '../models/network_snapshot.dart';

/// Contract 2 (D-05): derives the active-network local IPv4 fact from the
/// snapshot only — never NetworkInterface.list.
abstract class LocalIpv4Source {
  DiagnosticFact fromSnapshot(NetworkSnapshot snapshot);
}
