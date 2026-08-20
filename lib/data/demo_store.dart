import 'package:flutter/foundation.dart';

import '../domain/models.dart';

class DemoStore extends ChangeNotifier {
  DemoStore.seeded()
    : _workItems = _seedWorkItems,
      _instructions = [
        Instruction(
          id: 'INS-014',
          targetId: 'JO-10479',
          targetLabel: 'Order JO-10479',
          message: 'Please confirm the stone replacement before 4 PM.',
          createdBy: 'Ramesh Pareek',
          assignedTo: 'Arjun · Process Manager',
          urgency: InstructionUrgency.today,
          status: InstructionStatus.acknowledged,
          createdAt: DateTime(2026, 8, 11, 9, 20),
          hasPhoto: true,
        ),
      ];

  final List<WorkItem> _workItems;
  final List<Instruction> _instructions;

  List<WorkItem> workItemsFor(StatusPivot pivot) =>
      _workItems.where((item) => item.pivot == pivot).toList(growable: false);

  List<Instruction> get instructions =>
      List.unmodifiable(_instructions.reversed);

  int get actionableInstructionCount => _instructions
      .where((item) => item.status != InstructionStatus.resolved)
      .length;

  Instruction addInstruction({
    required WorkItem target,
    required String message,
    required InstructionUrgency urgency,
    bool hasPhoto = false,
    bool hasVoice = false,
  }) {
    final instruction = Instruction(
      id: 'INS-${(_instructions.length + 15).toString().padLeft(3, '0')}',
      targetId: target.id,
      targetLabel: '${target.pivot.singularLabel} ${target.id}',
      message: message.trim().isEmpty
          ? 'Voice instruction attached.'
          : message.trim(),
      createdBy: 'Ramesh Pareek',
      assignedTo: 'Arjun · Process Manager',
      urgency: urgency,
      status: InstructionStatus.sent,
      createdAt: DateTime.now(),
      hasPhoto: hasPhoto,
      hasVoice: hasVoice,
    );
    _instructions.add(instruction);
    notifyListeners();
    return instruction;
  }

  void setInstructionStatus(String id, InstructionStatus status) {
    final index = _instructions.indexWhere((item) => item.id == id);
    if (index == -1) return;
    _instructions[index] = _instructions[index].copyWith(status: status);
    notifyListeners();
  }

  static final List<WorkItem> _seedWorkItems = [
    WorkItem(
      id: 'JO-10482',
      pivot: StatusPivot.orders,
      title: 'Saanvi Jewels · Jaipur',
      subtitle: 'Promise today · 3 designs',
      status: 'Stone setting blocked',
      quantity: '124 of 180 ready',
      owner: 'Arjun · Process Manager',
      tone: HealthTone.critical,
      metrics: const {'Ordered': '180', 'Ready': '124', 'At risk': '56'},
      timeline: const [
        TimelineEntry(
          title: 'Stone setting blocked',
          detail: '56 pieces waiting for 1.30 mm white stones',
          time: '10:15 AM',
        ),
        TimelineEntry(
          title: 'Polish completed',
          detail: '124 pieces accepted by Meera',
          time: '9:40 AM',
        ),
      ],
    ),
    WorkItem(
      id: 'JO-10479',
      pivot: StatusPivot.orders,
      title: 'Raj Ratna · Ahmedabad',
      subtitle: 'Promise tomorrow · 2 designs',
      status: 'Awaiting approval',
      quantity: '88 of 100 ready',
      owner: 'Arjun · Process Manager',
      tone: HealthTone.warning,
      metrics: const {'Ordered': '100', 'Ready': '88', 'Review': '12'},
      timeline: const [
        TimelineEntry(
          title: 'Inspection submitted',
          detail: '12 pieces require stone replacement approval',
          time: '9:12 AM',
        ),
      ],
    ),
    WorkItem(
      id: 'JO-10471',
      pivot: StatusPivot.orders,
      title: 'Mahalaxmi Ornaments · Pune',
      subtitle: 'Promise Friday · 5 designs',
      status: 'On track',
      quantity: '240 of 320 ready',
      owner: 'Neha · Process Manager',
      tone: HealthTone.healthy,
      metrics: const {'Ordered': '320', 'Ready': '240', 'WIP': '80'},
      timeline: const [
        TimelineEntry(
          title: 'Moved to final polish',
          detail: '80 pieces accepted from setting',
          time: 'Yesterday',
        ),
      ],
    ),
    WorkItem(
      id: 'EMP-023',
      pivot: StatusPivot.people,
      title: 'Meera Patel',
      subtitle: 'Stone setting · Morning shift',
      status: '2 blocked assignments',
      quantity: 'WIP 164 pieces',
      owner: 'Arjun · Process Manager',
      tone: HealthTone.warning,
      metrics: const {'Assignments': '5', 'Blocked': '2', 'Due today': '3'},
      timeline: const [
        TimelineEntry(
          title: 'Assignment paused',
          detail: 'Waiting for replacement stones on JO-10482',
          time: '10:10 AM',
        ),
      ],
    ),
    WorkItem(
      id: 'EMP-041',
      pivot: StatusPivot.people,
      title: 'Kiran Sharma',
      subtitle: 'Polish · Morning shift',
      status: 'Available soon',
      quantity: 'WIP 32 pieces',
      owner: 'Neha · Process Manager',
      tone: HealthTone.healthy,
      metrics: const {'Assignments': '2', 'Blocked': '0', 'Due today': '1'},
      timeline: const [
        TimelineEntry(
          title: 'Assignment near completion',
          detail: '32 pieces expected by 11:30 AM',
          time: '9:55 AM',
        ),
      ],
    ),
    WorkItem(
      id: 'STG-SETTING',
      pivot: StatusPivot.stages,
      title: 'Stone setting',
      subtitle: '14 active lots · 6 employees',
      status: 'Queue above target',
      quantity: '620 pieces in WIP',
      owner: 'Arjun · Process Manager',
      tone: HealthTone.critical,
      metrics: const {'Active lots': '14', 'Blocked': '3', 'Oldest': '19h'},
      timeline: const [
        TimelineEntry(
          title: 'Queue threshold crossed',
          detail: 'Oldest lot is 7 hours above stage target',
          time: '8:45 AM',
        ),
      ],
    ),
    WorkItem(
      id: 'STG-POLISH',
      pivot: StatusPivot.stages,
      title: 'Final polish',
      subtitle: '8 active lots · 4 employees',
      status: 'On track',
      quantity: '284 pieces in WIP',
      owner: 'Neha · Process Manager',
      tone: HealthTone.healthy,
      metrics: const {'Active lots': '8', 'Blocked': '0', 'Oldest': '5h'},
      timeline: const [
        TimelineEntry(
          title: 'Healthy queue',
          detail: 'All lots are within the stage target',
          time: '8:30 AM',
        ),
      ],
    ),
  ];
}
