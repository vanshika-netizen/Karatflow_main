import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/demo_store.dart';
import '../../domain/models.dart';

class AdminTasksPage extends StatelessWidget {
  const AdminTasksPage({super.key, required this.store});

  final DemoStore store;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => _InstructionList(
        title: 'Tasks & approvals',
        subtitle: 'Track instructions and make governed decisions.',
        instructions: store.instructions,
        mode: _TaskMode.admin,
        store: store,
      ),
    );
  }
}

class ProcessManagerTasksPage extends StatelessWidget {
  const ProcessManagerTasksPage({super.key, required this.store});

  final DemoStore store;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => _InstructionList(
        title: 'My tasks',
        subtitle: 'Admin instructions stay visible until resolved.',
        instructions: store.instructions,
        mode: _TaskMode.manager,
        store: store,
      ),
    );
  }
}

class ProcessManagerHome extends StatelessWidget {
  const ProcessManagerHome({super.key, required this.store});

  final DemoStore store;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final active = store.instructions
            .where((item) => item.status != InstructionStatus.resolved)
            .toList();
        return SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              Text(
                'Good morning, Arjun',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 5),
              Text(
                'Tuesday · Morning shift',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan lot or assignment'),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _SummaryTile(
                      value: '${active.length}',
                      label: 'Admin instructions',
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: _SummaryTile(
                      value: '3',
                      label: 'Awaiting inspection',
                      color: AppColors.emerald,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Needs action now',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              if (active.isEmpty)
                const Card(
                  child: ListTile(title: Text('No active Admin instructions')),
                )
              else
                for (final instruction in active.take(2))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _InstructionCard(
                      instruction: instruction,
                      mode: _TaskMode.manager,
                      store: store,
                    ),
                  ),
              const SizedBox(height: 14),
              Text(
                'Workshop exceptions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              const Card(
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFFFFE7DF),
                    child: Icon(Icons.error_outline, color: AppColors.danger),
                  ),
                  title: Text(
                    'Stone setting · JO-10482',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text('56 pieces blocked · 1.30 mm stones'),
                  trailing: Icon(Icons.chevron_right),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InstructionList extends StatelessWidget {
  const _InstructionList({
    required this.title,
    required this.subtitle,
    required this.instructions,
    required this.mode,
    required this.store,
  });

  final String title;
  final String subtitle;
  final List<Instruction> instructions;
  final _TaskMode mode;
  final DemoStore store;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            children: const [
              Chip(label: Text('Actionable')),
              Chip(label: Text('Recently completed')),
            ],
          ),
          const SizedBox(height: 12),
          if (instructions.isEmpty)
            const Card(child: ListTile(title: Text('No tasks in this view')))
          else
            for (final instruction in instructions)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _InstructionCard(
                  instruction: instruction,
                  mode: mode,
                  store: store,
                ),
              ),
        ],
      ),
    );
  }
}

enum _TaskMode { admin, manager }

class _InstructionCard extends StatelessWidget {
  const _InstructionCard({
    required this.instruction,
    required this.mode,
    required this.store,
  });

  final Instruction instruction;
  final _TaskMode mode;
  final DemoStore store;

  @override
  Widget build(BuildContext context) {
    final isResolved = instruction.status == InstructionStatus.resolved;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _UrgencyDot(urgency: instruction.urgency),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    instruction.targetLabel,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _StatusPill(status: instruction.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              instruction.message,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (instruction.hasPhoto || instruction.hasVoice) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  if (instruction.hasVoice)
                    const Chip(
                      avatar: Icon(Icons.play_arrow, size: 18),
                      label: Text('Voice · 0:18'),
                    ),
                  if (instruction.hasPhoto)
                    const Chip(
                      avatar: Icon(Icons.image_outlined, size: 18),
                      label: Text('Photo'),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Text(
              mode == _TaskMode.admin
                  ? 'Assigned to ${instruction.assignedTo}'
                  : 'From ${instruction.createdBy} · ${instruction.urgency.label}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
            if (mode == _TaskMode.manager && !isResolved) ...[
              const SizedBox(height: 14),
              if (instruction.status == InstructionStatus.sent)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => store.setInstructionStatus(
                      instruction.id,
                      InstructionStatus.acknowledged,
                    ),
                    child: const Text('Acknowledge'),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            instruction.status == InstructionStatus.inProgress
                            ? null
                            : () => store.setInstructionStatus(
                                instruction.id,
                                InstructionStatus.inProgress,
                              ),
                        child: const Text('Start'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => store.setInstructionStatus(
                          instruction.id,
                          InstructionStatus.resolved,
                        ),
                        child: const Text('Resolve'),
                      ),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final InstructionStatus status;

  @override
  Widget build(BuildContext context) {
    final color = status == InstructionStatus.resolved
        ? AppColors.emerald
        : AppColors.gold;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _UrgencyDot extends StatelessWidget {
  const _UrgencyDot({required this.urgency});

  final InstructionUrgency urgency;

  @override
  Widget build(BuildContext context) {
    final color = switch (urgency) {
      InstructionUrgency.routine => AppColors.muted,
      InstructionUrgency.today => AppColors.gold,
      InstructionUrgency.urgent => AppColors.danger,
    };
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    ),
  );
}
