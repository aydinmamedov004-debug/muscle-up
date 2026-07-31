import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const StatTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 12,
          ),
          child: Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppTheme.accentTint,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: AppTheme.accentSoft,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontSize: 19),
              ),

              const SizedBox(height: 4),

              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
