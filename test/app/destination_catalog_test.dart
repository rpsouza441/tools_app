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

    test('ids remain the stable production identifiers', () {
      expect(appDestinations.map((d) => d.id).toList(), [
        'network_calculator',
        'data_converter',
        'hash_generator',
      ]);
    });

    test('labels are the short pt-BR catalog names', () {
      final labels = appDestinations.map((d) => d.label).toList();
      expect(labels, ['Rede', 'Armazenamento', 'Hash']);
    });

    test('semanticLabels are the full pt-BR names', () {
      final semanticLabels = appDestinations
          .map((d) => d.semanticLabel)
          .toList();
      expect(semanticLabels, [
        'Calculadora de Rede',
        'Conversor de Dados',
        'Gerador de Hash',
      ]);
    });

    test('appDestinations rejects mutation', () {
      final originalLength = appDestinations.length;
      try {
        expect(
          () => appDestinations.add(appDestinations.first),
          throwsUnsupportedError,
        );
      } finally {
        while (appDestinations.length > originalLength) {
          appDestinations.removeLast();
        }
      }
    });

    test('each destination has paired icons (filled + outlined)', () {
      for (final dest in appDestinations) {
        expect(dest.icon, isNotNull);
        expect(dest.selectedIcon, isNotNull);
        expect(
          dest.icon != dest.selectedIcon,
          isTrue,
          reason: '${dest.id} must have distinct icon/selectedIcon',
        );
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
  });
}

class _FakeBuildContext extends Fake implements BuildContext {}
