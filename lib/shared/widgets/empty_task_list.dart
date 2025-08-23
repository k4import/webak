import 'package:flutter/material.dart';
import 'package:webak/core/theme/app_theme.dart';
import 'package:webak/shared/widgets/app_button.dart';

class EmptyTaskList extends StatelessWidget {
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyTaskList({
    super.key,
    this.message = 'لا توجد مهام حالياً',
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 80,
              color: AppTheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppTheme.md),
            Text(
              message,
              style: AppTheme.h3.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null) ...[  
              const SizedBox(height: AppTheme.lg),
              AppButton(
                text: buttonText!,
                onPressed: onButtonPressed!,
                icon: Icons.add,
              ),
            ],
          ],
        ),
      ),
    );
  }
}