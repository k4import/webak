import 'package:flutter/material.dart';
import 'package:webak/core/theme/app_theme.dart';
import 'package:webak/core/utils/app_utils.dart';
import 'package:webak/features/tasks/domain/enums/task_priorities.dart';

class AppPriorityBadge extends StatelessWidget {
  final String priority;
  
  TaskPriorities get priorityEnum {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return TaskPriorities.urgent;
      case 'high':
        return TaskPriorities.high;
      case 'medium':
        return TaskPriorities.medium;
      case 'low':
        return TaskPriorities.low;
      default:
        return TaskPriorities.medium;
    }
  }
  final bool small;

  const AppPriorityBadge({
    super.key,
    required this.priority,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = AppUtils.getPriorityColor(priorityEnum);
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getPriorityIcon(),
            color: color,
            size: fontSize + 2,
          ),
          const SizedBox(width: 4),
          Text(
            priority,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPriorityIcon() {
    switch (priorityEnum) {
      case TaskPriorities.urgent:
        return Icons.priority_high;
      case TaskPriorities.high:
        return Icons.arrow_upward;
      case TaskPriorities.medium:
        return Icons.remove;
      case TaskPriorities.low:
        return Icons.arrow_downward;
    }
  }
}