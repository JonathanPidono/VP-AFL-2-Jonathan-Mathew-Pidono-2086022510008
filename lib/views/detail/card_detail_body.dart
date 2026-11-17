import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models/tcg_card.dart';
import '../shared/card_image.dart';

class CardDetailBody extends StatelessWidget {
  const CardDetailBody({super.key, required this.card});

  final TcgCard card;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.formMaxWidth),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.md),
                child: SizedBox(
                  height: AppSizes.photoHeight,
                  child: ColoredBox(
                    color: scheme.surfaceContainerHigh,
                    child: CardImage(
                      iconSize: AppSizes.iconHero,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(card.name, style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.md),
              Card(
                child: Column(
                  children: [
                    _InfoTile(
                      icon: Icons.payments_outlined,
                      label: 'Estimated value',
                      value: formatRupiah(card.valueRupiah),
                    ),
                    _InfoTile(
                      icon: Icons.category_outlined,
                      label: 'Brand',
                      value: card.brand,
                    ),
                    _InfoTile(
                      icon: Icons.diamond_outlined,
                      label: 'Rarity',
                      value: card.rarity,
                    ),
                    _InfoTile(
                      icon: Icons.verified_outlined,
                      label: 'Condition',
                      value: card.condition.label,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon),
      title: Text(value, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
