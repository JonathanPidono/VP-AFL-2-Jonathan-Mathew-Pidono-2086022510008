import '../../domain/models/tcg_card.dart';
import 'card_data_source.dart';

class InMemoryCardService implements CardDataSource {
  InMemoryCardService([List<TcgCard>? initial])
      : _cards = initial == null ? null : List.of(initial);

  List<TcgCard>? _cards;

  @override
  Future<List<TcgCard>?> readAll() async {
    final cards = _cards;
    return cards == null ? null : List.of(cards);
  }

  @override
  Future<void> writeAll(List<TcgCard> cards) async {
    _cards = List.of(cards);
  }
}
