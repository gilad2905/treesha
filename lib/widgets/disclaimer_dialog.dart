import 'package:flutter/material.dart';
import 'package:treez/l10n/app_localizations.dart';

class DisclaimerDialog extends StatelessWidget {
  final bool showButton;
  final VoidCallback? onAccepted;

  const DisclaimerDialog({super.key, this.showButton = true, this.onAccepted});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.disclaimerTitle),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.disclaimerSubtitle,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),
              Text(l10n.disclaimerAgreement),
              const SizedBox(height: 16),
              _buildPoint(l10n.disclaimerPoint1Title, l10n.disclaimerPoint1Body),
              _buildPoint(l10n.disclaimerPoint2Title, l10n.disclaimerPoint2Body),
              _buildPoint(l10n.disclaimerPoint3Title, l10n.disclaimerPoint3Body),
              _buildPoint(l10n.disclaimerPoint4Title, l10n.disclaimerPoint4Body),
              _buildPoint(l10n.disclaimerPoint5Title, l10n.disclaimerPoint5Body),
              const SizedBox(height: 16),
              Text(
                l10n.disclaimerLiability,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.disclaimerRisk,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      actions: showButton
          ? [
              ElevatedButton(
                onPressed: () {
                  if (onAccepted != null) onAccepted!();
                  Navigator.of(context).pop();
                },
                child: Text(l10n.iUnderstood),
              ),
            ]
          : null,
    );
  }

  Widget _buildPoint(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(body),
        ],
      ),
    );
  }
}
