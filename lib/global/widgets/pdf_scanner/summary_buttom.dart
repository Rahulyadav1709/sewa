import 'package:flutter/material.dart';
import 'package:sewa/global/app_colors.dart';

class SummaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const SummaryButton({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.blueShadeGradiant),
              ),
            )
          : const Icon(Icons.document_scanner_rounded),
      tooltip: 'Generate Summary',
    );
  }
}