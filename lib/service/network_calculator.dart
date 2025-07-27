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
    List<int> startIp = networkAddress.split('.').map(int.parse).toList();
    List<int> endIp = broadcastAddress.split('.').map(int.parse).toList();
    endIp[3] -= 1; // Último IP válido antes do broadcast

    String startIpStr = startIp.join('.');
    String endIpStr = endIp.join('.');
    return '$startIpStr - $endIpStr';
  }
}
