import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tools_app/app/app_destinations.dart';
import 'package:tools_app/screen/network_calculator_screen.dart';
import 'package:tools_app/screen/data_converter_screen.dart';
import 'package:tools_app/screen/hash_generator_screen.dart';

void main() {
  group('AppDestination catalog contract', () {
    test('ids are unique and stable across accesses', () {
      final ids = appDestinations.map((d) => d.id).toList();
      expect(ids.toSet().length, ids.length, reason: 'IDs must be unique');
      // Stable: same list on second access
      final ids2 = appDestinations.map((d) => d.id).toList();
      expect(ids, ids2);
    });

    test('labels are in pt-BR', () {
      final labels = appDestinations.map((d) => d.label).toList();
      expect(labels, contains('Calculadora de Rede'));
      expect(labels, contains('Conversor de Dados'));
      expect(labels, contains('Gerador de Hash'));
    });

    test('each destination has paired icons (filled + outlined)', () {
      for (final dest in appDestinations) {
        expect(dest.icon, isNotNull);
        expect(dest.selectedIcon, isNotNull);
        expect(dest.icon != dest.selectedIcon, isTrue,
            reason: '${dest.id} must have distinct icon/selectedIcon');
      }
    });

    test('order is Rede, Armazenamento, Hash by category', () {
      expect(appDestinations[0].category, AppDestinationCategory.rede);
      expect(appDestinations[1].category, AppDestinationCategory.armazenamento);
      expect(appDestinations[2].category, AppDestinationCategory.hash);
    });

    test('pageBuilder factories produce the current screens', () {
      final context = _FakeBuildContext();
      final pages = appDestinations.map((d) => d.pageBuilder(context)).toList();
      expect(pages[0], isA<NetworkCalculatorScreen>());
      expect(pages[1], isA<DataConverterScreen>());
      expect(pages[2], isA<HashGeneratorScreen>());
    });

    test('compactPriority values are assigned', () {
      for (final dest in appDestinations) {
        expect(dest.compactPriority, isA<int>());
      }
    });

    test('semanticLabel is provided for each destination', () {
      for (final dest in appDestinations) {
        expect(dest.semanticLabel, isNotEmpty);
      }
    });
  });
}

class _FakeBuildContext extends Fake implements BuildContext {}
