import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class PriorityAlertOverlayWidget extends StatefulWidget {
  final VoidCallback onDismiss;

  const PriorityAlertOverlayWidget({
    Key? key,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<PriorityAlertOverlayWidget> createState() =>
      _PriorityAlertOverlayWidgetState();
}

class _PriorityAlertOverlayWidgetState extends State<PriorityAlertOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFFFF6B35).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Color(0xFFFF6B35).withValues(alpha: _glowAnimation.value),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFFF6B35)
                    .withValues(alpha: _glowAnimation.value * 0.5),
                blurRadius: 16,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Color(0xFFFF6B35),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'warning',
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Véhicule Prioritaire',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Color(0xFFFF6B35),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Véhicule d\'urgence détecté à proximité. Soyez prudent.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  widget.onDismiss();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
