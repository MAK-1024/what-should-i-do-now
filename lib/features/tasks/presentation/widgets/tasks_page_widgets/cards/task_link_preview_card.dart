import 'package:flutter/material.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/shared/widgets/brand_surface_card.dart';

class TaskLinkPreviewCard extends StatelessWidget {
  const TaskLinkPreviewCard({
    super.key,
    required this.url,
    required this.onTap,
  });

  final String url;
  final VoidCallback onTap;

  String get _title {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) return url;
    final String path = uri.path;
    if (path.isNotEmpty && path != '/') {
      final String segment = path.split('/').where((String s) => s.isNotEmpty).last;
      if (segment.isNotEmpty) return Uri.decodeComponent(segment);
    }
    return uri.host;
  }

  String get _domain {
    final Uri? uri = Uri.tryParse(url);
    return uri?.host.isNotEmpty == true ? uri!.host : url;
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return BrandSurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
      child: Row(
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: brand.linkThumbBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.link, color: brand.iconOnTint, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.isLightTheme
                      ? context.cardTitleStyle
                      : context.txt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colors.primary,
                        ),
                ),
                const SizedBox(height: 2),
                Text(
                  _domain,
                  style: context.isLightTheme
                      ? context.metaTextStyle
                      : context.txt.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: context.colors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}