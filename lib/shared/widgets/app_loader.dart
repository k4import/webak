import 'package:flutter/material.dart';
import 'package:webak/core/theme/app_theme.dart';

class AppLoader extends StatelessWidget {
  final String? message;
  final bool overlay;

  const AppLoader({
    super.key,
    this.message,
    this.overlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget loader = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
          if (message != null) ...[  
            const SizedBox(height: AppTheme.md),
            Text(
              message!,
              style: AppTheme.body1,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );

    if (overlay) {
      return Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: loader,
      );
    }

    return loader;
  }

  // Helper method to show loading dialog
  static Future<void> show(BuildContext context, {String? message}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AppLoader(
        message: message,
        overlay: true,
      ),
    );
  }

  // Helper method to hide loading dialog
  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}