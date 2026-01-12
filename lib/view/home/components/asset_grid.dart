import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';


class AssetGrid extends StatelessWidget {
  final dynamic data;
  final bool isTablet;

  const AssetGrid({
    super.key,
    required this.data,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(5),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 2 : 1,
        crossAxisSpacing: isTablet ? 16 : 8,
        mainAxisSpacing: isTablet ? 16 : 8,
        childAspectRatio: isTablet
            ? MediaQuery.of(context).orientation == Orientation.portrait
                ? 1.7
                : 2.7
            : 1.67,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        return DelayedDisplay(
          delay: Duration(milliseconds: 100 * index),
          child: _buildCard(data[index]),
        );
      },
    );
  }

  Widget _buildCard(dynamic item) {
    return item;
  }
}