class NetworkCalculator {
  String ipAddress;
  int? cidr;
  String? subnetMask;

  NetworkCalculator({required this.ipAddress, this.cidr, this.subnetMask}) {
    if (cidr == null && subnetMask == null) {
      throw ArgumentError('É necessário fornecer CIDR ou Máscara de Sub-rede.');
    }

    cidr ??= _maskToCidr(subnetMask!);
    subnetMask ??= _cidrToMask(cidr!);
  }

  String _cidrToMask(int cidr) {
    var mask = List.filled(4, 0);
    for (int i = 0; i < cidr; i++) {
      mask[i ~/ 8] += (1 << (7 - (i % 8)));
    }
    return mask.join('.');
  }

  int _maskToCidr(String mask) {
    return mask
            .split('.')
            .map(int.parse)
            .map((octet) => octet.toRadixString(2).padLeft(8, '0'))
            .join()
            .split('1')
            .length -
        1;
  }

  String calculateNetworkAddress() {
    var ip = ipAddress.split('.').map(int.parse).toList();
    var mask = subnetMask!.split('.').map(int.parse).toList();
    var networkAddress = List.generate(4, (i) => ip[i] & mask[i]);
    return networkAddress.join('.');
  }

  String calculateBroadcastAddress() {
    var ip = ipAddress.split('.').map(int.parse).toList();
    var mask = subnetMask!.split('.').map(int.parse).toList();
    var broadcastAddress = List.generate(4, (i) => ip[i] | (~mask[i] & 0xFF));
    return broadcastAddress.join('.');
  }

  String calculateIpRange(String networkAddress, String broadcastAddress) {
    final network = _ipToInt(networkAddress);
    final broadcast = _ipToInt(broadcastAddress);

    if (cidr == 32) {
      return networkAddress;
    }

    if (cidr == 31) {
      return '$networkAddress - $broadcastAddress';
    }

    return '${_intToIp(network + 1)} - ${_intToIp(broadcast - 1)}';
  }

  int calculateUsableHostCount() {
    if (cidr == 32) {
      return 1;
    }

    if (cidr == 31) {
      return 2;
    }

    return (1 << (32 - cidr!)) - 2;
  }

  int _ipToInt(String ip) {
    return ip.split('.').map(int.parse).fold(0, (value, octet) {
      return (value << 8) + octet;
    });
  }

  String _intToIp(int value) {
    return [
      (value >> 24) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 8) & 0xFF,
      value & 0xFF,
    ].join('.');
  }
}
