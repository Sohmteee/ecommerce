import 'package:ecommerce/core/widgets/glass_container.dart';
import 'package:flutter/material.dart';

/// A glassmorphic button with optional icon and loading state.
class GlassButton extends StatelessWidget {
  /// The text label displayed on the button.
  final String label;

  /// Callback function when the button is pressed.
  final VoidCallback onPressed;

  /// Base color of the glass button.
  final Color? color;

  /// Optional icon displayed before the label.
  final IconData? icon;

  /// Whether to show a loading indicator instead of the label/icon.
  final bool isLoading;

  const GlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      opacity: 0.2,
      borderRadius: BorderRadius.circular(16),
      color: color ?? Colors.deepPurple,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 20, color: Colors.white),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// A glassmorphic text input field with a floating-style label.
class GlassTextField extends StatelessWidget {
  /// Controller for the text being edited.
  final TextEditingController controller;

  /// The label displayed above the text field.
  final String label;

  /// Optional icon displayed at the start of the text field.
  final IconData? prefixIcon;

  /// The type of information for which to optimize the text input control.
  final TextInputType keyboardType;

  /// Optional validator for the input value.
  final String? Function(String?)? validator;

  const GlassTextField({
    super.key,
    required this.controller,
    required this.label,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        GlassContainer(
          opacity: 0.05,
          borderRadius: BorderRadius.circular(16),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.white54) : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              hintText: 'Enter $label',
              hintStyle: const TextStyle(color: Colors.white24),
            ),
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
