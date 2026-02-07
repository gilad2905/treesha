import 'package:flutter/material.dart';
import 'package:treesha/constants.dart';
import 'package:treesha/l10n/app_localizations.dart';
import 'package:treesha/models/tree_filters.dart';

class FilterDialog extends StatefulWidget {
  final TreeFilters initialFilters;
  final List<String> availableFruitTypes;
  final bool isAdmin;

  const FilterDialog({
    super.key,
    required this.initialFilters,
    required this.availableFruitTypes,
    this.isAdmin = false,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late DateTime? _lastVerifiedAfter;
  late DateTime? _lastAddedAfter;
  late Set<String> _selectedFruitTypes;
  late Set<String> _selectedStatusTypes;
  late TextEditingController _treeNameController;
  late bool _showReportedOnly;
  late bool _showUnknownFruitsOnly;

  final Map<String, String> _statusLabels = {
    AppConstants.statusApproved: 'Approved',
    AppConstants.statusPending: 'Pending',
    AppConstants.statusRejected: 'Rejected',
  };

  @override
  void initState() {
    super.initState();
    _lastVerifiedAfter = widget.initialFilters.lastVerifiedAfter;
    _lastAddedAfter = widget.initialFilters.lastAddedAfter;
    _selectedFruitTypes = Set.from(widget.initialFilters.fruitTypes);
    _selectedStatusTypes = Set.from(widget.initialFilters.statusTypes);
    _treeNameController = TextEditingController(
      text: widget.initialFilters.treeName,
    );
    _showReportedOnly = widget.initialFilters.showReportedOnly;
    _showUnknownFruitsOnly = widget.initialFilters.showUnknownFruitsOnly;
  }

  @override
  void dispose() {
    _treeNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.filters),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tree Name Filter
            Text(
              'Tree Name',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _treeNameController,
              decoration: const InputDecoration(
                hintText: 'Search by tree name...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Fruit Type Filter
            Text(
              'Fruit Type',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (widget.availableFruitTypes.isEmpty)
              const Text(
                'No fruit types available',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.availableFruitTypes.map((fruitType) {
                  final isSelected = _selectedFruitTypes.contains(fruitType);
                  return FilterChip(
                    label: Text(fruitType),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedFruitTypes.add(fruitType);
                        } else {
                          _selectedFruitTypes.remove(fruitType);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            const SizedBox(height: 24),

            // Status Filter
            Text(
              'Status',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _statusLabels.entries.map((entry) {
                final status = entry.key;
                final label = entry.value;
                final isSelected = _selectedStatusTypes.contains(status);
                return FilterChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedStatusTypes.add(status);
                      } else {
                        _selectedStatusTypes.remove(status);
                      }
                    });
                  },
                  backgroundColor:
                      status == AppConstants.statusApproved
                          ? Colors.green.withOpacity(0.1)
                          : status == AppConstants.statusRejected
                              ? Colors.red.withOpacity(0.1)
                              : null,
                  selectedColor:
                      status == AppConstants.statusApproved
                          ? Colors.green.withOpacity(0.3)
                          : status == AppConstants.statusRejected
                              ? Colors.red.withOpacity(0.3)
                              : null,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Last Verified Date Filter
            Text(
              'Last Verified After',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _lastVerifiedAfter == null
                        ? 'No date filter'
                        : _formatDate(_lastVerifiedAfter!),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _lastVerifiedAfter ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _lastVerifiedAfter = date;
                      });
                    }
                  },
                ),
                if (_lastVerifiedAfter != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _lastVerifiedAfter = null;
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Last Added Date Filter
            Text(
              'Added After',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _lastAddedAfter == null
                        ? 'No date filter'
                        : _formatDate(_lastAddedAfter!),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _lastAddedAfter ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _lastAddedAfter = date;
                      });
                    }
                  },
                ),
                if (_lastAddedAfter != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _lastAddedAfter = null;
                      });
                    },
                  ),
              ],
            ),
            if (widget.isAdmin) ...[
              const Divider(height: 32),
              CheckboxListTile(
                title: const Text('Show Reported Only'),
                subtitle: const Text('Filter trees flagged by users'),
                value: _showReportedOnly,
                onChanged: (value) {
                  setState(() {
                    _showReportedOnly = value ?? false;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                title: const Text('Show Unknown Fruits Only'),
                subtitle: const Text('Filter fruits not in the official list'),
                value: _showUnknownFruitsOnly,
                onChanged: (value) {
                  setState(() {
                    _showUnknownFruitsOnly = value ?? false;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Cancel without applying
          },
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            // Reset to empty filters
            Navigator.of(context).pop(TreeFilters.empty);
          },
          child: Text(l10n.reset),
        ),
        ElevatedButton(
          onPressed: () {
            // Apply filters
            final filters = TreeFilters(
              lastVerifiedAfter: _lastVerifiedAfter,
              lastAddedAfter: _lastAddedAfter,
              fruitTypes: _selectedFruitTypes,
              statusTypes: _selectedStatusTypes,
              treeName: _treeNameController.text.trim(),
              showReportedOnly: _showReportedOnly,
              showUnknownFruitsOnly: _showUnknownFruitsOnly,
            );
            Navigator.of(context).pop(filters);
          },
          child: Text(l10n.apply),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
