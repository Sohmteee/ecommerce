import 'dart:ui' as ui;
import 'package:ecommerce/core/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A premium UI component that provides a frosted glass (glassmorphism) effect.
///
/// It supports blurring, adjustable opacity, sheen effects, and falls back to 
/// a solid background if liquid glass is disabled in [SettingsState].
class GlassContainer extends ConsumerWidget {
  /// The widget to be displayed inside the container.
  final Widget child;

  /// The amount of Gaussian blur applied to the background.
  final double blur;

  /// The opacity of the background color.
  final double opacity;

  /// The border radius of the container. Defaults to 24.
  final BorderRadius? borderRadius;

  /// Inner padding for the content.
  final EdgeInsetsGeometry? padding;

  /// Custom border for the container.
  final BoxBorder? border;

  /// Base color for the glass effect. Defaults to theme-based black/white.
  final Color? color;

  /// Width of the container.
  final double? width;

  /// Height of the container.
  final double? height;

  /// Shadows applied to the container.
  final List<BoxShadow>? boxShadow;

  /// Shape of the container.
  final BoxShape shape;

  /// Whether to show a subtle diagonal sheen effect.
  final bool showSheen;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 20,
    this.opacity = 0.1,
    this.borderRadius,
    this.padding,
    this.border,
    this.color,
    this.width,
    this.height,
    this.boxShadow,
    this.shape = BoxShape.rectangle,
    this.showSheen = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(24.0);
    
    final liquidGlassEnabled = ref.watch(settingsProvider).liquidGlassEnabled;

    // Dynamic values based on theme if not provided
    final backgroundColor = (color ?? (isDark ? Colors.black : Colors.white))
        .withOpacity(opacity);

    final borderColor = (isDark
        ? Colors.white.withOpacity(0.12)
        : Colors.white.withOpacity(0.25));

    final fallbackColor = color ?? (isDark ? Colors.grey.shade900 : Colors.grey.shade200);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: shape,
        boxShadow: boxShadow,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background layer
          Positioned.fill(
            child: ClipRRect(
              borderRadius: shape == BoxShape.circle
                  ? BorderRadius.zero
                  : effectiveBorderRadius,
              clipBehavior: shape == BoxShape.circle ? Clip.none : Clip.antiAlias,
              child: shape == BoxShape.circle
                  ? ClipOval(
                      child: _buildAnimatedBackground(liquidGlassEnabled, blur, backgroundColor, fallbackColor, borderColor, effectiveBorderRadius),
                    )
                  : _buildAnimatedBackground(liquidGlassEnabled, blur, backgroundColor, fallbackColor, borderColor, effectiveBorderRadius),
            ),
          ),
          // Content layer
          _buildContent(isDark, effectiveBorderRadius, liquidGlassEnabled),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(bool liquidGlassEnabled, double blur, Color backgroundColor, Color fallbackColor, Color borderColor, BorderRadius effectiveBorderRadius) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: liquidGlassEnabled
          ? SizedBox.expand(
              key: const ValueKey('glass_bg'),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: Container(
                  decoration: BoxDecoration(
                    shape: shape,
                    borderRadius: shape == BoxShape.circle ? null : effectiveBorderRadius,
                    color: backgroundColor,
                    border: border ?? Border.all(color: borderColor, width: 0.5),
                  ),
                ),
              ),
            )
          : SizedBox.expand(
              key: const ValueKey('solid_bg'),
              child: Container(
                decoration: BoxDecoration(
                  shape: shape,
                  borderRadius: shape == BoxShape.circle ? null : effectiveBorderRadius,
                  color: fallbackColor,
                  border: border ?? Border.all(color: borderColor, width: 0.5),
                ),
              ),
            ),
    );
  }

  Widget _buildContent(bool isDark, BorderRadius effectiveBorderRadius, bool liquidGlassEnabled) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Sheen Effect
        if (showSheen && liquidGlassEnabled)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: shape,
                borderRadius: shape == BoxShape.circle
                    ? null
                    : effectiveBorderRadius,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(isDark ? 0.05 : 0.1),
                    Colors.transparent,
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
        // Child widget
        if (padding != null)
          Padding(padding: padding!, child: child)
        else
          child,
      ],
    );
  }
}
