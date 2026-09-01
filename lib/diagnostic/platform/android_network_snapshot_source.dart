import 'package:flutter/services.dart';

import '../contracts/network_snapshot_source.dart';
import '../models/network_snapshot.dart';

/// MethodChannel name shared with the Kotlin NetworkSnapshotPlugin.
const String kNetworkSnapshotChannel =
    'br.dev.rodrigopinheiro.tools_app/network_snapshot';

/// Serializable facts returned by the Android snapshot plugin. Mirrors the
/// Kotlin map 1:1. IPv4 fields may be null and are never invented (DIAG-03/04).
class AndroidSnapshotFacts {
  const AndroidSnapshotFacts({
    required this.hasActiveNetwork,
    required this.transports,
    required this.hasInternet,
    required this.validated,
    required this.captive,
    required this.notMetered,
    required this.localIpv4,
    required this.gatewayIpv4,
    required this.networkHandle,
  });

  final bool hasActiveNetwork;
  final List<String> transports;
  final bool hasInternet;
  final bool validated;
  final bool captive;
  final bool notMetered;
  final String? localIpv4;
  final String? gatewayIpv4;
  final int? networkHandle;
}

/// Pure parser from the channel map to [AndroidSnapshotFacts]. Kept independent
/// of the diagnostic contracts; 03-06 wraps this into a NetworkSnapshotSource.
class NetworkSnapshotMapParser {
  const NetworkSnapshotMapParser._();

  static AndroidSnapshotFacts parse(Map<String, dynamic> map) {
    final transportsRaw = map['transports'];
    final transports = transportsRaw is List
        ? transportsRaw.map((e) => e.toString()).toList(growable: false)
        : const <String>[];

    final handleRaw = map['networkHandle'];
    final int? networkHandle = handleRaw is int
        ? handleRaw
        : (handleRaw is num ? handleRaw.toInt() : null);

    return AndroidSnapshotFacts(
      hasActiveNetwork: map['hasActiveNetwork'] == true,
      transports: transports,
      hasInternet: map['hasInternet'] == true,
      validated: map['validated'] == true,
      captive: map['captive'] == true,
      notMetered: map['notMetered'] == true,
      localIpv4: _nullableString(map['localIpv4']),
      gatewayIpv4: _nullableString(map['gatewayIpv4']),
      networkHandle: networkHandle,
    );
  }

  static String? _nullableString(Object? value) {
    if (value == null) return null;
    final s = value.toString();
    return s.isEmpty ? null : s;
  }
}

/// Reads the active-network snapshot from the Android plugin over a
/// MethodChannel. Implements [NetworkSnapshotSource] by mapping the raw
/// [AndroidSnapshotFacts] into the domain [NetworkSnapshot] (03-06 wiring).
class AndroidNetworkSnapshotSource implements NetworkSnapshotSource {
  AndroidNetworkSnapshotSource({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(kNetworkSnapshotChannel);

  final MethodChannel _channel;
  void Function()? _onChanged;

  Future<AndroidSnapshotFacts> currentFacts() async {
    final result = await _channel.invokeMethod<dynamic>('getSnapshot');
    final map = (result as Map).cast<String, dynamic>();
    return NetworkSnapshotMapParser.parse(map);
  }

  /// Maps the raw Android facts into the domain [NetworkSnapshot].
  @override
  Future<NetworkSnapshot> current() async {
    final facts = await currentFacts();
    return NetworkSnapshot(
      hasActiveNetwork: facts.hasActiveNetwork,
      transports: facts.transports,
      hasInternet: facts.hasInternet,
      validated: facts.validated,
      captivePortal: facts.captive,
      notMetered: facts.notMetered,
      localIpv4: facts.localIpv4,
      gatewayIpv4: facts.gatewayIpv4,
      networkHandle: facts.networkHandle,
    );
  }

  @override
  Future<void> startWatching(
    void Function(NetworkSnapshot snapshot) onChanged,
  ) async {
    _onChanged = () async {
      final snapshot = await current();
      onChanged(snapshot);
    };
    _channel.setMethodCallHandler(_handleCall);
    await _channel.invokeMethod<void>('startWatching');
  }

  @override
  Future<void> stopWatching() async {
    await _channel.invokeMethod<void>('stopWatching');
    _onChanged = null;
  }

  Future<dynamic> _handleCall(MethodCall call) async {
    if (call.method == 'onNetworkChanged') {
      _onChanged?.call();
    }
    return null;
  }
}
