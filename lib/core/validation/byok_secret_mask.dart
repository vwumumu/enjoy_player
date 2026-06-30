/// Masks a BYOK secret for display (first 4 + bullets + last 4).
String maskByokApiKey(String key) {
  final trimmed = key.trim();
  if (trimmed.isEmpty) return '';
  if (trimmed.length <= 8) return '••••••••';
  final hidden = trimmed.length - 8;
  return '${trimmed.substring(0, 4)}${'•' * hidden}${trimmed.substring(trimmed.length - 4)}';
}
