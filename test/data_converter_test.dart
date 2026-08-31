import 'package:flutter_test/flutter_test.dart';
import 'package:tools_app/service/data_converter.dart';

void main() {
  group('DataConverter', () {
    test('compares advertised TB with system TiB value', () {
      final result = DataConverter.analyze(1, 'TB');

      expect(result.advertisedValue, 1);
      expect(result.advertisedUnit, 'TB');
      expect(result.realUnit, 'TiB');
      expect(result.realValue, closeTo(0.9094947017, 0.0000000001));
      expect(result.differenceValue, closeTo(0.0905052982, 0.0000000001));
    });

    test('rejects unavailable unit', () {
      expect(() => DataConverter.analyze(1, 'B'), throwsArgumentError);
    });
  });
}
