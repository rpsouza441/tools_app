import '../models/diagnostic_fact.dart';
import '../models/network_snapshot.dart';

/// Contract 3 (D-05): derives the default-route gateway fact from the snapshot.
/// Returns unavailable when there is no gateway; never assumes 192.168.x.1.
abstract class DefaultGatewaySource {
  DiagnosticFact fromSnapshot(NetworkSnapshot snapshot);
}
