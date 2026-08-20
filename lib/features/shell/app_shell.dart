import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/demo_store.dart';
import '../../domain/models.dart';
import '../status/admin_status_page.dart';
import '../tasks/task_pages.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.role,
    required this.store,
    required this.onRoleChanged,
  });

  final AppRole role;
  final DemoStore store;
  final ValueChanged<AppRole> onRoleChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.role != widget.role) _selectedIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    final destinations = _destinations(widget.role);
    final pages = _pages(widget.role);
    final body = AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: KeyedSubtree(
        key: ValueKey('${widget.role.name}-$_selectedIndex'),
        child: pages[_selectedIndex],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 68,
        titleSpacing: 20,
        title: Row(
          children: [
            const _BrandMark(),
            const SizedBox(width: 11),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KARATFLOW',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    letterSpacing: 1.7,
                    fontSize: 13,
                  ),
                ),
                Text(
                  _greeting(widget.role),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Semantics(
            button: true,
            label: 'Switch current role. ${widget.role.label} selected.',
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: MediaQuery.sizeOf(context).width < 560
                  ? IconButton.filledTonal(
                      tooltip: 'Switch role · ${widget.role.label}',
                      onPressed: _showRolePicker,
                      icon: const Icon(Icons.person_outline),
                    )
                  : ActionChip(
                      avatar: const Icon(Icons.person_outline, size: 19),
                      label: Text(widget.role.label),
                      onPressed: _showRolePicker,
                    ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 820) {
            return Row(
              children: [
                NavigationRail(
                  extended: constraints.maxWidth >= 1080,
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _select,
                  groupAlignment: -0.9,
                  backgroundColor: AppColors.paper,
                  indicatorColor: AppColors.sage,
                  destinations: destinations
                      .map(
                        (item) => NavigationRailDestination(
                          icon: _destinationIcon(item, selected: false),
                          selectedIcon: _destinationIcon(item, selected: true),
                          label: Text(item.label),
                        ),
                      )
                      .toList(),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            );
          }
          return body;
        },
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (MediaQuery.sizeOf(context).width >= 820) {
            return const SizedBox.shrink();
          }
          return NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _select,
            destinations: destinations
                .map(
                  (item) => NavigationDestination(
                    icon: _destinationIcon(item, selected: false),
                    selectedIcon: _destinationIcon(item, selected: true),
                    label: item.label,
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }

  List<Widget> _pages(AppRole role) => switch (role) {
    AppRole.admin => [
      AdminStatusPage(store: widget.store),
      const SectionPage(
        title: 'Reports',
        description:
            'Operational answers with drill-down to the records behind them.',
        icon: Icons.query_stats,
        items: [
          'Order promise',
          'Production ageing',
          'Stage throughput',
          'Quality exceptions',
        ],
      ),
      const SectionPage(
        title: 'Manage',
        description: 'Focused master-data changes without long forms.',
        icon: Icons.tune,
        items: [
          'Employees',
          'Clients',
          'Categories',
          'Price books',
          'Routes and stages',
        ],
      ),
      const SectionPage(
        title: 'Stock',
        description:
            'Available, reserved, ready and mismatched stock in one place.',
        icon: Icons.inventory_2_outlined,
        items: [
          'Available',
          'Reserved',
          'Ready to dispatch',
          'Reconciliation issues',
        ],
      ),
      AdminTasksPage(store: widget.store),
    ],
    AppRole.processManager => [
      ProcessManagerHome(store: widget.store),
      const SectionPage(
        title: 'Scan',
        description:
            'Scan a lot or assignment label to open its current truth.',
        icon: Icons.qr_code_scanner,
        items: ['Camera scan', 'Enter lot number', 'Recent scans'],
      ),
      ProcessManagerTasksPage(store: widget.store),
      const SectionPage(
        title: 'Team',
        description:
            'Current workload, skill fit and blockers—without worker rankings.',
        icon: Icons.groups_outlined,
        items: ['Available now', 'Active assignments', 'Blocked work'],
      ),
      const SectionPage(
        title: 'More',
        description: 'Shift, printer, language and help settings.',
        icon: Icons.more_horiz,
        items: ['Current shift', 'Label printer', 'Language', 'Help'],
      ),
    ],
    AppRole.frontOffice => const [
      SectionPage(
        title: 'Designs',
        description:
            'Image-first catalogue with fast quantities and remembered browsing position.',
        icon: Icons.auto_awesome_mosaic_outlined,
        items: ['Necklaces', 'Earrings', 'Rings', 'Bangles'],
      ),
      SectionPage(
        title: 'Cart',
        description:
            'Design quantities, client selection and one clear order commitment.',
        icon: Icons.shopping_bag_outlined,
        items: ['Selected designs', 'Choose client', 'Notes and media'],
      ),
      SectionPage(
        title: 'Orders',
        description: 'Numeric contains-search across pending and past orders.',
        icon: Icons.receipt_long_outlined,
        items: ['Pending', 'Ready', 'Dispatched', 'Past'],
      ),
      SectionPage(
        title: 'Clients',
        description: 'Find a client by firm name or city.',
        icon: Icons.storefront_outlined,
        items: ['Recent clients', 'Search firms', 'Search cities'],
      ),
      SectionPage(
        title: 'More',
        description: 'Drafts, language and help.',
        icon: Icons.more_horiz,
        items: ['Saved drafts', 'Language', 'Help'],
      ),
    ],
  };

  void _select(int index) => setState(() => _selectedIndex = index);

  void _showRolePicker() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Preview as', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            const Text(
              'Production sign-in will select the correct role automatically.',
            ),
            const SizedBox(height: 16),
            for (final role in AppRole.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  minTileHeight: 64,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: AppColors.outline),
                  ),
                  leading: Icon(_roleIcon(role)),
                  title: Text(role.label),
                  subtitle: Text(role.shortDescription),
                  trailing: widget.role == role
                      ? const Icon(Icons.check_circle, color: AppColors.emerald)
                      : const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onRoleChanged(role);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String _greeting(AppRole role) => switch (role) {
    AppRole.admin => 'Operations control',
    AppRole.frontOffice => 'Orders and clients',
    AppRole.processManager => 'Workshop flow',
  };
}

class _Destination {
  const _Destination(this.label, this.icon, {this.badge});

  final String label;
  final IconData icon;
  final int? badge;
}

List<_Destination> _destinations(AppRole role) => switch (role) {
  AppRole.admin => const [
    _Destination('Status', Icons.space_dashboard_outlined),
    _Destination('Reports', Icons.query_stats_outlined),
    _Destination('Manage', Icons.tune),
    _Destination('Stock', Icons.inventory_2_outlined),
    _Destination('Tasks', Icons.task_alt_outlined, badge: 2),
  ],
  AppRole.frontOffice => const [
    _Destination('Designs', Icons.auto_awesome_mosaic_outlined),
    _Destination('Cart', Icons.shopping_bag_outlined),
    _Destination('Orders', Icons.receipt_long_outlined),
    _Destination('Clients', Icons.storefront_outlined),
    _Destination('More', Icons.more_horiz),
  ],
  AppRole.processManager => const [
    _Destination('Status', Icons.space_dashboard_outlined),
    _Destination('Scan', Icons.qr_code_scanner),
    _Destination('Tasks', Icons.task_alt_outlined, badge: 2),
    _Destination('Team', Icons.groups_outlined),
    _Destination('More', Icons.more_horiz),
  ],
};

Widget _destinationIcon(_Destination item, {required bool selected}) {
  final icon = Icon(item.icon, fill: selected ? 1 : 0);
  if (item.badge == null) return icon;
  return Badge(label: Text('${item.badge}'), child: icon);
}

IconData _roleIcon(AppRole role) => switch (role) {
  AppRole.admin => Icons.admin_panel_settings_outlined,
  AppRole.frontOffice => Icons.storefront_outlined,
  AppRole.processManager => Icons.precision_manufacturing_outlined,
};

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(11),
      ),
      alignment: Alignment.center,
      child: const Text(
        'K',
        style: TextStyle(
          color: Color(0xFFFFD18A),
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class SectionPage extends StatelessWidget {
  const SectionPage({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.items,
  });

  final String title;
  final String description;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          Icon(icon, size: 36, color: AppColors.gold),
          const SizedBox(height: 18),
          Text(title, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  minTileHeight: 66,
                  title: Text(
                    item,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            'This destination is included in the foundation. Its full workflow is scheduled after the first connected control loop.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
