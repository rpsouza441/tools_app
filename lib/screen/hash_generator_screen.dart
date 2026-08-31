import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tools_app/service/hash_calculator.dart';
import 'dart:convert';

class HashGeneratorScreen extends StatefulWidget {
  const HashGeneratorScreen({super.key});

  @override
  State<HashGeneratorScreen> createState() => _HashGeneratorScreenState();
}

class _HashGeneratorScreenState extends State<HashGeneratorScreen> {
  final TextEditingController _textController = TextEditingController();
  List<HashResult> _results = const [];
  String? _error;
  int _characterCount = 0;
  int _byteCount = 0;

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

  Future<void> _copy(HashResult result) async {
    await Clipboard.setData(ClipboardData(text: result.value));

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${result.algorithm} copiado')));
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Gerador de Hash')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    const SizedBox(height: 8),
                    Text(
                      'MD5 e SHA-1 servem para conferência, não para proteger senhas.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.72),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: ElevatedButton.icon(
                            onPressed: _calculate,
                            icon: const Icon(Icons.tag),
                            label: const Text('Calcular'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: TextButton.icon(
                            onPressed: _clear,
                            icon: const Icon(Icons.clear),
                            label: const Text('Limpar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_results.isNotEmpty) ...[
              _HashSummaryCard(
                characterCount: _characterCount,
                byteCount: _byteCount,
                algorithmCount: _results.length,
              ),
              const SizedBox(height: 8),
              ..._results.map(
                (result) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _HashResultTile(
                    result: result,
                    onCopy: () => _copy(result),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HashSummaryCard extends StatelessWidget {
  final int characterCount;
  final int byteCount;
  final int algorithmCount;

  const _HashSummaryCard({
    required this.characterCount,
    required this.byteCount,
    required this.algorithmCount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetricChip(label: 'Caracteres', value: '$characterCount'),
                _MetricChip(label: 'Bytes UTF-8', value: '$byteCount'),
                _MetricChip(label: 'Algoritmos', value: '$algorithmCount'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;

  const _MetricChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.28)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.72),
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
      ),
    );
  }
}

class _HashResultTile extends StatelessWidget {
  final HashResult result;
  final VoidCallback onCopy;

  const _HashResultTile({required this.result, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    result.algorithm,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onCopy,
                  tooltip: 'Copiar ${result.algorithm}',
                  icon: const Icon(Icons.copy),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetaLabel(text: '${result.bits} bits'),
                _MetaLabel(text: result.strength),
                _MetaLabel(text: '${result.value.length} hex'),
              ],
            ),
            const SizedBox(height: 12),
            SelectableText(
              result.value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontFamily: 'monospace',
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaLabel extends StatelessWidget {
  final String text;

  const _MetaLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.82),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
