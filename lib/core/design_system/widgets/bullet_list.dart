import 'package:flutter/material.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/design_system/widgets/s_card.dart';

class BulletList extends StatelessWidget {
  const BulletList({super.key, 
    required this.items,
    required this.dotColor,
    required this.dotBg,
    required this.icon,
  });
  final List<String> items;
  final Color dotColor, dotBg;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SCard(
      padding: const EdgeInsets.all(AppDimensions.sp16),
      child: Column(
        children: items.asMap().entries.map((e) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: e.key < items.length - 1 ? AppDimensions.sp10 : 0),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 18,
                height: 18,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(color: dotBg, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Icon(icon, size: 10, color: dotColor),
              ),
              const SizedBox(width: AppDimensions.sp10),
              Expanded(child: Text(e.value, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral600))),
            ]),
          );
        }).toList(),
      ),
    );
  }
}
