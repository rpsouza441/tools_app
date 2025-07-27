// lib/screens/data_converter_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../service/data_converter.dart';
import '../model/analysis_result.dart';

class DataConverterScreen extends StatefulWidget {
  const DataConverterScreen({super.key});

  @override
  State<DataConverterScreen> createState() => _DataConverterScreenState();
}

class _DataConverterScreenState extends State<DataConverterScreen> {
  final TextEditingController _valueController = TextEditingController();
  String _fromUnit = 'GB';
  AnalysisResult? _result;
  String? _error;
  bool _isLoading = false;

  // Formatter agora está firmemente na camada de apresentação (UI).
  final _numberFormatter = NumberFormat('#,##0.000', 'pt_BR');
  String _formatNumber(double number) => _numberFormatter.format(number);

  void _calculate() {
    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;

      final String input = _valueController.text.trim();
      if (input.isEmpty) {
        _error = 'Insira um valor';
        _isLoading = false;
        return;
      }

      final double? value = double.tryParse(input.replaceAll(',', '.'));
      if (value == null || value <= 0) {
        _error = 'Insira um valor numérico positivo';
        _isLoading = false;
        return;
      }

      try {
        // A UI chama a lógica e recebe um objeto de dados estruturado.
        _result = DataConverter.analyze(value, _fromUnit);
      } catch (e) {
        _error = e.toString().replaceAll('ArgumentError: ', '');
      } finally {
        _isLoading = false;
      }
    });
  }

  void _clear() {
    setState(() {
      _valueController.clear();
      _result = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversor de Armazenamento'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- CARD DE ENTRADA ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _valueController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Valor Anunciado',
                              border: const OutlineInputBorder(),
                              errorText: _error,
                            ),
                            onSubmitted: (_) => _calculate(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: _fromUnit,
                            // A UI obtém a lista de unidades da fonte da verdade.
                            items: DataConverter.availableUnits.map((unit) {
                              return DropdownMenuItem(value: unit, child: Text(unit));
                            }).toList(),
                            onChanged: (value) => setState(() => _fromUnit = value!),
                            decoration: InputDecoration(
                              labelText: 'Unidade',
                              labelStyle: Theme.of(context).textTheme.labelLarge,
                              border: OutlineInputBorder(),
                            ),
                            style: Theme.of(context).textTheme.bodyLarge,
                            dropdownColor: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16.0)),
                        onPressed: _isLoading ? null : _calculate,
                        child: _isLoading ? const CircularProgressIndicator() : const Text('Analisar Capacidade'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- CARD DE RESULTADO (CONSTRUÍDO DINAMICAMENTE) ---
            if (_result != null) _buildResultCard(_result!),

            const SizedBox(height: 16),

            // --- CARD DE EXPLICAÇÃO (Estático) ---
            _buildExplanationCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(AnalysisResult result) {
    final textStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      fontFamily: 'monospace',
      height: 1.6,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resultado da Análise', style: Theme.of(context).textTheme.titleMedium),
            const Divider(height: 24),

            const Text('Padrão do Fabricante (Base 10)', style: TextStyle(fontWeight: FontWeight.bold)),
            ...result.manufacturerConversions.map(
                  (data) => Text('${_formatNumber(data.value)} ${data.unit}', style: textStyle),
            ),

            const SizedBox(height: 16),
            const Text('Padrão Real do Sistema (Base 2)', style: TextStyle(fontWeight: FontWeight.bold)),
            ...result.systemConversions.map(
                  (data) => Text('${_formatNumber(data.value)} ${data.unit}', style: textStyle),
            ),

            const Divider(height: 24),
            const Text('Resumo da Diferença', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  const TextSpan(text: 'Um drive de '),
                  TextSpan(text: '${_formatNumber(double.parse(result.advertisedValue))} ${result.advertisedUnit}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(text: ' na verdade possui '),
                  TextSpan(text: '${_formatNumber(double.parse(result.realValue))} ${result.realUnit}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(text: ' no sistema.'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  const TextSpan(text: 'Diferença "perdida": '),
                  TextSpan(text: '${_formatNumber(double.parse(result.differenceValue))} ${result.differenceUnit}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Por que essa diferença existe?', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text(
              '• Fabricantes (Base 10): 1 GB = 1.000.000.000 bytes.\n'
                  '• Sistemas (Base 2): 1 GiB = 1.073.741.824 bytes.\n'
                  'Essa discrepância de ~7.4% é o padrão da indústria e não um defeito.',
              style: TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}