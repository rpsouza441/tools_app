bool isValidIp(String ip) {
  final regex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
  return regex.hasMatch(ip) &&
      ip.split('.').map(int.parse).every((octet) => octet >= 0 && octet <= 255);
}

bool isValidCidr(String cidr) {
  final value = int.tryParse(cidr);
  return value != null && value >= 0 && value <= 32;
}

bool isValidSubnetMask(String mask) {
  final validMasks = [
    "255.0.0.0",
    "255.128.0.0",
    "255.192.0.0",
    "255.224.0.0",
    "255.240.0.0",
    "255.248.0.0",
    "255.252.0.0",
    "255.254.0.0",
    "255.255.0.0",
    "255.255.128.0",
    "255.255.192.0",
    "255.255.224.0",
    "255.255.240.0",
    "255.255.248.0",
    "255.255.252.0",
    "255.255.254.0",
    "255.255.255.0",
    "255.255.255.128",
    "255.255.255.192",
    "255.255.255.224",
    "255.255.255.240",
    "255.255.255.248",
    "255.255.255.252",
    "255.255.255.254",
    "255.255.255.255"
  ];
  return validMasks.contains(mask);
}
