import 'dart:convert';

import 'package:crypto/crypto.dart';

class HashResult {
  final String algorithm;
  final String value;
  final int bits;
  final String strength;

  const HashResult({
    required this.algorithm,
    required this.value,
    required this.bits,
    required this.strength,
  });
}

class HashCalculator {
  static const List<String> availableAlgorithms = [
    'MD5',
    'SHA-1',
    'SHA-256',
    'SHA-512',
  ];

  static List<HashResult> calculate(String input) {
    final bytes = utf8.encode(input);

    return [
      HashResult(
        algorithm: 'MD5',
        value: md5.convert(bytes).toString(),
        bits: 128,
        strength: 'legado',
      ),
      HashResult(
        algorithm: 'SHA-1',
        value: sha1.convert(bytes).toString(),
        bits: 160,
        strength: 'legado',
      ),
      HashResult(
        algorithm: 'SHA-256',
        value: sha256.convert(bytes).toString(),
        bits: 256,
        strength: 'integridade',
      ),
      HashResult(
        algorithm: 'SHA-512',
        value: sha512.convert(bytes).toString(),
        bits: 512,
        strength: 'integridade',
      ),
    ];
  }
}
