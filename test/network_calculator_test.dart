import 'package:flutter_test/flutter_test.dart';
import 'package:tools_app/service/network_calculator.dart';
import 'package:tools_app/utils/network_utils.dart';

void main() {
  group('network validators', () {
    test('validates IPv4 format and range', () {
      expect(isValidIp('192.168.1.1'), isTrue);
      expect(isValidIp('255.255.255.255'), isTrue);
      expect(isValidIp('256.1.1.1'), isFalse);
      expect(isValidIp('192.168.1'), isFalse);
    });

    test('validates cidr range', () {
      expect(isValidCidr('0'), isTrue);
      expect(isValidCidr('32'), isTrue);
      expect(isValidCidr('33'), isFalse);
      expect(isValidCidr('abc'), isFalse);
    });
  });

  group('NetworkCalculator', () {
    test('calculates common /24 network values', () {
      final calculator = NetworkCalculator(ipAddress: '192.168.1.10', cidr: 24);
      final network = calculator.calculateNetworkAddress();
      final broadcast = calculator.calculateBroadcastAddress();

      expect(network, '192.168.1.0');
      expect(broadcast, '192.168.1.255');
      expect(calculator.subnetMask, '255.255.255.0');
      expect(
        calculator.calculateIpRange(network, broadcast),
        '192.168.1.1 - 192.168.1.254',
      );
      expect(calculator.calculateUsableHostCount(), 254);
    });

    test('keeps both addresses usable for /31 networks', () {
      final calculator = NetworkCalculator(ipAddress: '10.0.0.4', cidr: 31);
      final network = calculator.calculateNetworkAddress();
      final broadcast = calculator.calculateBroadcastAddress();

      expect(network, '10.0.0.4');
      expect(broadcast, '10.0.0.5');
      expect(
        calculator.calculateIpRange(network, broadcast),
        '10.0.0.4 - 10.0.0.5',
      );
      expect(calculator.calculateUsableHostCount(), 2);
    });

    test('handles /32 host route', () {
      final calculator = NetworkCalculator(ipAddress: '10.0.0.9', cidr: 32);
      final network = calculator.calculateNetworkAddress();
      final broadcast = calculator.calculateBroadcastAddress();

      expect(network, '10.0.0.9');
      expect(broadcast, '10.0.0.9');
      expect(calculator.calculateIpRange(network, broadcast), '10.0.0.9');
      expect(calculator.calculateUsableHostCount(), 1);
    });
  });
}
