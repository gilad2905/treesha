class Fruit {
  final String type;
  final String edibleSeason;

  Fruit({required this.type, required this.edibleSeason});

  factory Fruit.fromJson(Map<String, dynamic> json) {
    return Fruit(
      type: json['fruit_type'] as String,
      edibleSeason: json['fruit_edible_season'] as String,
    );
  }

  // Used for display in dropdown
  @override
  String toString() => type;

  // Used for comparison in dropdown_search
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Fruit &&
        other.type == type &&
        other.edibleSeason == edibleSeason;
  }

  @override
  int get hashCode => type.hashCode ^ edibleSeason.hashCode;
}
