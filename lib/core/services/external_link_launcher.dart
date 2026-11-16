import 'package:url_launcher/url_launcher.dart';

/// Opens [url] in an external application. Returns `false` when the URL is
/// malformed or no application can handle it.
Future<bool> openExternalLink(String url) async {
  final String trimmed = url.trim();
  if (trimmed.isEmpty) return false;
  final Uri? uri = Uri.tryParse(
    trimmed.contains('://') ? trimmed : 'https://$trimmed',
  );
  if (uri == null) return false;
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } on Exception {
    return false;
  }
}
