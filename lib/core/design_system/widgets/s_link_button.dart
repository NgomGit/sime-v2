import 'package:flutter/material.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_text_styles.dart';

class SLinkButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? trailingIcon;
  final Color? color;

  const SLinkButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.trailingIcon,
    this.color,
  });

  @override
  State<SLinkButton> createState() => _SLinkButtonState();
}

class _SLinkButtonState extends State<SLinkButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null;
    // Utilise AppColors.primary400 par défaut (ton style d'origine) ou une couleur personnalisée
    final Color buttonColor = widget.color ?? AppColors.primary400;

    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      behavior: HitTestBehavior.opaque, // Rend toute la zone (texte + icône) cliquable
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: !isEnabled ? 0.4 : (_isPressed ? 0.6 : 1.0),
        child: Padding(
          // Petite zone de padding interne pour rendre la cible de clic plus confortable (UX)
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: buttonColor,
                ),
              ),
              if (widget.trailingIcon != null) ...[
                const SizedBox(width: 4),
                Icon(
                  widget.trailingIcon,
                  size: 16,
                  color: buttonColor,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}