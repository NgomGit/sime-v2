import 'package:flutter/material.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';

class ExpandableText extends StatefulWidget {
  const ExpandableText({super.key, required this.text});
  final String text;

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AnimatedCrossFade(
        crossFadeState:
            _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 220),
        firstChild: Text(widget.text,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral600, height: 1.5),
            maxLines: 4,
            overflow: TextOverflow.ellipsis),
        secondChild: Text(widget.text, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral600, height: 1.5)),
      ),
      const SizedBox(height: AppDimensions.sp8),
      GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(_expanded ? 'Voir moins' : 'Lire la suite',
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.primary400, fontWeight: FontWeight.w600)),
          const SizedBox(width: 3),
          Icon(
            _expanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            size: AppDimensions.iconSM,
            color: AppColors.primary400,
          ),
        ]),
      ),
    ]);
  }
}
