/// Status of a single diagnostic fact. Never invents values: unavailable,
/// failure, timeout, cancelled, networkChanged and permissionDenied are all
/// honest non-success outcomes (D-04, D-10, QUAL-05).
enum DiagnosticFactStatus {
  success,
  unavailable,
  failure,
  cancelled,
  timeout,
  networkChanged,
  permissionDenied,
}

/// Provenance describing how a probe fact was obtained. [method] is a literal
/// like 'TCP connect' or 'HTTPS' — never 'ping' (D-10).
class ProbeProvenance {
  const ProbeProvenance({
    required this.method,
    required this.target,
    required this.portOrUrl,
    required this.timeout,
    required this.limitations,
    this.thirdParty,
  });

  final String method;
  final String target;
  final String portOrUrl;
  final Duration timeout;
  final String limitations;
  final String? thirdParty;
}

/// An immutable, single fact produced by one contract. Sibling facts survive
/// independently: one failure never erases another (DIAG-10).
class DiagnosticFact {
  const DiagnosticFact({
    required this.status,
    this.value,
    this.message,
    this.provenance,
    this.occurredAt,
  });

  final DiagnosticFactStatus status;
  final String? value;
  final String? message;
  final ProbeProvenance? provenance;
  final DateTime? occurredAt;

  bool get isSuccess => status == DiagnosticFactStatus.success;

  DiagnosticFact copyWith({
    DiagnosticFactStatus? status,
    String? value,
    String? message,
    ProbeProvenance? provenance,
    DateTime? occurredAt,
  }) {
    return DiagnosticFact(
      status: status ?? this.status,
      value: value ?? this.value,
      message: message ?? this.message,
      provenance: provenance ?? this.provenance,
      occurredAt: occurredAt ?? this.occurredAt,
    );
  }

  static const DiagnosticFact unavailable = DiagnosticFact(
    status: DiagnosticFactStatus.unavailable,
  );
}
