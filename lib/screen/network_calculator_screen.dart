import 'package:flutter/material.dart';
import 'package:tools_app/design_system/copy_value_action.dart';
import 'package:tools_app/design_system/tool_scaffold.dart';
import 'package:tools_app/design_system/tool_sections.dart';
import 'package:tools_app/service/network_calculator.dart';
import 'package:tools_app/utils/network_utils.dart';

class NetworkCalculatorScreen extends StatefulWidget {
  const NetworkCalculatorScreen({super.key, this.copyWriter});

  final CopyValueWriter? copyWriter;

  @override
  State<NetworkCalculatorScreen> createState() =>
      _NetworkCalculatorScreenState();
}

class _NetworkCalculatorScreenState extends State<NetworkCalculatorScreen> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _maskOrCidrController = TextEditingController();

  String? _ipError;
  String? _maskOrCidrError;
  String? _errorMessage;
  String? _networkAddress;
  String? _ipRange;
  String? _broadcastAddress;
  String? _subnetMask;
  String? _cidrLabel;
  String? _usableHosts;

  CopyValueWriter get _copyWriter =>
      widget.copyWriter ?? const ClipboardCopyWriter();

  void _clearComputedResults() {
    _networkAddress = null;
    _ipRange = null;
    _broadcastAddress = null;
    _subnetMask = null;
    _cidrLabel = null;
    _usableHosts = null;
    _errorMessage = null;
  }

  void _calculate() {
    String ip = _ipController.text.trim();
    String maskOrCidr = _maskOrCidrController.text.trim();

    setState(() {
      _ipError = null;
      _maskOrCidrError = null;

      if (!isValidIp(ip)) {
        _ipError = 'Formato de IP inválido (ex: 192.168.1.1).';
        _clearComputedResults(); // Limpa o resultado em caso de erro
        return;
      }

      if (maskOrCidr.isEmpty) {
        _maskOrCidrError = 'Insira uma máscara de sub-rede ou um CIDR.';
        _clearComputedResults(); // Limpa o resultado em caso de erro
        return;
      }

      try {
        NetworkCalculator calculator;
        if (maskOrCidr.contains('.')) {
          if (!isValidIp(maskOrCidr) || !isValidSubnetMask(maskOrCidr)) {
            _maskOrCidrError = 'Máscara de sub-rede inválida.';
            _clearComputedResults(); // Limpa o resultado em caso de erro
            return;
          }
          calculator = NetworkCalculator(ipAddress: ip, subnetMask: maskOrCidr);
        } else {
          if (!isValidCidr(maskOrCidr)) {
            _maskOrCidrError = 'Valor de CIDR inválido (0-32).';
            _clearComputedResults(); // Limpa o resultado em caso de erro
            return;
          }
          int cidr = int.parse(maskOrCidr);
          calculator = NetworkCalculator(ipAddress: ip, cidr: cidr);
        }

        String networkAddress = calculator.calculateNetworkAddress();
        String broadcastAddress = calculator.calculateBroadcastAddress();
        String ipRange = calculator.calculateIpRange(
          networkAddress,
          broadcastAddress,
        );
        int usableHosts = calculator.calculateUsableHostCount();

        _errorMessage = null;
        _networkAddress = networkAddress;
        _ipRange = ipRange;
        _broadcastAddress = broadcastAddress;
        _subnetMask = calculator.subnetMask;
        _cidrLabel = '/${calculator.cidr}';
        _usableHosts = '$usableHosts';
      } on FormatException {
        _clearComputedResults();
        _errorMessage =
            'Erro: Formato de entrada inválido. Verifique os valores inseridos.';
      } catch (e) {
        _clearComputedResults();
        _errorMessage = 'Erro inesperado: ${e.toString()}';
      }
    });
  }

  void _clearFields() {
    setState(() {
      _ipController.clear();
      _maskOrCidrController.clear();
      _clearComputedResults();
      _ipError = null;
      _maskOrCidrError = null;
    });
  }

  @override
  void dispose() {
    _ipController.dispose();
    _maskOrCidrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ToolScaffold(
      title: 'Calculadora de Rede',
      children: [
        ToolInputSection(
          children: [
            TextField(
              controller: _ipController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'Endereço de IP',
                border: const OutlineInputBorder(),
                errorText: _ipError,
              ),
            ),
            TextField(
              controller: _maskOrCidrController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'Máscara de Sub-Rede ou CIDR',
                border: const OutlineInputBorder(),
                errorText: _maskOrCidrError,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ToolActionGroup(
          primary: ElevatedButton(
            onPressed: _calculate,
            child: const Text('Calcular rede'),
          ),
          secondary: TextButton(
            onPressed: _clearFields,
            child: const Text('Limpar'),
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          Text(_errorMessage!),
        ],
        if (_networkAddress != null) ...[
          const SizedBox(height: 24),
          ToolResultCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TechnicalValueRow(
                  label: 'Endereço de Rede',
                  value: _networkAddress!,
                  copyWriter: _copyWriter,
                ),
                TechnicalValueRow(
                  label: 'Faixa de IPs',
                  value: _ipRange!,
                  copyWriter: _copyWriter,
                ),
                TechnicalValueRow(
                  label: 'Endereço de Broadcast',
                  value: _broadcastAddress!,
                  copyWriter: _copyWriter,
                ),
                TechnicalValueRow(
                  label: 'Máscara de Sub-rede',
                  value: _subnetMask!,
                  copyWriter: _copyWriter,
                ),
                TechnicalValueRow(
                  label: 'CIDR',
                  value: _cidrLabel!,
                  copyWriter: _copyWriter,
                ),
                ToolMetric(label: 'Hosts utilizáveis', value: _usableHosts),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
