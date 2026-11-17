import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/models/tcg_card.dart';

class SeedLoader {
  SeedLoader({
    Future<String> Function(String path)? loadAsset,
    this.assetPath = 'assets/data/sample_cards.json',
  }) : _loadAsset = loadAsset ?? rootBundle.loadString;

  final String assetPath;
  final Future<String> Function(String path) _loadAsset;

  Future<List<TcgCard>> load() async {
    final items = jsonDecode(await _loadAsset(assetPath)) as List<dynamic>;
    return [
      for (final item in items) TcgCard.fromJson(item as Map<String, dynamic>),
    ];
  }
}
