import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../domain/models/tcg_card.dart';
import '../domain/repositories/card_repository.dart';
import 'dispose_guard.dart';
import 'error_messages.dart';

sealed class DetailState extends Equatable {
  const DetailState();

  @override
  List<Object?> get props => const [];
}

class DetailLoading extends DetailState {
  const DetailLoading();
}

class DetailFound extends DetailState {
  const DetailFound(this.card);

  final TcgCard card;

  @override
  List<Object?> get props => [card];
}

class DetailNotFound extends DetailState {
  const DetailNotFound();
}

class DetailFailure extends DetailState {
  const DetailFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class DetailDeleted extends DetailState {
  const DetailDeleted(this.card);

  final TcgCard card;

  @override
  List<Object?> get props => [card];
}

class DetailViewModel extends ChangeNotifier with DisposeGuard {
  DetailViewModel(this._repository, this.cardId);

  final CardRepository _repository;
  final String cardId;

  DetailState _state = const DetailLoading();
  String? _message;

  DetailState get state => _state;

  String? takeMessage() {
    final message = _message;
    _message = null;
    return message;
  }

  Future<void> load() async {
    try {
      final card = await _repository.getCard(cardId);
      if (isDisposed) return;
      _state = card == null ? const DetailNotFound() : DetailFound(card);
    } catch (error) {
      if (isDisposed) return;
      _state = DetailFailure(messageFor(error));
    }
    notifyListeners();
  }

  Future<void> retry() async {
    _state = const DetailLoading();
    notifyListeners();
    await load();
  }

  Future<void> toggleFavorite() async {
    final current = _state;
    if (current is! DetailFound) return;
    final updated = current.card.copyWith(isFavorite: !current.card.isFavorite);

    try {
      await _repository.updateCard(updated);
      if (isDisposed) return;
      _state = DetailFound(updated);
    } catch (error) {
      if (isDisposed) return;
      _message = messageFor(error);
    }
    notifyListeners();
  }

  Future<void> delete() async {
    final current = _state;
    if (current is! DetailFound) return;

    try {
      await _repository.deleteCard(current.card.id);
      if (isDisposed) return;
      _state = DetailDeleted(current.card);
    } catch (error) {
      if (isDisposed) return;
      _message = messageFor(error);
    }
    notifyListeners();
  }
}
