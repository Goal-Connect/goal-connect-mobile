import 'package:flutter/material.dart';
import 'package:goal_connect/generated/l10n/app_localizations.dart';

class NoInternetCard extends StatelessWidget {
  const NoInternetCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.5),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  color: Colors.red,
                  size: 20,
                ),
                const SizedBox(height: 8),
                Text(
                  l.noInternetTitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  l.noInternetSubtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.red.withValues(alpha: 0.7),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
