/// Public URLs of the hosted legal pages (`web/privacy.html`, `web/terms.html`).
///
/// Update both if the production Vercel domain changes. App Store, Google Play
/// and Supabase OAuth require these to be live URLs.
abstract final class LegalUrls {
  static const String privacyPolicy = 'https://wsidapp.vercel.app/privacy.html';

  static const String termsOfService = 'https://wsidapp.vercel.app/terms.html';
}
