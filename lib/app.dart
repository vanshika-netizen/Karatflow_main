import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'data/demo_store.dart';
import 'domain/models.dart';
import 'features/shell/app_shell.dart';

class JewelleryOpsApp extends StatefulWidget {
  const JewelleryOpsApp({super.key, this.initialRole = AppRole.admin});

  final AppRole initialRole;

  @override
  State<JewelleryOpsApp> createState() => _JewelleryOpsAppState();
}

class _JewelleryOpsAppState extends State<JewelleryOpsApp> {
  late AppRole _role = widget.initialRole;
  final DemoStore _store = DemoStore.seeded();

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KaratFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: AppShell(
        role: _role,
        store: _store,
        onRoleChanged: (role) => setState(() => _role = role),
      ),
    );
  }
}
