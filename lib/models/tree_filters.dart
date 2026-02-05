class TreeFilters {
  final DateTime? lastVerifiedAfter; // Show trees verified after this date
  final DateTime? lastAddedAfter; // Show trees added after this date
  final Set<String> fruitTypes; // Empty set means show all
  final Set<String> statusTypes; // Empty set means show all ('pending', 'approved', 'rejected')
  final String treeName; // Empty string means show all
  final bool showReportedOnly; // For admins to see reported trees

  const TreeFilters({
    this.lastVerifiedAfter,
    this.lastAddedAfter,
    this.fruitTypes = const {},
    this.statusTypes = const {},
    this.treeName = '',
    this.showReportedOnly = false,
  });

  /// Check if any filters are active
  bool get hasActiveFilters =>
      lastVerifiedAfter != null ||
      lastAddedAfter != null ||
      fruitTypes.isNotEmpty ||
      statusTypes.isNotEmpty ||
      treeName.isNotEmpty ||
      showReportedOnly;

  /// Create a copy with some fields replaced
  TreeFilters copyWith({
    DateTime? Function()? lastVerifiedAfter,
    DateTime? Function()? lastAddedAfter,
    Set<String>? fruitTypes,
    Set<String>? statusTypes,
    String? treeName,
    bool? showReportedOnly,
  }) {
    return TreeFilters(
      lastVerifiedAfter: lastVerifiedAfter != null
          ? lastVerifiedAfter()
          : this.lastVerifiedAfter,
      lastAddedAfter: lastAddedAfter != null
          ? lastAddedAfter()
          : this.lastAddedAfter,
      fruitTypes: fruitTypes ?? this.fruitTypes,
      statusTypes: statusTypes ?? this.statusTypes,
      treeName: treeName ?? this.treeName,
      showReportedOnly: showReportedOnly ?? this.showReportedOnly,
    );
  }

  /// Create empty filters (no filters applied)
  static const TreeFilters empty = TreeFilters();
}
