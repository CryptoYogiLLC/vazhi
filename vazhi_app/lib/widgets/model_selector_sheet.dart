/// Model Selector Bottom Sheet
///
/// Radio-style card list for choosing a GGUF model variant.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../models/model_variant.dart';
import '../providers/model_provider.dart';

class ModelSelectorSheet extends StatelessWidget {
  const ModelSelectorSheet._();

  /// Show the sheet and return the selected variant, or null if dismissed.
  static Future<ModelVariant?> show(BuildContext context, WidgetRef ref) {
    return showModalBottomSheet<ModelVariant>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const ModelSelectorSheet._(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final variants = ref.watch(availableModelsProvider);
        final selected = ref.watch(selectedModelProvider);

        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text(
                    'Select Model',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: _buildGroupedList(variants, selected, context),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

List<Widget> _buildGroupedList(
  List<ModelVariant> variants,
  ModelVariant selected,
  BuildContext context,
) {
  final vazhi = variants.where((v) => v.isVazhi).toList();
  final other = variants.where((v) => !v.isVazhi).toList();

  return [
    if (vazhi.isNotEmpty) ...[
      _SectionHeader(label: 'VAZHI Models', subtitle: 'Fine-tuned for Tamil'),
      ...vazhi.map(
        (v) => _VariantCard(
          variant: v,
          isSelected: v.id == selected.id,
          onTap: () => Navigator.pop(context, v),
        ),
      ),
    ],
    if (other.isNotEmpty) ...[
      const SizedBox(height: 8),
      _SectionHeader(
        label: 'Community Models',
        subtitle: 'Vanilla / untrained',
      ),
      ...other.map(
        (v) => _VariantCard(
          variant: v,
          isSelected: v.id == selected.id,
          onTap: () => Navigator.pop(context, v),
        ),
      ),
    ],
  ];
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final String subtitle;

  const _SectionHeader({required this.label, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class _VariantCard extends StatelessWidget {
  final ModelVariant variant;
  final bool isSelected;
  final VoidCallback onTap;

  const _VariantCard({
    required this.variant,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDefault = variant.id == ModelRegistry.defaultVariant.id;
    final isLow = variant.quality == ModelQuality.low;
    final isLite = variant.quality == ModelQuality.lite;

    final Color badgeColor;
    switch (variant.quality) {
      case ModelQuality.high:
        badgeColor = Colors.green;
      case ModelQuality.medium:
        badgeColor = Colors.orange;
      case ModelQuality.low:
        badgeColor = Colors.red;
      case ModelQuality.lite:
        badgeColor = Colors.blue;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? VazhiTheme.primaryColor.withValues(alpha: 0.08)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? VazhiTheme.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio indicator
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? VazhiTheme.primaryColor : Colors.grey,
              size: 22,
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        variant.quantization,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${variant.qualityLabel} / ${variant.qualityLabelTamil}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: badgeColor,
                          ),
                        ),
                      ),
                      if (isDefault) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: VazhiTheme.primaryColor.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Recommended',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: VazhiTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        variant.displaySize,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'RAM ${(variant.recommendedRamMB / 1024).toStringAsFixed(0)} GB+',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      if (isLow || isLite) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 14,
                          color: Colors.orange[700],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
