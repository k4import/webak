import 'package:flutter/material.dart';
import 'package:webak/core/theme/app_theme.dart';
import 'package:webak/core/theme/app_colors.dart';
import 'package:webak/core/theme/app_icons.dart';
import 'package:webak/core/theme/app_animations.dart';
import 'package:webak/core/utils/app_utils.dart';
import 'package:webak/features/tasks/domain/models/task_model.dart';
import 'package:intl/intl.dart';

/// بطاقة مهمة محسنة مع تصميم حديث ورسوم متحركة
class EnhancedTaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;
  final int? animationIndex;

  EnhancedTaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
    this.animationIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget card = Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppTheme.lg,
        vertical: AppTheme.sm,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: AppTheme.elevation,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: _getStatusColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          child: Padding(
            padding: EdgeInsets.all(AppTheme.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme),
                SizedBox(height: AppTheme.md),
                _buildTitle(theme),
                if (task.description.isNotEmpty) ...[
                  SizedBox(height: AppTheme.sm),
                  _buildDescription(theme),
                ],
                SizedBox(height: AppTheme.lg),
                _buildMetadata(theme),
                if (task.tags != null && task.tags!.isNotEmpty) ...[
                  SizedBox(height: AppTheme.md),
                  _buildTags(theme),
                ],
                if (showActions) ...[
                  SizedBox(height: AppTheme.lg),
                  _buildActions(theme),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    // إضافة الرسم المتحرك إذا تم تحديد الفهرس
    if (animationIndex != null) {
      card = AppAnimations.listItemAnimation(
        index: animationIndex!,
        child: card,
      );
    }

    return card;
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        // أيقونة الحالة
        Container(
          padding: EdgeInsets.all(AppTheme.sm),
          decoration: BoxDecoration(
            color: _getStatusColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          ),
          child: Icon(
            AppUtils.getStatusIcon(task.status),
            color: _getStatusColor(),
            size: 20,
          ),
        ),
        SizedBox(width: AppTheme.md),
        // معلومات الحالة والأولوية
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getStatusText(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _getStatusColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppTheme.xxs),
              Row(
                children: [
                  Icon(
                    AppUtils.getPriorityIcon(task.priority),
                    color: _getPriorityColor(),
                    size: 16,
                  ),
                  SizedBox(width: AppTheme.xs),
                  Text(
                    _getPriorityText(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getPriorityColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // تاريخ الإنشاء
        if (task.createdAt != null)
          Text(
            DateFormat('dd/MM').format(task.createdAt!),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
            ),
          ),
      ],
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Text(
      task.title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return Text(
      task.description,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMetadata(ThemeData theme) {
    return Row(
      children: [
        // الموقع
        if (task.location != null && task.location!.isNotEmpty) ...[
          Icon(
            AppIcons.location,
            size: 16,
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
          ),
          SizedBox(width: AppTheme.xs),
          Expanded(
            child: Text(
              task.location!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        // تاريخ الاستحقاق
        if (task.dueDate != null) ...[
          if (task.location != null && task.location!.isNotEmpty)
            SizedBox(width: AppTheme.md),
          Icon(
            AppIcons.calendar,
            size: 16,
            color: _getDueDateColor(theme),
          ),
          SizedBox(width: AppTheme.xs),
          Text(
            DateFormat('dd/MM/yyyy').format(task.dueDate!),
            style: theme.textTheme.bodySmall?.copyWith(
              color: _getDueDateColor(theme),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTags(ThemeData theme) {
    return Wrap(
      spacing: AppTheme.sm,
      runSpacing: AppTheme.xs,
      children: task.tags!.take(3).map((tag) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.md,
            vertical: AppTheme.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            border: Border.all(
              color: AppColors.primaryGreen.withOpacity(0.2),
            ),
          ),
          child: Text(
            tag,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// تحديث الأزرار
  Widget _buildActions(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (onTap != null)
          IconButton(
            onPressed: onTap,
            icon: Icon(AppIcons.editTask),
            iconSize: 20,
            color: AppColors.info,
            tooltip: 'عرض التفاصيل',
          ),
        if (onEdit != null)
          IconButton(
            onPressed: onEdit,
            icon: Icon(AppIcons.editTask),
            iconSize: 20,
            color: AppColors.info,
            tooltip: 'تعديل',
          ),
        if (onDelete != null)
          IconButton(
            onPressed: onDelete,
            icon: Icon(AppIcons.deleteTask),
            iconSize: 20,
            color: AppColors.error,
            tooltip: 'حذف',
          ),
      ],
    );
  }

  Color _getStatusColor() {
    return AppUtils.getStatusColor(task.status);
  }

  Color _getPriorityColor() {
    return AppUtils.getPriorityColor(task.priority);
  }

  Color _getDueDateColor(ThemeData theme) {
    if (task.dueDate == null) return theme.textTheme.bodySmall?.color ?? Colors.grey;

    final now = DateTime.now();
    final dueDate = task.dueDate!;
    final difference = dueDate.difference(now).inDays;

    if (difference < 0) {
      return AppColors.error; // متأخر
    } else if (difference <= 1) {
      return AppColors.warning; // مستحق قريباً
    } else {
      return theme.textTheme.bodySmall?.color?.withOpacity(0.8) ?? Colors.grey;
    }
  }

  String _getStatusText() {
    switch (task.status) {
      case 'pending':
        return 'معلقة';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'completed':
        return 'مكتملة';
      default:
        return task.status;
    }
  }

  String _getPriorityText() {
    switch (task.priority) {
      case 'high':
        return 'عالية';
      case 'medium':
        return 'متوسطة';
      case 'low':
        return 'منخفضة';
      default:
        return task.priority;
    }
  }
}
