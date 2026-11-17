import 'package:flutter/material.dart';

import '../../core/widgets/empty_state.dart';
import '../../domain/models/tcg_card.dart';
import '../../viewmodels/detail_view_model.dart';
import 'card_detail_body.dart';

class CardDetailScreen extends StatefulWidget {
  const CardDetailScreen({
    super.key,
    required this.createViewModel,
    required this.formPageBuilder,
  });

  final DetailViewModel Function() createViewModel;
  final Widget Function([TcgCard? card]) formPageBuilder;

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  late final DetailViewModel _viewModel = widget.createViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onChanged);
    _viewModel.load();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;
    final state = _viewModel.state;
    if (state is DetailDeleted) {
      Navigator.of(context).pop(state.card);
      return;
    }
    final message = _viewModel.takeMessage();
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message, maxLines: 3)),
      );
    }
  }

  Future<void> _openEdit(TcgCard card) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => widget.formPageBuilder(card)),
    );
    if (!mounted) return;
    await _viewModel.load();
  }

  Future<void> _confirmRemove(TcgCard card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove this card?'),
        content: Text('"${card.name}" will be removed from your vault.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _viewModel.delete();
  }

  List<Widget> _actions(TcgCard card) => [
        IconButton(
          isSelected: card.isFavorite,
          icon: const Icon(Icons.star_border),
          selectedIcon: const Icon(Icons.star),
          tooltip:
              card.isFavorite ? 'Remove from favourites' : 'Add to favourites',
          onPressed: _viewModel.toggleFavorite,
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          tooltip: 'Edit card',
          onPressed: () => _openEdit(card),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Remove card',
          onPressed: () => _confirmRemove(card),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final state = _viewModel.state;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Card details'),
            actions: state is DetailFound ? _actions(state.card) : null,
          ),
          body: switch (state) {
            DetailLoading() || DetailDeleted() => const Center(
                child: CircularProgressIndicator(
                  semanticsLabel: 'Loading the card',
                ),
              ),
            DetailFound(:final card) => CardDetailBody(card: card),
            DetailNotFound() => const EmptyState(
                icon: Icons.search_off,
                title: 'Card not found',
                message: 'This card is no longer in your vault.',
              ),
            DetailFailure(:final message) => EmptyState(
                icon: Icons.error_outline,
                title: 'Could not load this card',
                message: message,
                actionLabel: 'Try again',
                onAction: _viewModel.retry,
              ),
          },
        );
      },
    );
  }
}
