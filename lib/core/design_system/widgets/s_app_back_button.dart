import 'package:flutter/material.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: AppDimensions.sp16),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, size: AppDimensions.iconSM),
          color: AppColors.neutral800,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            ),
            side: const BorderSide(color: AppColors.border),
            fixedSize: const Size(36, 36),
            padding: EdgeInsets.zero,
          ),
          onPressed: onPressed ?? () {},
        ),
      ),
    );
  }
}
