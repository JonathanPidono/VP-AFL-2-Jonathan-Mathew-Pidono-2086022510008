import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/tcg_card.dart';
import 'card_data_source.dart';

class LocalCardService implements CardDataSource {
  LocalCardService(this._prefs);

  static const storageKey = 'tcg_vault.cards';

  final SharedPreferences _prefs;

  static Future<LocalCardService> open() async {
    return LocalCardService(await SharedPreferences.getInstance());
  }

  @override
  Future<List<TcgCard>?> readAll() async {
    final text = _prefs.getString(storageKey);
    if (text == null) return null;

    final items = jsonDecode(text) as List<dynamic>;
    return [
      for (final item in items) TcgCard.fromJson(item as Map<String, dynamic>),
    ];
  }

  @override
  Future<void> writeAll(List<TcgCard> cards) async {
    final text = jsonEncode([for (final card in cards) card.toJson()]);
    final saved = await _prefs.setString(storageKey, text);
    if (!saved) throw StateError('The cards could not be written to storage');
  }
}
