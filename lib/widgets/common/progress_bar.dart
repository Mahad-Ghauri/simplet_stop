import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class ProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final BorderRadius? borderRadius;
  final String? label;
  final bool showPercentage;
  final TextStyle? labelStyle;

  const ProgressBar({
    super.key,
    required this.progress,
    this.height = 8.0,
    this.backgroundColor,
    this.progressColor,
    this.borderRadius,
    this.label,
    this.showPercentage = false,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null || showPercentage) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (label != null)
                Text(label!, style: labelStyle ?? AppTheme.bodySmall),
              if (showPercentage)
                Text(
                  '${(clampedProgress * 100).toInt()}%',
                  style:
                      labelStyle ??
                      AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600),
                ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        Container(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.grey.shade300,
            borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
          ),
          child: ClipRRect(
            borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
            child: LinearProgressIndicator(
              value: clampedProgress,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                progressColor ?? AppTheme.primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CircularProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? progressColor;
  final Widget? child;
  final bool showPercentage;
  final TextStyle? textStyle;

  const CircularProgressBar({
    super.key,
    required this.progress,
    this.size = 100.0,
    this.strokeWidth = 8.0,
    this.backgroundColor,
    this.progressColor,
    this.child,
    this.showPercentage = false,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: clampedProgress,
            strokeWidth: strokeWidth,
            backgroundColor: backgroundColor ?? Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              progressColor ?? AppTheme.primaryColor,
            ),
          ),
          if (child != null)
            child!
          else if (showPercentage)
            Text(
              '${(clampedProgress * 100).toInt()}%',
              style:
                  textStyle ??
                  AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }
}

class AnimatedProgressBar extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final BorderRadius? borderRadius;
  final String? label;
  final bool showPercentage;
  final TextStyle? labelStyle;
  final Duration animationDuration;
  final Curve animationCurve;

  const AnimatedProgressBar({
    super.key,
    required this.progress,
    this.height = 8.0,
    this.backgroundColor,
    this.progressColor,
    this.borderRadius,
    this.label,
    this.showPercentage = false,
    this.labelStyle,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeInOut,
  });

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: widget.progress.clamp(0.0, 1.0))
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: widget.animationCurve,
          ),
        );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation =
          Tween<double>(
            begin: _animation.value,
            end: widget.progress.clamp(0.0, 1.0),
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: widget.animationCurve,
            ),
          );
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ProgressBar(
          progress: _animation.value,
          height: widget.height,
          backgroundColor: widget.backgroundColor,
          progressColor: widget.progressColor,
          borderRadius: widget.borderRadius,
          label: widget.label,
          showPercentage: widget.showPercentage,
          labelStyle: widget.labelStyle,
        );
      },
    );
  }
}

class MultiProgressBar extends StatelessWidget {
  final List<ProgressSegment> segments;
  final double height;
  final BorderRadius? borderRadius;
  final String? label;
  final bool showPercentage;
  final TextStyle? labelStyle;

  const MultiProgressBar({
    super.key,
    required this.segments,
    this.height = 8.0,
    this.borderRadius,
    this.label,
    this.showPercentage = false,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final totalProgress = segments
        .fold<double>(0.0, (sum, segment) => sum + segment.value)
        .clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null || showPercentage) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (label != null)
                Text(label!, style: labelStyle ?? AppTheme.bodySmall),
              if (showPercentage)
                Text(
                  '${(totalProgress * 100).toInt()}%',
                  style:
                      labelStyle ??
                      AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600),
                ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
          ),
          child: ClipRRect(
            borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
            child: Row(
              children: segments.map((segment) {
                return Expanded(
                  flex: (segment.value * 100).toInt(),
                  child: Container(color: segment.color),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class ProgressSegment {
  final double value; // 0.0 to 1.0
  final Color color;
  final String? label;

  const ProgressSegment({required this.value, required this.color, this.label});
}

class StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final double height;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? completedColor;
  final BorderRadius? borderRadius;

  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.height = 8.0,
    this.activeColor,
    this.inactiveColor,
    this.completedColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        Color color;
        if (index < currentStep) {
          color = completedColor ?? AppTheme.successColor;
        } else if (index == currentStep) {
          color = activeColor ?? AppTheme.primaryColor;
        } else {
          color = inactiveColor ?? Colors.grey.shade300;
        }

        return Expanded(
          child: Container(
            height: height,
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 4 : 0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
            ),
          ),
        );
      }),
    );
  }
}
