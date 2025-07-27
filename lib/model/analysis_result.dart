// lib/model/analysis_result.dart

class ConversionData {
  final String unit;
  final double value;

  ConversionData({required this.unit, required this.value});
}

class AnalysisResult {
  final List<ConversionData> manufacturerConversions;
  final List<ConversionData> systemConversions;

  final String advertisedValue;
  final String advertisedUnit;

  final String realValue;
  final String realUnit;

  final String differenceValue;
  final String differenceUnit;

  AnalysisResult({
    required this.manufacturerConversions,
    required this.systemConversions,
    required this.advertisedValue,
    required this.advertisedUnit,
    required this.realValue,
    required this.realUnit,
    required this.differenceValue,
    required this.differenceUnit,
  });
}