import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models/tcg_card.dart';

class VaultSummary extends StatelessWidget {
  const VaultSummary({
    super.key,
    required this.totalCards,
    required this.totalValue,
  });

  final int totalCards;
  final int totalValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;

    return Card(
      color: scheme.primaryContainer,
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        0,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estimated value',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.labelLarge?.copyWith(color: scheme.onPrimaryContainer),
            ),
            const SizedBox(height: AppSpacing.xs),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                formatRupiah(totalValue),
                maxLines: 1,
                style: text.displaySmall?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '$totalCards cards in your vault',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.bodyLarge?.copyWith(color: scheme.onPrimaryContainer),
            ),
          ],
        ),
      ),
    );
  }
}

class BrandFilterBar extends StatelessWidget {
  const BrandFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.favoritesOnly,
    required this.onFavoritesChanged,
  });

  final String? selected;
  final ValueChanged<String?> onSelected;
  final bool favoritesOnly;
  final ValueChanged<bool> onFavoritesChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: selected == null,
            onSelected: (_) => onSelected(null),
          ),
          for (final name in brandNames)
            ChoiceChip(
              label: Text(name),
              selected: selected == name,
              onSelected: (_) => onSelected(name),
            ),
          FilterChip(
            avatar: Icon(favoritesOnly ? Icons.star : Icons.star_border),
            label: const Text('Favourites'),
            showCheckmark: false,
            selected: favoritesOnly,
            onSelected: onFavoritesChanged,
          ),
        ],
      ),
    );
  }
}
