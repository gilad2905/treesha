class TreeFilters {
  final DateTime? lastVerifiedAfter; // Show trees verified after this date
  final DateTime? lastAddedAfter; // Show trees added after this date
  final Set<String> fruitTypes; // Empty set means show all
  final String treeName; // Empty string means show all

  const TreeFilters({
    this.lastVerifiedAfter,
    this.lastAddedAfter,
    this.fruitTypes = const {},
    this.treeName = '',
  });

  /// Check if any filters are active
  bool get hasActiveFilters =>
      lastVerifiedAfter != null ||
      lastAddedAfter != null ||
      fruitTypes.isNotEmpty ||
      treeName.isNotEmpty;

  /// Create a copy with some fields replaced
  TreeFilters copyWith({
    DateTime? Function()? lastVerifiedAfter,
    DateTime? Function()? lastAddedAfter,
    Set<String>? fruitTypes,
    String? treeName,
  }) {
    return TreeFilters(
      lastVerifiedAfter: lastVerifiedAfter != null
          ? lastVerifiedAfter()
          : this.lastVerifiedAfter,
      lastAddedAfter: lastAddedAfter != null
          ? lastAddedAfter()
          : this.lastAddedAfter,
      fruitTypes: fruitTypes ?? this.fruitTypes,
      treeName: treeName ?? this.treeName,
    );
  }

  /// Create empty filters (no filters applied)
  static const TreeFilters empty = TreeFilters();
}
