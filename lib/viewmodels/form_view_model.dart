import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../domain/models/tcg_card.dart';
import '../domain/repositories/card_repository.dart';
import 'dispose_guard.dart';
import 'error_messages.dart';

class CardDraft extends Equatable {
  const CardDraft({
    required this.brand,
    required this.rarity,
    required this.condition,
    this.isDirty = false,
  });

  final String brand;
  final String rarity;
  final CardCondition condition;

  final bool isDirty;

  CardDraft copyWith({
    String? brand,
    String? rarity,
    CardCondition? condition,
    bool? isDirty,
  }) {
    return CardDraft(
      brand: brand ?? this.brand,
      rarity: rarity ?? this.rarity,
      condition: condition ?? this.condition,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  List<Object?> get props => [
        brand,
        rarity,
        condition,
        isDirty,
      ];
}

sealed class CardFormState extends Equatable {
  const CardFormState(this.draft);

  final CardDraft draft;

  @override
  List<Object?> get props => [draft];
}

class CardFormEditing extends CardFormState {
  const CardFormEditing(super.draft, {this.nameError, this.valueError});

  final String? nameError;
  final String? valueError;

  @override
  List<Object?> get props => [draft, nameError, valueError];
}

class CardFormSaving extends CardFormState {
  const CardFormSaving(super.draft);
}

class CardFormSaved extends CardFormState {
  const CardFormSaved(super.draft, this.card);

  final TcgCard card;

  @override
  List<Object?> get props => [draft, card];
}

class CardFormFailed extends CardFormState {
  const CardFormFailed(super.draft, this.message);

  final String message;

  @override
  List<Object?> get props => [draft, message];
}

class FormViewModel extends ChangeNotifier with DisposeGuard {
  FormViewModel(
    this._repository, {
    this.card,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    _state = CardFormEditing(_firstDraft());
  }

  final CardRepository _repository;
  final TcgCard? card;
  final DateTime Function() _clock;

  late CardFormState _state;

  CardFormState get state => _state;

  bool get isEditing => card != null;

  String get initialName => card?.name ?? '';
  String get initialValue => card?.valueRupiah.toString() ?? '';

  CardDraft _firstDraft() {
    final old = card;
    return CardDraft(
      brand: (old != null && brandNames.contains(old.brand))
          ? old.brand
          : brandNames.first,
      rarity: (old != null && cardRarities.contains(old.rarity))
          ? old.rarity
          : cardRarities.first,
      condition: old?.condition ?? CardCondition.nearMint,
    );
  }

  void setBrand(String value) {
    _edit(draft: _state.draft.copyWith(brand: value));
  }

  void setRarity(String value) {
    _edit(draft: _state.draft.copyWith(rarity: value));
  }

  void setCondition(CardCondition value) {
    _edit(draft: _state.draft.copyWith(condition: value));
  }

  void nameChanged() => _edit(clearNameError: true);

  void valueChanged() => _edit(clearValueError: true);

  Future<void> save(String name, String valueText) async {
    final current = _state;
    if (current is CardFormSaving || current is CardFormSaved) return;

    final trimmedName = name.trim();
    final value = int.tryParse(valueText.trim());
    final draft = current.draft;

    if (trimmedName.isEmpty || value == null || value <= 0) {
      _state = CardFormEditing(
        draft,
        nameError: trimmedName.isEmpty ? nameRequiredMessage : null,
        valueError:
            (value == null || value <= 0) ? valueInvalidMessage : null,
      );
      notifyListeners();
      return;
    }

    _state = CardFormSaving(draft);
    notifyListeners();

    try {
      final old = card;
      final now = _clock();
      final saved = TcgCard(
        id: old?.id ?? 'card-${now.microsecondsSinceEpoch}',
        name: trimmedName,
        brand: draft.brand,
        rarity: draft.rarity,
        condition: draft.condition,
        valueRupiah: value,
        createdAt: old?.createdAt ?? now,
        isFavorite: old?.isFavorite ?? false,
      );

      if (old == null) {
        await _repository.addCard(saved);
      } else {
        await _repository.updateCard(saved);
      }
      if (isDisposed) return;
      _state = CardFormSaved(draft, saved);
    } catch (error) {
      if (isDisposed) return;
      _state = CardFormFailed(draft, messageFor(error));
    }
    notifyListeners();
  }

  void _edit({
    CardDraft? draft,
    bool clearNameError = false,
    bool clearValueError = false,
  }) {
    final current = _state;
    if (current is CardFormSaving || current is CardFormSaved) return;

    final editing = current is CardFormEditing ? current : null;
    _state = CardFormEditing(
      (draft ?? current.draft).copyWith(isDirty: true),
      nameError: clearNameError ? null : editing?.nameError,
      valueError: clearValueError ? null : editing?.valueError,
    );
    notifyListeners();
  }
}
