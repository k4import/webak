import 'package:flutter/material.dart';
import 'package:webak/core/theme/app_theme.dart';
import 'package:webak/core/utils/app_utils.dart';

class AppStatusBadge extends StatelessWidget {
  final String status;
  final bool small;

  const AppStatusBadge({
    super.key,
    required this.status,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = AppUtils.getStatusColor(status);
    final double fontSize = small ? 10.0 : 12.0;
    final EdgeInsets padding = small
        ? const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0)
        : const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppTheme.xs),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}