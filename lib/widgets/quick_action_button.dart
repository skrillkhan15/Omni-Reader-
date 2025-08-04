import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuickActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool isEnabled;
  final double? width;
  final double? height;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
    this.isEnabled = true,
    this.width,
    this.height,
  });

  @override
  State<QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<QuickActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.isEnabled) return;
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.isEnabled) return;
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  void _onTapCancel() {
    if (!widget.isEnabled) return;
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.isEnabled ? widget.onTap : null,
            child: Container(
              width: widget.width,
              height: widget.height ?? 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.isEnabled
                      ? [
                          widget.color.withOpacity(0.1),
                          widget.color.withOpacity(0.05),
                        ]
                      : [
                          colorScheme.surfaceVariant,
                          colorScheme.surfaceVariant,
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isEnabled
                      ? widget.color.withOpacity(0.2)
                      : colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: _isPressed
                    ? []
                    : [
                        BoxShadow(
                          color: widget.isEnabled
                              ? widget.color.withOpacity(0.1)
                              : Colors.transparent,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.isEnabled
                          ? widget.color.withOpacity(0.2)
                          : colorScheme.outline.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 24,
                      color: widget.isEnabled
                          ? widget.color
                          : colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: widget.isEnabled
                          ? colorScheme.onSurface
                          : colorScheme.outline,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Large quick action button for prominent actions
class LargeQuickActionButton extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;
  final bool isEnabled;

  const LargeQuickActionButton({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
    this.isEnabled = true,
  });

  @override
  State<LargeQuickActionButton> createState() => _LargeQuickActionButtonState();
}

class _LargeQuickActionButtonState extends State<LargeQuickActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.isEnabled) return;
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.isEnabled) return;
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  void _onTapCancel() {
    if (!widget.isEnabled) return;
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.isEnabled ? widget.onTap : null,
            child: Card(
              elevation: _isPressed ? 2 : 4,
              shadowColor: widget.isEnabled
                  ? widget.color.withOpacity(0.3)
                  : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.isEnabled
                        ? [
                            widget.color.withOpacity(0.1),
                            widget.color.withOpacity(0.05),
                            colorScheme.surface,
                          ]
                        : [
                            colorScheme.surfaceVariant,
                            colorScheme.surfaceVariant,
                            colorScheme.surfaceVariant,
                          ],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: widget.isEnabled
                            ? widget.color.withOpacity(0.2)
                            : colorScheme.outline.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        widget.icon,
                        size: 32,
                        color: widget.isEnabled
                            ? widget.color
                            : colorScheme.outline,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: widget.isEnabled
                                  ? colorScheme.onSurface
                                  : colorScheme.outline,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: widget.isEnabled
                                  ? colorScheme.onSurface.withOpacity(0.7)
                                  : colorScheme.outline.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: widget.isEnabled
                          ? widget.color
                          : colorScheme.outline,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Floating quick action button
class FloatingQuickActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool isEnabled;

  const FloatingQuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
    this.isEnabled = true,
  });

  @override
  State<FloatingQuickActionButton> createState() =>
      _FloatingQuickActionButtonState();
}

class _FloatingQuickActionButtonState extends State<FloatingQuickActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTap() {
    if (!widget.isEnabled) return;
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    HapticFeedback.mediumImpact();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: FloatingActionButton.extended(
              onPressed: widget.isEnabled ? _onTap : null,
              backgroundColor: widget.isEnabled
                  ? widget.color
                  : theme.colorScheme.surfaceVariant,
              foregroundColor: widget.isEnabled
                  ? Colors.white
                  : theme.colorScheme.outline,
              elevation: widget.isEnabled ? 6 : 2,
              icon: Icon(widget.icon),
              label: Text(
                widget.label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Quick action grid
class QuickActionGrid extends StatelessWidget {
  final List<QuickActionButton> actions;
  final int crossAxisCount;
  final double childAspectRatio;
  final EdgeInsets padding;

  const QuickActionGrid({
    super.key,
    required this.actions,
    this.crossAxisCount = 4,
    this.childAspectRatio = 1.0,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          return actions[index];
        },
      ),
    );
  }
}

