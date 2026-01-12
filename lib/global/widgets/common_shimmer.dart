import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sewa/global/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class CommonShimmer extends StatelessWidget {
  final BorderRadius? borderRadius;
  final Gradient? webShimmerGradient;
  final Color? bgColor;
  final Color? baseColor;
  final Color? highlightColor;
  final double? height, width;

  const CommonShimmer({
    super.key,
    this.borderRadius,
    this.bgColor,
    this.webShimmerGradient,
    this.baseColor,
    this.highlightColor,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return kIsWeb
        ? Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: webShimmerGradient ??
                  LinearGradient(
                    colors: [
                      AppColors.grey.withOpacity(0.2),
                      AppColors.greyShimmer,
                    ],
                  ),
            ),
          )
        : SizedBox(
            height: height,
            width: width,
            child: Shimmer.fromColors(
              enabled: true,
              baseColor: baseColor ?? AppColors.grey.withOpacity(0.2),
              highlightColor: highlightColor ?? AppColors.grey400,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  color: bgColor ?? AppColors.greyBg,
                ),
              ),
            ),
          );
  }
}
