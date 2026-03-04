import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qd_and_d/l10n/app_localizations.dart';
import '../../../../core/models/ability_scores.dart';

class AsiStep extends StatefulWidget {
  final AbilityScores currentScores;
  final Function(Map<String, int>) onAllocationChanged;
  final VoidCallback onNext;

  const AsiStep({
    super.key,
    required this.currentScores,
    required this.onAllocationChanged,
    required this.onNext,
  });

  @override
  State<AsiStep> createState() => _AsiStepState();
}

class _AsiStepState extends State<AsiStep> {
  final Map<String, int> _allocations = {
    'strength': 0,
    'dexterity': 0,
    'constitution': 0,
    'intelligence': 0,
    'wisdom': 0,
    'charisma': 0,
  };

  int get _totalAllocated =>
      _allocations.values.fold(0, (sum, val) => sum + val);

  int _getBaseScore(String stat) {
    switch (stat) {
      case 'strength':
        return widget.currentScores.strength;
      case 'dexterity':
        return widget.currentScores.dexterity;
      case 'constitution':
        return widget.currentScores.constitution;
      case 'intelligence':
        return widget.currentScores.intelligence;
      case 'wisdom':
        return widget.currentScores.wisdom;
      case 'charisma':
        return widget.currentScores.charisma;
      default:
        return 10;
    }
  }

  void _increment(String stat) {
    final base = _getBaseScore(stat);
    final allocated = _allocations[stat] ?? 0;
    if (base + allocated < 20 && _totalAllocated < 2) {
      HapticFeedback.lightImpact();
      setState(() {
        _allocations[stat] = allocated + 1;
      });
      widget.onAllocationChanged(_allocations);
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  void _decrement(String stat) {
    final allocated = _allocations[stat] ?? 0;
    if (allocated > 0) {
      HapticFeedback.lightImpact();
      setState(() {
        _allocations[stat] = allocated - 1;
      });
      widget.onAllocationChanged(_allocations);
    }
  }

  String _getStatName(String stat, AppLocalizations l10n) {
    switch (stat) {
      case 'strength':
        return l10n.abilityStr;
      case 'dexterity':
        return l10n.abilityDex;
      case 'constitution':
        return l10n.abilityCon;
      case 'intelligence':
        return l10n.abilityInt;
      case 'wisdom':
        return l10n.abilityWis;
      case 'charisma':
        return l10n.abilityCha;
      default:
        return stat;
    }
  }

  IconData _getStatIcon(String stat) {
    switch (stat) {
      case 'strength':
        return Icons.fitness_center;
      case 'dexterity':
        return Icons.directions_run;
      case 'constitution':
        return Icons.favorite;
      case 'intelligence':
        return Icons.psychology;
      case 'wisdom':
        return Icons.visibility;
      case 'charisma':
        return Icons.auto_awesome;
      default:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isComplete = _totalAllocated == 2;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.abilityScoreImprovementDesc,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.allocateAsiPoints,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Points Tracker
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isComplete
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isComplete ? colorScheme.primary : colorScheme.outline,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.stars,
                    color: isComplete
                        ? colorScheme.primary
                        : colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$_totalAllocated / 2',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isComplete
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Stats List
          Expanded(
            child: ListView(
              children: [
                _buildStatRow('strength', colorScheme, l10n),
                _buildStatRow('dexterity', colorScheme, l10n),
                _buildStatRow('constitution', colorScheme, l10n),
                _buildStatRow('intelligence', colorScheme, l10n),
                _buildStatRow('wisdom', colorScheme, l10n),
                _buildStatRow('charisma', colorScheme, l10n),
              ],
            ),
          ),

          const SizedBox(height: 16),
          FilledButton(
            onPressed: isComplete ? widget.onNext : null,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(l10n.next),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
      String stat, ColorScheme colorScheme, AppLocalizations l10n) {
    final base = _getBaseScore(stat);
    final allocated = _allocations[stat] ?? 0;
    final total = base + allocated;
    final isMaxed = total >= 20;
    final canAdd = !isMaxed && _totalAllocated < 2;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: allocated > 0
            ? colorScheme.primaryContainer.withValues(alpha: 0.3)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: allocated > 0
              ? colorScheme.primary.withValues(alpha: 0.5)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              shape: BoxShape.circle,
            ),
            child:
                Icon(_getStatIcon(stat), color: colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatName(stat, l10n),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  isMaxed ? l10n.maxScoreReached : '$base -> $total',
                  style: TextStyle(
                    fontSize: 12,
                    color: isMaxed
                        ? colorScheme.error
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: allocated > 0 ? () => _decrement(stat) : null,
                icon: const Icon(Icons.remove),
                style: IconButton.styleFrom(
                  minimumSize: const Size(40, 40),
                ),
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  '+$allocated',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: allocated > 0
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                ),
              ),
              IconButton.filled(
                onPressed: canAdd ? () => _increment(stat) : null,
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(
                  minimumSize: const Size(40, 40),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
