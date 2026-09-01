import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'aggregation/latency_aggregator.dart';
import 'contracts/diagnostic_session.dart';
import 'contracts/network_snapshot_source.dart';
import 'contracts/public_ip_source.dart';
import 'contracts/gateway_probe.dart';
import 'contracts/internet_probe.dart';
import 'contracts/share_text_port.dart';
import 'gateway/snapshot_default_gateway_source.dart';
import 'local/snapshot_local_ipv4_source.dart';
import 'platform/android_network_snapshot_source.dart';
import 'platform/android_share_text_port.dart';
import 'platform/unsupported_network_snapshot_source.dart';
import 'probes/dio_https_probe.dart';
import 'probes/probe_config.dart';
import 'probes/tcp_connect_probe.dart';
import 'probes/unavailable_gateway_probe.dart';
import 'probes/unavailable_internet_probe.dart';
import 'public_ip/dio_public_ip_source.dart';
import 'public_ip/public_ip_config.dart';
import 'public_ip/unavailable_public_ip_source.dart';
import 'session/diagnostic_session_impl.dart';
import 'share/noop_share_text_port.dart';

// Platform check that is safe on web (dart:io is unavailable there).
import 'diagnostic_platform_io.dart'
    if (dart.library.html) 'diagnostic_platform_web.dart';

/// Production composition root for the diagnostic session.
///
/// On Android, wires the real adapters (Android snapshot, ipify public IP,
/// TCP-connect gateway probe, HTTPS internet probe). On every other platform
/// (including web), keeps honest unavailable/unsupported stubs — never
/// promising unverified capabilities (D-04, D-05).
class DiagnosticDefaults {
  const DiagnosticDefaults._();

  static DiagnosticSession createSession() {
    final bool android = !kIsWeb && isAndroidPlatform();

    final NetworkSnapshotSource snapshotSource = android
        ? AndroidNetworkSnapshotSource()
        : const UnsupportedNetworkSnapshotSource();

    final PublicIpSource publicIpSource = android
        ? DioPublicIpSource(Dio(), const PublicIpConfig())
        : const UnavailablePublicIpSource();

    final GatewayProbe gatewayProbe = android
        ? TcpConnectGatewayProbe(config: const GatewayProbeConfig())
        : const UnavailableGatewayProbe();

    final InternetProbe internetProbe = android
        ? DioHttpsInternetProbe(Dio(), config: const HttpsProbeConfig())
        : const UnavailableInternetProbe();

    return DiagnosticSessionImpl(
      snapshotSource: snapshotSource,
      localIpv4Source: const SnapshotLocalIpv4Source(),
      gatewaySource: const SnapshotDefaultGatewaySource(),
      publicIpSource: publicIpSource,
      gatewayProbe: gatewayProbe,
      internetProbe: internetProbe,
      aggregator: const LatencyAggregator(),
    );
  }

  /// Share port: native Intent.ACTION_SEND on Android, no-op elsewhere.
  static ShareTextPort createSharePort() {
    final bool android = !kIsWeb && isAndroidPlatform();
    return android ? AndroidShareTextPort() : const NoopShareTextPort();
  }
}
