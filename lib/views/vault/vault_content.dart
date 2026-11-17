import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/widgets/empty_state.dart';
import '../../domain/models/tcg_card.dart';
import '../../viewmodels/vault_view_model.dart';
import 'card_tile.dart';
import 'vault_controls.dart';

class VaultContent extends StatelessWidget {
  const VaultContent({
    super.key,
    required this.viewModel,
    required this.cards,
    required this.totalCards,
    required this.totalValue,
    required this.onOpenCard,
  });

  final VaultViewModel viewModel;
  final List<TcgCard> cards;
  final int totalCards;
  final int totalValue;
  final ValueChanged<String> onOpenCard;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                VaultSummary(totalCards: totalCards, totalValue: totalValue),
                BrandFilterBar(
                  selected: viewModel.brand,
                  onSelected: viewModel.setBrand,
                  favoritesOnly: viewModel.favoritesOnly,
                  onFavoritesChanged: viewModel.setFavoritesOnly,
                ),
              ],
            ),
          ),
          _cardsSliver(),
        ],
      ),
    );
  }

  Widget _cardsSliver() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.fabClearance,
      ),
      sliver: cards.isEmpty
          ? SliverFillRemaining(hasScrollBody: false, child: _noMatches())
          : SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: AppSizes.gridTileMaxWidth,
                mainAxisExtent: AppSizes.gridTileHeight,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
              ),
              itemCount: cards.length,
              itemBuilder: (context, i) {
                final card = cards[i];
                return CardTile(
                  key: ValueKey(card.id),
                  card: card,
                  onTap: () => onOpenCard(card.id),
                  onToggleFavorite: () => viewModel.toggleFavorite(card.id),
                );
              },
            ),
    );
  }

  Widget _noMatches() {
    if (viewModel.favoritesOnly && viewModel.brand == null) {
      return EmptyState(
        icon: Icons.star_border,
        title: 'No favourites yet',
        message: 'Tap the star on a card to find it here.',
        actionLabel: 'Show all cards',
        onAction: viewModel.clearFilters,
      );
    }
    return EmptyState(
      icon: Icons.search_off,
      title: 'No cards match',
      message: 'Try a different brand or show all cards.',
      actionLabel: 'Show all cards',
      onAction: viewModel.clearFilters,
    );
  }
}
