import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import 'primary_button.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  final String? buttonText;
  final VoidCallback? onPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 420,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 52,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.md),

              Text(
                subtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      color: Colors.grey,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),

              if (buttonText != null &&
                  onPressed != null) ...[
                const SizedBox(height: AppSpacing.xl),

                PrimaryButton(
                  text: buttonText!,
                  onPressed: onPressed!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}