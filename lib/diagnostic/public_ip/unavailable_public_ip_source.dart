import '../contracts/public_ip_source.dart';
import '../models/diagnostic_fact.dart';
import '../session/cancellation_scope.dart';

/// Public IP stub: reports unavailable without any network I/O (D-04, QUAL-05).
class UnavailablePublicIpSource implements PublicIpSource {
  const UnavailablePublicIpSource();

  @override
  Future<DiagnosticFact> fetch({
    required int runId,
    required CancellationScope scope,
  }) async {
    return const DiagnosticFact(
      status: DiagnosticFactStatus.unavailable,
      message: 'IP público indisponível nesta plataforma',
    );
  }
}
