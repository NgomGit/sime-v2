// core/design_system/widgets/app_status_dialog.dart

import 'package:flutter/material.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';


enum StatusDialogType { success, error }

class AppStatusDialog extends StatefulWidget {
  final String title;
  final String message;
  final StatusDialogType type;
  final VoidCallback? onConfirm;

  const AppStatusDialog({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    this.onConfirm,
  });

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    required StatusDialogType type,
    VoidCallback? onConfirm,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.easeInOutCubic.transform(anim1.value),
          child: Opacity(
            opacity: anim1.value,
            child: AppStatusDialog(
              title: title,
              message: message,
              type: type,
              onConfirm: onConfirm,
            ),
          ),
        );
      },
    );
  }

  @override
  State<AppStatusDialog> createState() => _AppStatusDialogState();
}

class _AppStatusDialogState extends State<AppStatusDialog> with SingleTickerProviderStateMixin {
  late AnimationController _iconController;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = widget.type == StatusDialogType.success;
    
    // Application stricte des jetons de couleur de ta charte
    final themeColor = isSuccess ? AppColors.primary400 : AppColors.error; 
    final iconData = isSuccess ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded;

    return AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0), // Ajustable selon AppDimensions.radiusLG
      ),
      contentPadding: const EdgeInsets.all(24.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icône animée
          RotationTransition(
            turns: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: _iconController, curve: Curves.easeOutBack),
            ),
            child: Icon(
              iconData,
              size: 72,
              color: themeColor,
            ),
          ),
          const SizedBox(height: 16),
          
          // Titre de l'alerte
          Text(
            widget.title,
            style: const TextStyle(
              color: AppColors.neutral800,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          
          // Message épuré provenant directement de la violation
          Text(
            widget.message,
            style: const TextStyle(
              color: AppColors.neutral600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Bouton de confirmation d'action
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                widget.onConfirm?.call();
              },
              child: Text(
                isSuccess ? 'Continuer' : 'Compris',
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}