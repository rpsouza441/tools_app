import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tools_app/design_system/copy_value_action.dart';
import 'package:tools_app/design_system/tool_scaffold.dart';
import 'package:tools_app/design_system/tool_sections.dart';
import 'package:tools_app/service/hash_calculator.dart';

class HashGeneratorScreen extends StatefulWidget {
  const HashGeneratorScreen({super.key, this.copyWriter});

  final CopyValueWriter? copyWriter;

  @override
  State<HashGeneratorScreen> createState() => _HashGeneratorScreenState();
}

class _HashGeneratorScreenState extends State<HashGeneratorScreen> {
  final TextEditingController _textController = TextEditingController();
  List<HashResult> _results = const [];
  String? _error;
  int _characterCount = 0;
  int _byteCount = 0;

  CopyValueWriter get _copyWriter =>
      widget.copyWriter ?? const ClipboardCopyWriter();

  void _calculate() {
    final input = _textController.text;
    final bytes = utf8.encode(input);

    setState(() {
      if (input.isEmpty) {
        _error = 'Digite ou cole um texto para calcular o hash.';
        _results = const [];
        _characterCount = 0;
        _byteCount = 0;
        return;
      }

      _error = null;
      _characterCount = input.runes.length;
      _byteCount = bytes.length;
      _results = HashCalculator.calculate(input);
    });
  }

  void _clear() {
    setState(() {
      _textController.clear();
      _results = const [];
      _error = null;
      _characterCount = 0;
      _byteCount = 0;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ToolScaffold(
      title: 'Gerador de Hash',
      children: [
        ToolInputSection(
          children: [
            TextField(
              controller: _textController,
              minLines: 5,
              maxLines: 8,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
                errorText: _error,
                hintText: 'ex: pacote-1.2.3.zip',
                labelText: 'Texto',
              ),
            ),
            Text(
              'MD5 e SHA-1 servem para conferência, não para proteger senhas.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.72),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ToolActionGroup(
          primary: ElevatedButton(
            onPressed: _calculate,
            child: const Text('Gerar hashes'),
          ),
          secondary: TextButton(
            onPressed: _clear,
            child: const Text('Limpar'),
          ),
        ),
        if (_results.isNotEmpty) ...[
          const SizedBox(height: 24),
          ToolMetricLayout(
            metrics: [
              ToolMetric(label: 'Caracteres', value: '$_characterCount'),
              ToolMetric(label: 'Bytes UTF-8', value: '$_byteCount'),
              ToolMetric(label: 'Algoritmos', value: '${_results.length}'),
            ],
          ),
          const SizedBox(height: 16),
          ..._results.map(
            (result) => TechnicalValueRow(
              label: result.algorithm,
              value: result.value,
              metadata:
                  '${result.bits} bits · ${result.strength} · ${result.value.length} hex',
              copyWriter: _copyWriter,
            ),
          ),
        ],
      ],
    );
  }
}
