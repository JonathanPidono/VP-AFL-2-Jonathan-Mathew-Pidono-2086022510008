import '../models/tcg_card.dart';

abstract class CardRepository {
  Future<List<TcgCard>> getCards();
  Future<TcgCard?> getCard(String id);
  Future<void> addCard(TcgCard card);
  Future<void> updateCard(TcgCard card);
  Future<void> deleteCard(String id);

}

sealed class CardException implements Exception {
  const CardException({this.cause});

  final Object? cause;

  @override
  String toString() => '$runtimeType(cause: $cause)';
}

class CardReadException extends CardException {
  const CardReadException({super.cause});
}

class CardWriteException extends CardException {
  const CardWriteException({super.cause});
}
