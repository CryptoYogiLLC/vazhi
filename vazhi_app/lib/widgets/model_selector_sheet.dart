/// Model Selector Bottom Sheet
///
/// RAM-aware card list for choosing a GGUF model variant.
/// Filters models by device RAM, shows user-friendly names,
/// and recommends the best model for the device.
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
        final variants = ref.watch(compatibleModelsProvider);
        final selected = ref.watch(selectedModelProvider);
        final memInfo = ref.watch(deviceMemoryInfoProvider).valueOrNull;
        final tier = ref.watch(deviceTierProvider);
        final ramUnknown = ref.watch(ramUnknownProvider);

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
                  const SizedBox(height: 12),
                  // RAM banner
                  _RamBanner(
                    memInfo: memInfo,
                    tier: tier,
                    ramUnknown: ramUnknown,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: _buildModelList(
                        variants,
                        selected,
                        memInfo?.totalRamMB ?? 0,
                        tier,
                        context,
                      ),
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

List<Widget> _buildModelList(
  List<ModelVariant> variants,
  ModelVariant selected,
  int totalRamMB,
  DeviceTier tier,
  BuildContext context,
) {
  // sqliteOnly: show informational card instead of model list
  if (tier == DeviceTier.sqliteOnly) {
    return [_SqliteOnlyCard()];
  }

  final recommended = totalRamMB > 0
      ? ModelRegistry.recommendedForDevice(totalRamMB)
      : null;

  return variants.map((v) {
    return _VariantCard(
      variant: v,
      isSelected: v.id == selected.id,
      isRecommended: recommended != null && v.id == recommended.id,
      onTap: () => Navigator.pop(context, v),
    );
  }).toList();
}

class _RamBanner extends StatelessWidget {
  final dynamic memInfo;
  final DeviceTier tier;
  final bool ramUnknown;

  const _RamBanner({
    required this.memInfo,
    required this.tier,
    required this.ramUnknown,
  });

  @override
  Widget build(BuildContext context) {
    if (ramUnknown) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 18, color: Colors.orange[700]),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Unable to detect device memory — showing safe models',
                style: TextStyle(fontSize: 12, color: Colors.orange),
              ),
            ),
          ],
        ),
      );
    }

    final totalGB = memInfo != null
        ? (memInfo.totalRamMB / 1024).toStringAsFixed(1)
        : '?';
    final tierLabel = _tierLabel(tier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: VazhiTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.memory, size: 18, color: VazhiTheme.primaryColor),
          const SizedBox(width: 8),
          Text(
            'Your device: $totalGB GB',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: VazhiTheme.primaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              tierLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: VazhiTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _tierLabel(DeviceTier tier) {
    switch (tier) {
      case DeviceTier.premium:
        return 'Premium';
      case DeviceTier.standard:
        return 'Standard';
      case DeviceTier.compact:
        return 'Compact';
      case DeviceTier.sqliteOnly:
        return 'Basic';
    }
  }
}

class _SqliteOnlyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.info_outline, size: 32, color: Colors.blue),
          const SizedBox(height: 12),
          const Text(
            'AI model not available for this device',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'You can still use knowledge lookups for Thirukkural, '
            'government schemes, emergency numbers, and more.',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _VariantCard extends StatelessWidget {
  final ModelVariant variant;
  final bool isSelected;
  final bool isRecommended;
  final VoidCallback onTap;

  const _VariantCard({
    required this.variant,
    required this.isSelected,
    required this.isRecommended,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color badgeColor;
    switch (variant.quality) {
      case ModelQuality.high:
        badgeColor = Colors.green;
      case ModelQuality.medium:
        badgeColor = Colors.orange;
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
                      Flexible(
                        child: Text(
                          '${variant.displayName} / ${variant.displayNameTamil}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
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
                          variant.quality == ModelQuality.high
                              ? 'High'
                              : 'Medium',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: badgeColor,
                          ),
                        ),
                      ),
                      if (isRecommended) ...[
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
                      if (variant.isTrimmed) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.teal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Trimmed',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.teal,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      // Quantization in small grey text for advanced users
                      Text(
                        variant.quantization,
                        style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                      ),
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
