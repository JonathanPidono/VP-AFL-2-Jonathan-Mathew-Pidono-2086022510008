import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

class CardImage extends StatelessWidget {
  const CardImage({
    super.key,
    this.asset,
    this.iconSize = AppSizes.iconLarge,
  });

  final String? asset;
  final double iconSize;

  Widget _placeholder(BuildContext context) {
    return Center(
      child: Icon(
        Icons.style,
        size: iconSize,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final path = asset;
    if (path == null) return _placeholder(context);

    return Image.asset(
      path,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
      semanticLabel: 'Card picture',
      errorBuilder: (context, error, stackTrace) => _placeholder(context),
    );
  }
}
