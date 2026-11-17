import '../../domain/models/tcg_card.dart';
import '../../domain/repositories/card_repository.dart';
import '../services/card_data_source.dart';
import '../services/seed_loader.dart';

class CardRepositoryImpl implements CardRepository {
  CardRepositoryImpl({required this._source, required this._seed});

  final CardDataSource _source;
  final SeedLoader _seed;

  @override
  Future<List<TcgCard>> getCards() {
    return _run(
      () async => _newestFirst(await _loadAll()),
      (cause) => CardReadException(cause: cause),
    );
  }

  @override
  Future<TcgCard?> getCard(String id) {
    return _run(() async {
      for (final card in await _loadAll()) {
        if (card.id == id) return card;
      }
      return null;
    }, (cause) => CardReadException(cause: cause));
  }

  @override
  Future<void> addCard(TcgCard card) {
    return _run(() async {
      final cards = await _loadAll();
      await _source.writeAll([
        card,
        for (final other in cards)
          if (other.id != card.id) other,
      ]);
    }, (cause) => CardWriteException(cause: cause));
  }

  @override
  Future<void> updateCard(TcgCard card) {
    return _run(() async {
      final cards = await _loadAll();
      if (!cards.any((other) => other.id == card.id)) {
        throw StateError('There is no card with id ${card.id}');
      }
      await _source.writeAll([
        for (final other in cards) other.id == card.id ? card : other,
      ]);
    }, (cause) => CardWriteException(cause: cause));
  }

  @override
  Future<void> deleteCard(String id) {
    return _run(() async {
      final cards = await _loadAll();
      await _source.writeAll([
        for (final other in cards)
          if (other.id != id) other,
      ]);
    }, (cause) => CardWriteException(cause: cause));
  }

  Future<List<TcgCard>> _loadAll() async {
    final stored = await _source.readAll();
    if (stored != null) return stored;

    final starter = await _seed.load();
    await _source.writeAll(starter);
    return starter;
  }

  static List<TcgCard> _newestFirst(List<TcgCard> cards) {
    final sorted = List.of(cards);
    sorted.sort((a, b) {
      final byDate = b.createdAt.compareTo(a.createdAt);
      return byDate != 0 ? byDate : a.id.compareTo(b.id);
    });
    return sorted;
  }

  Future<T> _run<T>(
    Future<T> Function() action,
    CardException Function(Object cause) wrap,
  ) async {
    try {
      return await action();
    } on CardException {
      rethrow;
    } catch (error) {
      throw wrap(error);
    }
  }
}
