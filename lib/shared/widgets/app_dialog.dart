import 'package:flutter/material.dart';
import 'package:webak/core/theme/app_theme.dart';
import 'package:webak/shared/widgets/app_button.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Widget? content;

  const AppDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: AppTheme.h2,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: AppTheme.body1,
          ),
          if (content != null) const SizedBox(height: AppTheme.md),
          if (content != null) content!,
        ],
      ),
      actions: [
        if (cancelText != null)
          AppButton(
            text: cancelText!,
            onPressed: onCancel ?? () => Navigator.of(context).pop(false),
            type: ButtonType.secondary,
          ),
        if (confirmText != null)
          AppButton(
            text: confirmText!,
            onPressed: onConfirm ?? () => Navigator.of(context).pop(true),
            type: ButtonType.primary,
          ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.sm),
      ),
      contentPadding: const EdgeInsets.all(AppTheme.md),
      actionsPadding: const EdgeInsets.all(AppTheme.md),
    );
  }

  // Helper method to show dialog
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Widget? content,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        content: content,
      ),
    );
  }
}