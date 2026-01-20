import 'package:flutter/material.dart';
import 'package:treesha/l10n/app_localizations.dart';

class FilterDialog extends StatefulWidget {
  final double initialMinVerificationScore;

  const FilterDialog({super.key, required this.initialMinVerificationScore});

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late double _minVerificationScore;

  @override
  void initState() {
    super.initState();
    _minVerificationScore = widget.initialMinVerificationScore;
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
            // Verification Score Filter
            Text(
              l10n.verificationScoreFilter,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.minimumVerificationScore(_minVerificationScore.toInt()),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Slider(
              value: _minVerificationScore,
              min: -10.0,
              max: 10.0,
              divisions: 20,
              label: _minVerificationScore.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _minVerificationScore = value;
                });
              },
            ),
            const SizedBox(height: 16),
            // Placeholder for future filters
            Text(
              l10n.moreFiltersComingSoon,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
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
            // Reset to default value (0)
            Navigator.of(context).pop(0.0);
          },
          child: Text(l10n.reset),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(_minVerificationScore);
          },
          child: Text(l10n.apply),
        ),
      ],
    );
  }
}
