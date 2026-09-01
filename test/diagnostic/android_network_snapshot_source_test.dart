// Parser + MethodChannel tests for the Android snapshot adapter (03-02).
// Fakes only, no mockito. Verifies null gateway/local (never invented) and
// channel plumbing (DIAG-02/03/04, QUAL-06).
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tools_app/diagnostic/platform/android_network_snapshot_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NetworkSnapshotMapParser', () {
    test('mapa completo preenche AndroidSnapshotFacts 1:1', () {
      final facts = NetworkSnapshotMapParser.parse(<String, dynamic>{
        'hasActiveNetwork': true,
        'transports': <String>['wifi'],
        'hasInternet': true,
        'validated': true,
        'captive': false,
        'notMetered': true,
        'localIpv4': '10.0.0.5',
        'gatewayIpv4': '10.0.0.1',
        'networkHandle': 42,
      });

      expect(facts.hasActiveNetwork, isTrue);
      expect(facts.transports, ['wifi']);
      expect(facts.hasInternet, isTrue);
      expect(facts.validated, isTrue);
      expect(facts.captive, isFalse);
      expect(facts.notMetered, isTrue);
      expect(facts.localIpv4, '10.0.0.5');
      expect(facts.gatewayIpv4, '10.0.0.1');
      expect(facts.networkHandle, 42);
    });

    test('mapa sem localIpv4/gatewayIpv4 → null, nunca 192.168.1.1', () {
      final facts = NetworkSnapshotMapParser.parse(<String, dynamic>{
        'hasActiveNetwork': true,
        'transports': <String>['cellular'],
        'hasInternet': true,
        'validated': true,
        'captive': false,
        'notMetered': false,
        'localIpv4': null,
        'gatewayIpv4': null,
        'networkHandle': 7,
      });

      expect(facts.localIpv4, isNull);
      expect(facts.gatewayIpv4, isNull);
    });

    test('hasActiveNetwork false → transports vazio, IPs null', () {
      final facts = NetworkSnapshotMapParser.parse(<String, dynamic>{
        'hasActiveNetwork': false,
        'transports': <String>[],
        'hasInternet': false,
        'validated': false,
        'captive': false,
        'notMetered': false,
        'localIpv4': null,
        'gatewayIpv4': null,
        'networkHandle': null,
      });

      expect(facts.hasActiveNetwork, isFalse);
      expect(facts.transports, isEmpty);
      expect(facts.localIpv4, isNull);
      expect(facts.gatewayIpv4, isNull);
      expect(facts.networkHandle, isNull);
    });
  });

  group('AndroidNetworkSnapshotSource', () {
    late List<MethodCall> calls;

    setUp(() => calls = <MethodCall>[]);

    void install(Future<Object?>? Function(MethodCall) handler) {
      TestDefaultBinaryMessengerBinding
          .instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel(kNetworkSnapshotChannel),
        (call) async {
          calls.add(call);
          return handler(call);
        },
      );
    }

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel(kNetworkSnapshotChannel),
        null,
      );
    });

    test('currentFacts() propaga o mapa do canal getSnapshot', () async {
      install((call) async {
        if (call.method == 'getSnapshot') {
          return <String, dynamic>{
            'hasActiveNetwork': true,
            'transports': <String>['wifi'],
            'hasInternet': true,
            'validated': true,
            'captive': false,
            'notMetered': true,
            'localIpv4': '192.168.0.42',
            'gatewayIpv4': '192.168.0.1',
            'networkHandle': 99,
          };
        }
        return null;
      });

      final source = AndroidNetworkSnapshotSource();
      final facts = await source.currentFacts();

      expect(calls.single.method, 'getSnapshot');
      expect(facts.localIpv4, '192.168.0.42');
      expect(facts.gatewayIpv4, '192.168.0.1');
      expect(facts.transports, ['wifi']);
    });

    test('startWatching/stopWatching invocam os métodos do canal', () async {
      install((call) async => null);

      final source = AndroidNetworkSnapshotSource();
      await source.startWatching((_) {});
      await source.stopWatching();

      expect(calls.map((c) => c.method), containsAll(<String>[
        'startWatching',
        'stopWatching',
      ]));
    });
  });
}
