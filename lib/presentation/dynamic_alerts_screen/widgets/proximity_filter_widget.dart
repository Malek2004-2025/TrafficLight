import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Proximity filter chips for alert distance filtering
class ProximityFilterWidget extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onFilterChanged;

  const ProximityFilterWidget({
    Key? key,
    required this.selectedIndex,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filters = [
      {'label': '500m', 'value': 500},
      {'label': '1km', 'value': 1000},
      {'label': '2km', 'value': 2000},
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF2A2A2A).withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'my_location',
                size: 20,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 2.w),
              Text(
                'Rayon de proximité',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Row(
            children: List.generate(
              filters.length,
              (index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < filters.length - 1 ? 2.w : 0,
                  ),
                  child: _buildFilterChip(
                    context: context,
                    label: filters[index]['label'] as String,
                    isSelected: selectedIndex == index,
                    onTap: () => onFilterChanged(index),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.8),
                  ],
                )
              : null,
          color: isSelected ? null : Color(0xFF2A2A2A).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : Color(0xFF2A2A2A).withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              color: isSelected ? Colors.black : Color(0xFFB0BEC5),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
