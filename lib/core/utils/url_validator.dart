abstract final class UrlValidator {
  static bool isHttps(String value) {
    final Uri? uri = Uri.tryParse(value.trim());
    return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty;
  }
}
