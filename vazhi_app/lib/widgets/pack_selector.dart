/// Pack Selector Widget
///
/// Horizontal scrollable list of knowledge packs.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../providers/chat_provider.dart';

class PackSelector extends ConsumerWidget {
  final String currentPack;
  final Function(String) onPackChanged;

  const PackSelector({
    super.key,
    required this.currentPack,
    required this.onPackChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packs = ref.watch(availablePacksProvider);

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: packs.length,
        itemBuilder: (context, index) {
          final pack = packs[index];
          final isSelected = pack.id == currentPack;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _PackChip(
              pack: pack,
              isSelected: isSelected,
              onTap: () => onPackChanged(pack.id),
            ),
          );
        },
      ),
    );
  }
}

class _PackChip extends StatelessWidget {
  final PackInfo pack;
  final bool isSelected;
  final VoidCallback onTap;

  const _PackChip({
    required this.pack,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? VazhiTheme.primaryColor
              : VazhiTheme.primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? VazhiTheme.primaryColor
                : VazhiTheme.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              pack.icon,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 6),
            Text(
              pack.nameTamil,
              style: TextStyle(
                color: isSelected ? Colors.white : VazhiTheme.primaryColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pack selection bottom sheet for detailed view
class PackSelectorSheet extends ConsumerWidget {
  const PackSelectorSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packs = ref.watch(availablePacksProvider);
    final currentPack = ref.watch(currentPackProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Select Knowledge Pack',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a topic to get specialized answers',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: VazhiTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 20),
          ...packs.map((pack) => _PackTile(
                pack: pack,
                isSelected: pack.id == currentPack,
                onTap: () {
                  ref.read(currentPackProvider.notifier).state = pack.id;
                  Navigator.pop(context);
                },
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _PackTile extends StatelessWidget {
  final PackInfo pack;
  final bool isSelected;
  final VoidCallback onTap;

  const _PackTile({
    required this.pack,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? VazhiTheme.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? VazhiTheme.primaryColor
                : Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? VazhiTheme.primaryColor
                    : VazhiTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  pack.icon,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        pack.nameTamil,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? VazhiTheme.primaryColor
                              : VazhiTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        pack.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: VazhiTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pack.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: VazhiTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: VazhiTheme.primaryColor,
              ),
          ],
        ),
      ),
    );
  }
}
