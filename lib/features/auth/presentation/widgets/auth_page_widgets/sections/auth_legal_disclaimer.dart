import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:wsidappp/config/environment_config/legal_urls.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/core/services/external_link_launcher.dart';

/// "By continuing, you agree to…" line with tappable Terms and Privacy links.
class AuthLegalDisclaimer extends StatefulWidget {
  const AuthLegalDisclaimer({super.key});

  @override
  State<AuthLegalDisclaimer> createState() => _AuthLegalDisclaimerState();
}

class _AuthLegalDisclaimerState extends State<AuthLegalDisclaimer> {
  late final TapGestureRecognizer _termsRecognizer = TapGestureRecognizer()
    ..onTap = () => _open(LegalUrls.termsOfService);
  late final TapGestureRecognizer _privacyRecognizer = TapGestureRecognizer()
    ..onTap = () => _open(LegalUrls.privacyPolicy);

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  Future<void> _open(String url) async {
    final messenger = ScaffoldMessenger.of(context);
    final errorText = context.l10n.couldNotOpenLink;
    final errorColor = context.colors.error;
    if (!await openExternalLink(url)) {
      messenger.showSnackBar(
        SnackBar(content: Text(errorText), backgroundColor: errorColor),
      );
    }
  }

  List<InlineSpan> _buildSpans(BuildContext context) {
    final l10n = context.l10n;
    final String sentence = l10n.authLegalDisclaimer;
    final TextStyle linkStyle = TextStyle(
      color: context.colors.primary,
      fontWeight: context.txt.labelLarge?.fontWeight,
      decoration: TextDecoration.underline,
      decorationColor: context.colors.primary,
    );

    final List<({int start, String label, TapGestureRecognizer recognizer})>
        links = <({int start, String label, TapGestureRecognizer recognizer})>[
      (
        start: sentence.indexOf(l10n.termsOfService),
        label: l10n.termsOfService,
        recognizer: _termsRecognizer,
      ),
      (
        start: sentence.indexOf(l10n.privacyPolicy),
        label: l10n.privacyPolicy,
        recognizer: _privacyRecognizer,
      ),
    ]..sort((a, b) => a.start.compareTo(b.start));

    final List<InlineSpan> spans = <InlineSpan>[];
    int cursor = 0;
    for (final link in links) {
      if (link.start < cursor) continue;
      spans.add(TextSpan(text: sentence.substring(cursor, link.start)));
      spans.add(
        TextSpan(
          text: link.label,
          style: linkStyle,
          recognizer: link.recognizer,
        ),
      );
      cursor = link.start + link.label.length;
    }
    spans.add(TextSpan(text: sentence.substring(cursor)));
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(children: _buildSpans(context)),
      textAlign: TextAlign.center,
      style: context.txt.bodySmall?.copyWith(
        color: context.colors.onSurfaceVariant,
      ),
    );
  }
}
