import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/demo_store.dart';
import '../../domain/models.dart';
import '../instructions/instruction_composer.dart';

class AdminStatusPage extends StatefulWidget {
  const AdminStatusPage({super.key, required this.store});

  final DemoStore store;

  @override
  State<AdminStatusPage> createState() => _AdminStatusPageState();
}

class _AdminStatusPageState extends State<AdminStatusPage> {
  StatusPivot _pivot = StatusPivot.orders;
  bool _exceptionsOnly = true;

  @override
  Widget build(BuildContext context) {
    final all = widget.store.workItemsFor(_pivot);
    final items = _exceptionsOnly
        ? all.where((item) => item.tone != HealthTone.healthy).toList()
        : all;

    return SafeArea(
      top: false,
      child: RefreshIndicator(
        onRefresh: () async =>
            Future<void>.delayed(const Duration(milliseconds: 450)),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              sliver: SliverList.list(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status',
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tuesday · All locations',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                      IconButton.filledTonal(
                        tooltip: 'Search status',
                        onPressed: () {},
                        icon: const Icon(Icons.search),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const _HealthStrip(),
                  const SizedBox(height: 20),
                  SegmentedButton<StatusPivot>(
                    segments: StatusPivot.values
                        .map(
                          (pivot) => ButtonSegment(
                            value: pivot,
                            label: Text(pivot.label),
                          ),
                        )
                        .toList(),
                    selected: {_pivot},
                    showSelectedIcon: false,
                    onSelectionChanged: (selection) =>
                        setState(() => _pivot = selection.first),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      FilterChip(
                        label: const Text('Needs attention'),
                        selected: _exceptionsOnly,
                        onSelected: (value) =>
                            setState(() => _exceptionsOnly = value),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.tune, size: 18),
                        label: const Text('Filters'),
                        onPressed: () {},
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          '${items.length} shown',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (items.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _HealthyEmptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                sliver: SliverList.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _StatusCard(
                    item: items[index],
                    onOpen: () => _openDetail(items[index]),
                    onInstruction: () => _composeInstruction(items[index]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDetail(WorkItem item) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StatusDetailPage(item: item, store: widget.store),
      ),
    );
  }

  Future<void> _composeInstruction(WorkItem item) async {
    await showInstructionComposer(context, store: widget.store, target: item);
  }
}

class _HealthStrip extends StatelessWidget {
  const _HealthStrip();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.ink,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        child: Row(
          children: const [
            Expanded(
              child: _HealthMetric(
                value: '3',
                label: 'Blocked',
                accent: Color(0xFFFFA88D),
              ),
            ),
            _MetricDivider(),
            Expanded(
              child: _HealthMetric(
                value: '5',
                label: 'Due risk',
                accent: Color(0xFFFFD18A),
              ),
            ),
            _MetricDivider(),
            Expanded(
              child: _HealthMetric(
                value: '2',
                label: 'Approvals',
                accent: Color(0xFFA9DDD0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthMetric extends StatelessWidget {
  const _HealthMetric({
    required this.value,
    required this.label,
    required this.accent,
  });

  final String value;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: accent,
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 38, color: Colors.white24);
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.item,
    required this.onOpen,
    required this.onInstruction,
  });

  final WorkItem item;
  final VoidCallback onOpen;
  final VoidCallback onInstruction;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = _tone(item.tone);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.subtitle,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  _TonePill(label: label, color: color),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                item.status,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 3),
              Text(
                '${item.quantity} · ${item.owner}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onInstruction,
                      icon: const Icon(Icons.chat_bubble_outline, size: 19),
                      label: const Text('Instruction'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    tooltip: 'Open status details',
                    onPressed: onOpen,
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TonePill extends StatelessWidget {
  const _TonePill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 11),
    ),
  );
}

class _HealthyEmptyState extends StatelessWidget {
  const _HealthyEmptyState();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 50,
            color: AppColors.emerald,
          ),
          const SizedBox(height: 12),
          Text(
            'No exceptions in this view',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          const Text('Turn off Needs attention to see all healthy work.'),
        ],
      ),
    ),
  );
}

class StatusDetailPage extends StatelessWidget {
  const StatusDetailPage({super.key, required this.item, required this.store});

  final WorkItem item;
  final DemoStore store;

  @override
  Widget build(BuildContext context) {
    final (_, color, icon) = _tone(item.tone);
    return Scaffold(
      appBar: AppBar(title: Text(item.id)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
          children: [
            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.subtitle,
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Card(
              color: AppColors.ink,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: item.metrics.entries
                      .map(
                        (entry) => Expanded(
                          child: Column(
                            children: [
                              Text(
                                entry.value,
                                style: const TextStyle(
                                  color: Color(0xFFFFD18A),
                                  fontSize: 23,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                entry.key,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Current truth',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  item.status,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('${item.quantity}\nOwner: ${item.owner}'),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Timeline', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            for (final entry in item.timeline)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.radio_button_checked,
                  color: AppColors.emerald,
                  size: 20,
                ),
                title: Text(
                  entry.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(entry.detail),
                trailing: entry.time == null
                    ? null
                    : Text(
                        entry.time!,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
              ),
          ],
        ),
      ),
      bottomSheet: SafeArea(
        top: false,
        child: Container(
          color: AppColors.canvas,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () =>
                  showInstructionComposer(context, store: store, target: item),
              icon: const Icon(Icons.add_comment_outlined),
              label: const Text('Add instruction'),
            ),
          ),
        ),
      ),
    );
  }
}

(String, Color, IconData) _tone(HealthTone tone) => switch (tone) {
  HealthTone.critical => ('Blocked', AppColors.danger, Icons.error_outline),
  HealthTone.warning => ('Attention', AppColors.warning, Icons.schedule),
  HealthTone.healthy => (
    'Healthy',
    AppColors.emerald,
    Icons.check_circle_outline,
  ),
};
