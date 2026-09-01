import '../models/diagnostic_fact.dart';
import '../session/cancellation_scope.dart';

/// Contract 4 (D-05): fetches the public IPv4 fact over HTTPS. The
/// implementation registers its cancellation with [scope] and tags late
/// results with [runId] (D-07, D-12).
abstract class PublicIpSource {
  Future<DiagnosticFact> fetch({
    required int runId,
    required CancellationScope scope,
  });
}
