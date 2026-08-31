import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tools_app/design_system/copy_value_action.dart';
import 'package:tools_app/design_system/tool_scaffold.dart';
import 'package:tools_app/design_system/tool_sections.dart';
import '../service/data_converter.dart';
import '../model/analysis_result.dart';

class DataConverterScreen extends StatefulWidget {
  const DataConverterScreen({super.key, this.copyWriter});

  final CopyValueWriter? copyWriter;

  @override
  State<DataConverterScreen> createState() => _DataConverterScreenState();
}

class _DataConverterScreenState extends State<DataConverterScreen> {
  final TextEditingController _valueController = TextEditingController();
  String _fromUnit = 'GB';
  AnalysisResult? _result;
  String? _error;

  // Formatter agora está firmemente na camada de apresentação (UI).
  final _numberFormatter = NumberFormat('#,##0.000', 'pt_BR');

  String _formatNumber(double number) => _numberFormatter.format(number);

  CopyValueWriter get _copyWriter =>
      widget.copyWriter ?? const ClipboardCopyWriter();

  String _formattedWithUnit(double value, String unit) =>
      '${_formatNumber(value)} $unit';

  void _calculate() {
    setState(() {
      _error = null;
      _result = null;

      final String input = _valueController.text.trim();
      if (input.isEmpty) {
        _error = 'Insira um valor';
        return;
      }

      final double? value = double.tryParse(input.replaceAll(',', '.'));
      if (value == null || value <= 0) {
        _error = 'Insira um valor numérico positivo';
        return;
      }

      try {
        // A UI chama a lógica e recebe um objeto de dados estruturado.
        _result = DataConverter.analyze(value, _fromUnit);
      } catch (e) {
        _error = e.toString().replaceAll('ArgumentError: ', '');
      }
    });
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ToolScaffold(
      title: 'Conversor de Armazenamento',
      children: [
        ToolInputSection(
          children: [
            TextField(
              controller: _valueController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Valor Anunciado',
                border: const OutlineInputBorder(),
                errorText: _error,
              ),
              onSubmitted: (_) => _calculate(),
            ),
            DropdownButtonFormField<String>(
              initialValue: _fromUnit,
              // A UI obtém a lista de unidades da fonte da verdade.
              items: DataConverter.availableUnits.map((unit) {
                return DropdownMenuItem(value: unit, child: Text(unit));
              }).toList(),
              onChanged: (value) => setState(() => _fromUnit = value!),
              decoration: InputDecoration(
                labelText: 'Unidade',
                labelStyle: Theme.of(context).textTheme.labelLarge,
                border: const OutlineInputBorder(),
              ),
              style: Theme.of(context).textTheme.bodyLarge,
              dropdownColor: Theme.of(context).colorScheme.surface,
            ),
          ],
        ),
        const SizedBox(height: 24),
        ToolActionGroup(
          primary: ElevatedButton(
            onPressed: _calculate,
            child: const Text('Analisar capacidade'),
          ),
        ),
        if (_result != null) ...[
          const SizedBox(height: 24),
          _buildResultCard(_result!),
        ],
        const SizedBox(height: 24),
        _buildExplanationCard(),
      ],
    );
  }

  Widget _buildResultCard(AnalysisResult result) {
    return ToolResultCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resultado da Análise',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Divider(height: 24),
          TechnicalValueRow(
            label: 'Valor anunciado',
            value: _formattedWithUnit(
              result.advertisedValue,
              result.advertisedUnit,
            ),
            copyWriter: _copyWriter,
          ),
          TechnicalValueRow(
            label: 'Valor real',
            value: _formattedWithUnit(result.realValue, result.realUnit),
            copyWriter: _copyWriter,
          ),
          TechnicalValueRow(
            label: 'Diferença',
            value: _formattedWithUnit(
              result.differenceValue,
              result.differenceUnit,
            ),
            copyWriter: _copyWriter,
          ),
          const SizedBox(height: 16),
          const Text(
            'Padrão do Fabricante (Base 10)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...result.manufacturerConversions.map(
            (data) => TechnicalValueRow(
              label: data.unit,
              value: _formattedWithUnit(data.value, data.unit),
              copyWriter: _copyWriter,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Padrão Real do Sistema (Base 2)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...result.systemConversions.map(
            (data) => TechnicalValueRow(
              label: data.unit,
              value: _formattedWithUnit(data.value, data.unit),
              copyWriter: _copyWriter,
            ),
          ),
          const Divider(height: 24),
          const Text(
            'Resumo da Diferença',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                const TextSpan(text: 'Um drive de '),
                TextSpan(
                  text: _formattedWithUnit(
                    result.advertisedValue,
                    result.advertisedUnit,
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: ' na verdade possui '),
                TextSpan(
                  text: _formattedWithUnit(result.realValue, result.realUnit),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
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
                TextSpan(
                  text: _formattedWithUnit(
                    result.differenceValue,
                    result.differenceUnit,
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationCard() {
    final iconColor = Theme.of(context).colorScheme.secondary;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return ToolResultCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Por que a capacidade parece menor?', // Título mais direto
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Informação do Fabricante
          ListTile(
            leading: Icon(Icons.storage_rounded, color: iconColor, size: 32),
            title: const Text('O Padrão do Fabricante (Base 10)'),
            subtitle: const Text(
              'Para marketing, 1 Gigabyte (GB) é um número redondo: 1 bilhão de bytes.',
            ),
            contentPadding: EdgeInsets.zero,
          ),

          // Informação do Sistema Operacional
          ListTile(
            leading: Icon(Icons.devices_rounded, color: iconColor, size: 32),
            title: const Text('O Padrão do Sistema (Base 2)'),
            subtitle: const Text(
              'O sistema operacional usa potências de 2, onde 1 Gibibyte (GiB) = 1.073.741.824 bytes.',
            ),
            contentPadding: EdgeInsets.zero,
          ),

          const Divider(height: 24, thickness: 0.5),

          // Resumo Prático
          RichText(
            text: TextSpan(
              style: TextStyle(color: textColor, height: 1.5),
              children: <TextSpan>[
                const TextSpan(text: 'Na prática: um drive anunciado como '),
                TextSpan(
                  text: '1 TB',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
                const TextSpan(
                  text: ' é lido pelo seu sistema como aproximadamente ',
                ),
                TextSpan(
                  text: '931 GiB',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
                const TextSpan(
                  text: '. Essa diferença é normal e não um defeito!',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
