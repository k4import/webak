import 'package:flutter/material.dart';
import 'package:webak/core/theme/app_theme.dart';

class AppCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? borderColor;
  final List<Widget>? actions;
  final Widget? content;

  const AppCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.borderColor,
    this.actions,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.sm),
        side: borderColor != null
            ? BorderSide(color: borderColor!, width: 2)
            : BorderSide.none,
      ),
      margin: const EdgeInsets.all(AppTheme.xs),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            ListTile(
              leading: leading,
              title: Text(
                title,
                style: AppTheme.h3,
              ),
              subtitle: subtitle != null
                  ? Text(
                      subtitle!,
                      style: AppTheme.body2,
                    )
                  : null,
              trailing: trailing,
            ),
            // Content
            if (content != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.md,
                  vertical: AppTheme.xs,
                ),
                child: content!,
              ),
            // Actions
            if (actions != null && actions!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(AppTheme.xs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}