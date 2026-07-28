import 'package:flutter/material.dart';

/// Interactive editor for a training/rest pattern like "1010101".
/// Tap a day to toggle training/rest; use +/- to change the cycle length.
class PatternEditor extends StatelessWidget {
  final String pattern;
  final ValueChanged<String> onChanged;

  const PatternEditor({
    super.key,
    required this.pattern,
    required this.onChanged,
  });

  static const int minLength = 2;
  static const int maxLength = 14;

  void _toggle(int index) {
    final chars = pattern.split('');
    chars[index] = chars[index] == '1' ? '0' : '1';
    onChanged(chars.join());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(pattern.length, (i) {
            final training = pattern[i] == '1';
            return InkWell(
              onTap: () => _toggle(i),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 44,
                height: 56,
                decoration: BoxDecoration(
                  color: training
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${i + 1}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: training
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Icon(
                      training ? Icons.fitness_center : Icons.hotel,
                      size: 18,
                      color: training
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              'Cycle: ${pattern.length} days  ·  Pattern: $pattern',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const Spacer(),
            IconButton.filledTonal(
              visualDensity: VisualDensity.compact,
              onPressed: pattern.length > minLength
                  ? () => onChanged(pattern.substring(0, pattern.length - 1))
                  : null,
              icon: const Icon(Icons.remove, size: 18),
              tooltip: 'Remove a day',
            ),
            IconButton.filledTonal(
              visualDensity: VisualDensity.compact,
              onPressed: pattern.length < maxLength
                  ? () => onChanged('${pattern}0')
                  : null,
              icon: const Icon(Icons.add, size: 18),
              tooltip: 'Add a day',
            ),
          ],
        ),
      ],
    );
  }
}
