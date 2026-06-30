/// HTTPS-only URL guard for BYOK base URLs (no localhost / private IPs).
bool isByokBaseUrlAllowed(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return false;

  final uri = Uri.tryParse(trimmed);
  if (uri == null || !uri.hasScheme || !uri.hasAuthority) return false;
  if (uri.scheme.toLowerCase() != 'https') return false;

  final host = uri.host.toLowerCase();
  if (host == 'localhost' || host == '127.0.0.1' || host == '::1') {
    return false;
  }

  if (_isPrivateIpv4(host)) return false;

  return true;
}

bool _isPrivateIpv4(String host) {
  final parts = host.split('.');
  if (parts.length != 4) return false;

  final octets = <int>[];
  for (final part in parts) {
    final value = int.tryParse(part);
    if (value == null || value < 0 || value > 255) return false;
    octets.add(value);
  }

  if (octets[0] == 10) return true;
  if (octets[0] == 172 && octets[1] >= 16 && octets[1] <= 31) return true;
  if (octets[0] == 192 && octets[1] == 168) return true;

  return false;
}
