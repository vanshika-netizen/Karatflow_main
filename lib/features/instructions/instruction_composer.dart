import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/demo_store.dart';
import '../../domain/models.dart';

Future<Instruction?> showInstructionComposer(
  BuildContext context, {
  required DemoStore store,
  required WorkItem target,
}) {
  return Navigator.of(context).push<Instruction>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => InstructionComposerPage(store: store, target: target),
    ),
  );
}

class InstructionComposerPage extends StatefulWidget {
  const InstructionComposerPage({
    super.key,
    required this.store,
    required this.target,
  });

  final DemoStore store;
  final WorkItem target;

  @override
  State<InstructionComposerPage> createState() =>
      _InstructionComposerPageState();
}

class _InstructionComposerPageState extends State<InstructionComposerPage> {
  final _message = TextEditingController();
  InstructionUrgency _urgency = InstructionUrgency.today;
  bool _hasPhoto = false;
  bool _hasVoice = false;
  Instruction? _sent;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_sent != null) return _SuccessView(instruction: _sent!);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Close instruction',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
        title: const Text('New instruction'),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          children: [
            _StepLabel(number: '1', label: 'Target'),
            Card(
              color: AppColors.sage,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: const Icon(Icons.link, color: AppColors.emerald),
                title: Text(
                  widget.target.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text('${widget.target.id} · ${widget.target.status}'),
                trailing: const Icon(Icons.lock_outline, size: 19),
              ),
            ),
            const SizedBox(height: 24),
            _StepLabel(number: '2', label: 'Message'),
            TextField(
              controller: _message,
              onChanged: (_) => setState(() {}),
              minLines: 3,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'What should the Process Manager do?',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _CaptureButton(
                    selected: _hasVoice,
                    icon: Icons.mic_none,
                    label: _hasVoice ? 'Voice attached' : 'Record voice',
                    onPressed: () => setState(() => _hasVoice = !_hasVoice),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _CaptureButton(
                    selected: _hasPhoto,
                    icon: Icons.camera_alt_outlined,
                    label: _hasPhoto ? 'Photo attached' : 'Take photo',
                    onPressed: () => setState(() => _hasPhoto = !_hasPhoto),
                  ),
                ),
              ],
            ),
            if (_hasVoice || _hasPhoto) ...[
              const SizedBox(height: 10),
              Text(
                'Prototype attachment added. Native camera and audio capture are connected in the media implementation slice.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
            ],
            const SizedBox(height: 24),
            _StepLabel(number: '3', label: 'Priority and route'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: InstructionUrgency.values
                  .map(
                    (urgency) => ChoiceChip(
                      label: Text(urgency.label),
                      selected: _urgency == urgency,
                      onSelected: (_) => setState(() => _urgency = urgency),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 14),
            const Card(
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                leading: CircleAvatar(
                  backgroundColor: AppColors.sage,
                  child: Text(
                    'A',
                    style: TextStyle(
                      color: AppColors.emerald,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                title: Text(
                  'Arjun · Process Manager',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text('Responsible manager for this target'),
                trailing: Icon(Icons.notifications_active_outlined),
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
              onPressed: _canSend ? _send : null,
              icon: const Icon(Icons.send_outlined),
              label: const Text('Send to Process Manager'),
            ),
          ),
        ),
      ),
    );
  }

  bool get _canSend => _message.text.trim().isNotEmpty || _hasVoice;

  void _send() {
    final instruction = widget.store.addInstruction(
      target: widget.target,
      message: _message.text,
      urgency: _urgency,
      hasPhoto: _hasPhoto,
      hasVoice: _hasVoice,
    );
    setState(() => _sent = instruction);
  }
}

class _StepLabel extends StatelessWidget {
  const _StepLabel({required this.number, required this.label});

  final String number;
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(
      children: [
        CircleAvatar(
          radius: 13,
          backgroundColor: AppColors.ink,
          foregroundColor: Colors.white,
          child: Text(
            number,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 9),
        Text(label, style: Theme.of(context).textTheme.titleMedium),
      ],
    ),
  );
}

class _CaptureButton extends StatelessWidget {
  const _CaptureButton({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => selected
      ? FilledButton.tonalIcon(
          onPressed: onPressed,
          icon: const Icon(Icons.check),
          label: Text(label),
        )
      : OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
        );
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.instruction});

  final Instruction instruction;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            const Icon(Icons.check_circle, color: AppColors.emerald, size: 74),
            const SizedBox(height: 18),
            Text(
              'Instruction sent',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '${instruction.id} is now in Arjun’s task queue. You will see acknowledgement and resolution here.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => Navigator.pop(context, instruction),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    ),
  );
}
