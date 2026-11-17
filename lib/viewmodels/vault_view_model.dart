import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../domain/models/tcg_card.dart';
import '../domain/repositories/card_repository.dart';
import 'dispose_guard.dart';
import 'error_messages.dart';

sealed class VaultState extends Equatable {
  const VaultState();

  @override
  List<Object?> get props => const [];
}

class VaultLoading extends VaultState {
  const VaultLoading();
}

class VaultFailure extends VaultState {
  const VaultFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class VaultEmpty extends VaultState {
  const VaultEmpty();
}

class VaultReady extends VaultState {
  const VaultReady({
    required this.cards,
    required this.totalCards,
    required this.totalValue,
  });

  final List<TcgCard> cards;
  final int totalCards;
  final int totalValue;

  @override
  List<Object?> get props => [cards, totalCards, totalValue];
}

class VaultNoMatches extends VaultState {
  const VaultNoMatches({required this.totalCards, required this.totalValue});

  final int totalCards;
  final int totalValue;

  @override
  List<Object?> get props => [totalCards, totalValue];
}

class VaultViewModel extends ChangeNotifier with DisposeGuard {
  VaultViewModel(this._repository);

  final CardRepository _repository;

  VaultState _state = const VaultLoading();
  String? _brand;
  bool _favoritesOnly = false;
  List<TcgCard> _cards = const [];
  String? _message;

  VaultState get state => _state;
  String? get brand => _brand;
  bool get favoritesOnly => _favoritesOnly;

  String? takeMessage() {
    final message = _message;
    _message = null;
    return message;
  }

  Future<void> load() async {
    _state = const VaultLoading();
    notifyListeners();
    await refresh();
  }

  Future<void> refresh() async {
    try {
      final cards = await _repository.getCards();
      if (isDisposed) return;
      _cards = cards;
      _rebuild();
    } catch (error) {
      if (isDisposed) return;
      _state = VaultFailure(messageFor(error));
      notifyListeners();
    }
  }

  void setBrand(String? value) {
    _brand = value;
    _filterChanged();
  }

  void setFavoritesOnly(bool value) {
    _favoritesOnly = value;
    _filterChanged();
  }

  void clearFilters() {
    _brand = null;
    _favoritesOnly = false;
    _filterChanged();
  }

  Future<void> toggleFavorite(String id) async {
    final index = _cards.indexWhere((card) => card.id == id);
    if (index < 0) return;
    final updated = _cards[index].copyWith(isFavorite: !_cards[index].isFavorite);

    try {
      await _repository.updateCard(updated);
      if (isDisposed) return;
      _cards = [
        for (final card in _cards) card.id == id ? updated : card,
      ];
      _rebuild();
    } catch (error) {
      if (isDisposed) return;
      _message = messageFor(error);
      notifyListeners();
    }
  }

  Future<void> restoreCard(TcgCard card) async {
    try {
      await _repository.addCard(card);
    } catch (error) {
      if (isDisposed) return;
      _message = messageFor(error);
      notifyListeners();
      return;
    }
    if (isDisposed) return;
    await refresh();
  }

  void _filterChanged() {
    final current = _state;
    if (current is VaultLoading || current is VaultFailure) {
      notifyListeners();
    } else {
      _rebuild();
    }
  }

  void _rebuild() {
    if (_cards.isEmpty) {
      _state = const VaultEmpty();
    } else {
      final visible = [
        for (final card in _cards)
          if ((_brand == null || card.brand == _brand) &&
              (!_favoritesOnly || card.isFavorite))
            card,
      ];
      final totalValue = _cards.fold<int>(0, (sum, c) => sum + c.valueRupiah);
      _state = visible.isEmpty
          ? VaultNoMatches(totalCards: _cards.length, totalValue: totalValue)
          : VaultReady(
              cards: visible,
              totalCards: _cards.length,
              totalValue: totalValue,
            );
    }
    notifyListeners();
  }
}
