import 'package:flutter/material.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/widgets/s_shimer.dart';

class Skeleton extends StatelessWidget {
  const Skeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.pagePaddingH),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SShimmer(width: 36, height: 36, radius: AppDimensions.radiusSM),
          SizedBox(height: AppDimensions.sp24),
          Row(children: [
            SShimmer(
                width: 58, height: 58, radius: AppDimensions.radiusMD),
            SizedBox(width: AppDimensions.sp14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SShimmer(width: double.infinity, height: 20),
                    SizedBox(height: AppDimensions.sp8),
                    SShimmer(width: 160, height: 13),
                    SizedBox(height: AppDimensions.sp6),
                    SShimmer(width: 120, height: 11),
                  ]),
            ),
          ]),
          SizedBox(height: AppDimensions.sp20),
          Row(children: [
            SShimmer(width: 56, height: 24, radius: AppDimensions.radiusFull),
            SizedBox(width: AppDimensions.sp8),
            SShimmer(width: 72, height: 24, radius: AppDimensions.radiusFull),
            SizedBox(width: AppDimensions.sp8),
            SShimmer(width: 80, height: 24, radius: AppDimensions.radiusFull),
          ]),
          SizedBox(height: AppDimensions.sp24),
          SShimmer(
              width: double.infinity,
              height: 96,
              radius: AppDimensions.radiusLG),
          SizedBox(height: AppDimensions.sp16),
          SShimmer(
              width: double.infinity,
              height: 130,
              radius: AppDimensions.radiusLG),
          SizedBox(height: AppDimensions.sp16),
          SShimmer(
              width: double.infinity,
              height: 130,
              radius: AppDimensions.radiusLG),
        ]),
      ),
    );
  }
}