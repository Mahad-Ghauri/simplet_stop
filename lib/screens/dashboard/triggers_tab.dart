import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class TriggersTab extends StatelessWidget {
  const TriggersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context),

              const SizedBox(height: 24),

              // Common Triggers
              _buildCommonTriggers(context),

              const SizedBox(height: 24),

              // Personal Triggers
              _buildPersonalTriggers(context),

              const SizedBox(height: 24),

              // Coping Strategies
              _buildCopingStrategies(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Triggers & Coping', style: AppTheme.headingMedium),
        const SizedBox(height: 8),
        Text(
          'Identify your triggers and learn healthy coping strategies',
          style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildCommonTriggers(BuildContext context) {
    final triggers = [
      {
        'name': 'Stress',
        'icon': Icons.psychology,
        'color': AppTheme.errorColor,
      },
      {
        'name': 'Social Situations',
        'icon': Icons.people,
        'color': AppTheme.primaryColor,
      },
      {
        'name': 'After Meals',
        'icon': Icons.restaurant,
        'color': AppTheme.secondaryColor,
      },
      {
        'name': 'Coffee/Tea',
        'icon': Icons.coffee,
        'color': AppTheme.warningColor,
      },
      {
        'name': 'Boredom',
        'icon': Icons.sentiment_dissatisfied,
        'color': AppTheme.accentColor,
      },
      {
        'name': 'Driving',
        'icon': Icons.directions_car,
        'color': AppTheme.primaryColor,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Common Triggers', style: AppTheme.headingSmall),
        const SizedBox(height: 16),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: triggers.length,
          itemBuilder: (context, index) {
            final trigger = triggers[index];
            return _buildTriggerCard(
              context,
              trigger['name'] as String,
              trigger['icon'] as IconData,
              trigger['color'] as Color,
            );
          },
        ),
      ],
    );
  }

  Widget _buildTriggerCard(
    BuildContext context,
    String name,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          // TODO: Show trigger details and coping strategies
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 12),
              Text(
                name,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalTriggers(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Your Triggers', style: AppTheme.headingSmall),
            TextButton.icon(
              onPressed: () {
                // TODO: Add new trigger
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildPersonalTriggerItem(
                  'Work stress',
                  'High',
                  Icons.work,
                  AppTheme.errorColor,
                ),
                const Divider(),
                _buildPersonalTriggerItem(
                  'Evening routine',
                  'Medium',
                  Icons.nightlight,
                  AppTheme.warningColor,
                ),
                const Divider(),
                _buildPersonalTriggerItem(
                  'Weekend parties',
                  'High',
                  Icons.celebration,
                  AppTheme.errorColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalTriggerItem(
    String name,
    String intensity,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTheme.bodyMedium),
                Text(
                  'Intensity: $intensity',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Edit trigger
            },
            icon: const Icon(Icons.edit, size: 16),
            color: AppTheme.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildCopingStrategies(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Coping Strategies', style: AppTheme.headingSmall),
        const SizedBox(height: 16),

        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStrategyItem(
                  'Deep Breathing',
                  'Take 5 deep breaths when you feel triggered',
                  Icons.air,
                  AppTheme.primaryColor,
                ),
                const Divider(),
                _buildStrategyItem(
                  'Physical Activity',
                  'Go for a walk or do some exercise',
                  Icons.directions_walk,
                  AppTheme.secondaryColor,
                ),
                const Divider(),
                _buildStrategyItem(
                  'Distraction',
                  'Call a friend or read a book',
                  Icons.phone,
                  AppTheme.accentColor,
                ),
                const Divider(),
                _buildStrategyItem(
                  'Mindfulness',
                  'Practice meditation or yoga',
                  Icons.self_improvement,
                  AppTheme.successColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStrategyItem(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
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
