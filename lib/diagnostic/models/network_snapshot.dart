/// Immutable snapshot of the active network. Every field can be null/false;
/// the code never invents 192.168.1.1 or an isOnline boolean (DIAG-02, D-13).
class NetworkSnapshot {
  const NetworkSnapshot({
    required this.hasActiveNetwork,
    required this.transports,
    required this.hasInternet,
    required this.validated,
    required this.captivePortal,
    required this.notMetered,
    required this.localIpv4,
    required this.gatewayIpv4,
    required this.networkHandle,
  });

  /// Whether ConnectivityManager reports an active network at all.
  final bool hasActiveNetwork;

  /// Raw transport labels (wifi, cellular, vpn, ethernet, ...).
  final List<String> transports;

  /// NET_CAPABILITY_INTERNET present. Null when unknown.
  final bool? hasInternet;

  /// NET_CAPABILITY_VALIDATED present. Null when unknown.
  final bool? validated;

  /// NET_CAPABILITY_CAPTIVE_PORTAL present. Null when unknown.
  final bool? captivePortal;

  /// NET_CAPABILITY_NOT_METERED present. Null when unknown.
  final bool? notMetered;

  /// Active-network IPv4 (LinkProperties). Null when unavailable.
  final String? localIpv4;

  /// Default-route gateway IPv4 (RouteInfo). Null when unavailable.
  final String? gatewayIpv4;

  /// Opaque handle used to detect network changes across a run (QUAL-03).
  final int? networkHandle;
}
