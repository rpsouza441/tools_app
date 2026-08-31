import 'package:flutter_test/flutter_test.dart';
import 'package:tools_app/service/hash_calculator.dart';

void main() {
  group('HashCalculator', () {
    test('calculates known digests for abc', () {
      final results = {
        for (final result in HashCalculator.calculate('abc'))
          result.algorithm: result.value,
      };

      expect(results['MD5'], '900150983cd24fb0d6963f7d28e17f72');
      expect(results['SHA-1'], 'a9993e364706816aba3e25717850c26c9cd0d89d');
      expect(
        results['SHA-256'],
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
      );
      expect(
        results['SHA-512'],
        'ddaf35a193617abacc417349ae204131'
        '12e6fa4e89a97ea20a9eeee64b55d39a'
        '2192992a274fc1a836ba3c23a3feebbd'
        '454d4423643ce80e2a9ac94fa54ca49f',
      );
    });
  });
}
