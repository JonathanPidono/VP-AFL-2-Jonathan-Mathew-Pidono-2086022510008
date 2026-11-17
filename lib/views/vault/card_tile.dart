import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models/tcg_card.dart';
import '../shared/card_image.dart';

class CardTile extends StatelessWidget {
  const CardTile({
    super.key,
    required this.card,
    required this.onTap,
    required this.onToggleFavorite,
  });

  final TcgCard card;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                    child: SizedBox.expand(
                      child: CardImage(
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                card.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: text.titleMedium,
              ),
              Text(
                '${card.brand} • ${card.rarity}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
              Row(
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        formatRupiah(card.valueRupiah),
                        maxLines: 1,
                        style: text.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    isSelected: card.isFavorite,
                    icon: const Icon(Icons.star_border),
                    selectedIcon: const Icon(Icons.star),
                    tooltip: card.isFavorite
                        ? 'Remove from favourites'
                        : 'Add to favourites',
                    onPressed: onToggleFavorite,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
