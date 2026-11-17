import 'package:flutter/material.dart';

import '../../core/widgets/empty_state.dart';
import '../../domain/models/tcg_card.dart';
import '../../viewmodels/vault_view_model.dart';
import 'vault_content.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({
    super.key,
    required this.viewModel,
    required this.detailPageBuilder,
    required this.formPageBuilder,
  });

  final VaultViewModel viewModel;
  final Widget Function(String cardId) detailPageBuilder;
  final Widget Function([TcgCard? card]) formPageBuilder;

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_showPendingMessage);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_showPendingMessage);
    super.dispose();
  }

  void _showPendingMessage() {
    final message = widget.viewModel.takeMessage();
    if (message == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, maxLines: 3)),
    );
  }

  Future<void> _openAdd() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => widget.formPageBuilder()),
    );
    if (!mounted) return;
    await widget.viewModel.refresh();
  }

  Future<void> _openCard(String id) async {
    final removed = await Navigator.of(context).push<TcgCard>(
      MaterialPageRoute(builder: (_) => widget.detailPageBuilder(id)),
    );
    if (!mounted) return;
    if (removed != null) _showUndo(removed);
    await widget.viewModel.refresh();
  }

  void _showUndo(TcgCard card) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Removed ${card.name}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => widget.viewModel.restoreCard(card),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TCG Vault')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAdd,
        icon: const Icon(Icons.add),
        label: const Text('Add card'),
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) => switch (widget.viewModel.state) {
          VaultLoading() => const Center(
              child: CircularProgressIndicator(
                semanticsLabel: 'Loading your vault',
              ),
            ),
          VaultFailure(:final message) => EmptyState(
              icon: Icons.error_outline,
              title: 'Could not load your vault',
              message: message,
              actionLabel: 'Try again',
              onAction: widget.viewModel.load,
            ),
          VaultEmpty() => EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Your vault is empty',
              message: 'Add your first card to start tracking its value.',
              actionLabel: 'Add card',
              onAction: _openAdd,
            ),
          VaultReady(:final cards, :final totalCards, :final totalValue) =>
            VaultContent(
              viewModel: widget.viewModel,
              cards: cards,
              totalCards: totalCards,
              totalValue: totalValue,
              onOpenCard: _openCard,
            ),
          VaultNoMatches(:final totalCards, :final totalValue) => VaultContent(
              viewModel: widget.viewModel,
              cards: const [],
              totalCards: totalCards,
              totalValue: totalValue,
              onOpenCard: _openCard,
            ),
        },
      ),
    );
  }
}
