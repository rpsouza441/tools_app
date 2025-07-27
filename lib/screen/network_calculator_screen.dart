import 'package:flutter/material.dart';
import 'package:tolls_app/service/network_calculator.dart';
import 'package:tolls_app/utils/network_utils.dart'; // Importe o arquivo de utilitários

class NetworkCalculatorScreen extends StatefulWidget {
  const NetworkCalculatorScreen({super.key});

  @override
  State<NetworkCalculatorScreen> createState() =>
      _NetworkCalculatorScreenState();
}

class _NetworkCalculatorScreenState extends State<NetworkCalculatorScreen> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _maskOrCidrController = TextEditingController();

  String _result = '';
  String? _ipError;
  String? _maskOrCidrError;

  void _calculate() {
    String ip = _ipController.text.trim();
    String maskOrCidr = _maskOrCidrController.text.trim();

    setState(() {
      _ipError = null;
      _maskOrCidrError = null;

      if (!isValidIp(ip)) {
        _ipError = 'Formato de IP inválido (ex: 192.168.1.1).';
        _result = ''; // Limpa o resultado em caso de erro
        return;
      }

      if (maskOrCidr.isEmpty) {
        _maskOrCidrError = 'Insira uma máscara de sub-rede ou um CIDR.';
        _result = ''; // Limpa o resultado em caso de erro
        return;
      }

      try {
        NetworkCalculator calculator;
        if (maskOrCidr.contains('.')) {
          if (!isValidIp(maskOrCidr) || !isValidSubnetMask(maskOrCidr)) {
            _maskOrCidrError = 'Máscara de sub-rede inválida.';
            _result = ''; // Limpa o resultado em caso de erro
            return;
          }
          calculator = NetworkCalculator(ipAddress: ip, subnetMask: maskOrCidr);
        } else {
          if (!isValidCidr(maskOrCidr)) {
            _maskOrCidrError = 'Valor de CIDR inválido (0-32).';
            _result = ''; // Limpa o resultado em caso de erro
            return;
          }
          int cidr = int.parse(maskOrCidr);
          calculator = NetworkCalculator(ipAddress: ip, cidr: cidr);
        }

        String networkAddress = calculator.calculateNetworkAddress();
        String broadcastAddress = calculator.calculateBroadcastAddress();
        String ipRange =
            calculator.calculateIpRange(networkAddress, broadcastAddress);

        _result = 'Endereço de Rede: $networkAddress\n'
            'Faixa de IPs: $ipRange\n'
            'Endereço de Broadcast: $broadcastAddress\n'
            'Máscara de Sub-rede: ${calculator.subnetMask}\n'
            'CIDR: /${calculator.cidr}';
      } on FormatException {
        _result =
            'Erro: Formato de entrada inválido. Verifique os valores inseridos.';
      } catch (e) {
        _result = 'Erro inesperado: ${e.toString()}';
      }
    });
  }

  void _clearFields() {
    setState(() {
      _ipController.clear();
      _maskOrCidrController.clear();
      _result = '';
      _ipError = null;
      _maskOrCidrError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Calculator'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (isWideScreen)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Inputs ocupando 70% da largura
                        Expanded(
                          flex: 7,
                          child: Column(
                            children: [
                              TextField(
                                controller: _ipController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Endereço de IP',
                                  border: const OutlineInputBorder(),
                                  errorText: _ipError,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _maskOrCidrController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Máscara de Sub-Rede ou CIDR',
                                  border: const OutlineInputBorder(),
                                  errorText: _maskOrCidrError,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Botões ocupando 30% da largura
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _calculate,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(48),
                                  ),
                                  child: const Text('Calcular'),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: TextButton(
                                  onPressed: _clearFields,
                                  style: TextButton.styleFrom(
                                    minimumSize: const Size.fromHeight(48),
                                  ),
                                  child: const Text('Limpar'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  if (!isWideScreen)
                    Column(
                      children: [
                        TextField(
                          controller: _ipController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Endereço de IP',
                            border: const OutlineInputBorder(),
                            errorText: _ipError,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _maskOrCidrController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Máscara de Sub-Rede ou CIDR',
                            border: const OutlineInputBorder(),
                            errorText: _maskOrCidrError,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: constraints.maxWidth * 0.6,
                              child: ElevatedButton(
                                onPressed: _calculate,
                                child: const Text('Calcular'),
                              ),
                            ),
                            Expanded(
                              child: TextButton(
                                onPressed: _clearFields,
                                child: const Text('Limpar'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  if (_result.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _result,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
