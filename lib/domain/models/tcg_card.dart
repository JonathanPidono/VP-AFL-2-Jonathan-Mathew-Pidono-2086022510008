import 'package:equatable/equatable.dart';

const brandNames = ['Pokémon', 'Yu-Gi-Oh!', 'Magic'];

const cardRarities = [
  'Common',
  'Uncommon',
  'Rare',
  'Super Rare',
  'Ultra Rare',
];

enum CardCondition {
  mint('Mint'),
  nearMint('Near mint'),
  excellent('Excellent'),
  played('Played');

  const CardCondition(this.label);

  final String label;

  static CardCondition fromName(String name) {
    for (final condition in values) {
      if (condition.name == name) return condition;
    }
    throw FormatException('Unknown card condition: $name');
  }
}

class TcgCard extends Equatable {
  const TcgCard({
    required this.id,
    required this.name,
    required this.brand,
    required this.rarity,
    required this.condition,
    required this.valueRupiah,
    required this.createdAt,
    this.isFavorite = false,
  });

  factory TcgCard.fromJson(Map<String, dynamic> json) {
    return TcgCard(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      rarity: json['rarity'] as String,
      condition: CardCondition.fromName(json['condition'] as String),
      valueRupiah: json['valueRupiah'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  final String id;
  final String name;
  final String brand;
  final String rarity;
  final CardCondition condition;
  final int valueRupiah;

  final DateTime createdAt;
  final bool isFavorite;

  TcgCard copyWith({bool? isFavorite}) {
    return TcgCard(
      id: id,
      name: name,
      brand: brand,
      rarity: rarity,
      condition: condition,
      valueRupiah: valueRupiah,
      createdAt: createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'brand': brand,
        'rarity': rarity,
        'condition': condition.name,
        'valueRupiah': valueRupiah,
        'createdAt': createdAt.toIso8601String(),
        'isFavorite': isFavorite,
      };

  @override
  List<Object?> get props => [
        id,
        name,
        brand,
        rarity,
        condition,
        valueRupiah,
        createdAt,
        isFavorite,
      ];
}
