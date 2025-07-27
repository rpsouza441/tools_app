// lib/service/data_converter.dart
import '../model/analysis_result.dart';
import 'dart:math';

class DataConverter {
  // Fonte da verdade para as unidades e seus multiplicadores.
  // Removido 'B' conforme solicitado.
  static const Map<String, num> _decimalMultipliers = {
    'KB': 1e3,
    'MB': 1e6,
    'GB': 1e9,
    'TB': 1e12,
    'PB': 1e15,
  };

  static const Map<String, num> _binaryMultipliers = {
    'KiB': 1024,
    'MiB': 1024 * 1024,
    'GiB': 1024 * 1024 * 1024,
    'TiB': 1024 * 1024 * 1024 * 1024,
    'PiB': 1024 * 1024 * 1024 * 1024 * 1024,
  };

  // Mapeamento entre unidades, agora dentro da classe de lógica.
  static const Map<String, String> _unitComparisonMap = {
    'KB': 'KiB',
    'MB': 'MiB',
    'GB': 'GiB',
    'TB': 'TiB',
    'PB': 'PiB',
  };

  /// Expõe as unidades disponíveis para a UI não precisar hardcodá-las.
  static List<String> get availableUnits => _decimalMultipliers.keys.toList();

  /// Função única e centralizada que executa a análise completa.
  /// Recebe o valor bruto e retorna um objeto de resultado estruturado.
  static AnalysisResult analyze(double value, String fromUnit) {
    if (!_decimalMultipliers.containsKey(fromUnit)) {
      throw ArgumentError('Unidade de entrada inválida: $fromUnit');
    }

    // 1. Calcular o total de bytes com base na entrada (padrão decimal).
    final totalBytes = value * _decimalMultipliers[fromUnit]!;

    // 2. Gerar a lista de conversões para o padrão do fabricante (Base 10).
    final manufacturerConversions = _decimalMultipliers.entries
        .where((entry) => entry.key != fromUnit) // Pula a unidade de origem
        .map((entry) => ConversionData(unit: entry.key, value: totalBytes / entry.value))
        .toList();

    // 3. Gerar a lista de conversões para o padrão do sistema (Base 2).
    final systemConversions = _binaryMultipliers.entries
        .map((entry) => ConversionData(unit: entry.key, value: totalBytes / entry.value))
        .toList();

    // 4. Calcular os valores para o resumo.
    final comparableBinaryUnit = _unitComparisonMap[fromUnit]!;
    final realValueInComparableUnit = totalBytes / _binaryMultipliers[comparableBinaryUnit]!;
    final difference = value - realValueInComparableUnit;

    // 5. Retornar o objeto de resultado estruturado.
    // A formatação de números (`toStringAsFixed`, `NumberFormat`) NÃO pertence aqui.
    // A UI cuidará disso.
    return AnalysisResult(
      manufacturerConversions: manufacturerConversions,
      systemConversions: systemConversions,
      advertisedValue: value.toString(), // Enviando dados brutos
      advertisedUnit: fromUnit,
      realValue: realValueInComparableUnit.toString(),
      realUnit: comparableBinaryUnit,
      differenceValue: difference.toString(),
      differenceUnit: fromUnit, // A diferença é expressa na unidade original
    );
  }
}