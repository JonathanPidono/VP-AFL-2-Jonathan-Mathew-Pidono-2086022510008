import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../domain/models/tcg_card.dart';

class BrandSelector extends StatelessWidget {
  const BrandSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  final String selected;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Brand', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        SegmentedButton<String>(
          showSelectedIcon: false,
          style: const ButtonStyle(
            minimumSize: WidgetStatePropertyAll(
              Size(0, AppSpacing.touchTarget),
            ),
          ),
          segments: [
            for (final brand in brandNames)
              ButtonSegment<String>(
                value: brand,
                enabled: enabled,
                label: Text(
                  brand,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          selected: {selected},
          onSelectionChanged: (selection) => onChanged(selection.first),
        ),
      ],
    );
  }
}
