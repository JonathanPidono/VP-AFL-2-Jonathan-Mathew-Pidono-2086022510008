import '../../domain/models/tcg_card.dart';

abstract class CardDataSource {
  Future<List<TcgCard>?> readAll();

  Future<void> writeAll(List<TcgCard> cards);
}
