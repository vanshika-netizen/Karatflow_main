enum AppRole { admin, frontOffice, processManager }

extension AppRoleLabel on AppRole {
  String get label => switch (this) {
    AppRole.admin => 'Admin',
    AppRole.frontOffice => 'Front Office',
    AppRole.processManager => 'Process Manager',
  };

  String get shortDescription => switch (this) {
    AppRole.admin => 'Control, approvals and governance',
    AppRole.frontOffice => 'Designs, clients and orders',
    AppRole.processManager => 'Assignments, stages and inspection',
  };
}

enum StatusPivot { orders, people, stages }

extension StatusPivotLabel on StatusPivot {
  String get label => switch (this) {
    StatusPivot.orders => 'Orders',
    StatusPivot.people => 'People',
    StatusPivot.stages => 'Stages',
  };

  String get singularLabel => switch (this) {
    StatusPivot.orders => 'Order',
    StatusPivot.people => 'Employee',
    StatusPivot.stages => 'Stage',
  };
}

enum HealthTone { critical, warning, healthy }

enum InstructionUrgency { routine, today, urgent }

extension InstructionUrgencyLabel on InstructionUrgency {
  String get label => switch (this) {
    InstructionUrgency.routine => 'Routine',
    InstructionUrgency.today => 'Today',
    InstructionUrgency.urgent => 'Urgent',
  };
}

enum InstructionStatus { sent, acknowledged, inProgress, resolved }

extension InstructionStatusLabel on InstructionStatus {
  String get label => switch (this) {
    InstructionStatus.sent => 'Sent',
    InstructionStatus.acknowledged => 'Acknowledged',
    InstructionStatus.inProgress => 'In progress',
    InstructionStatus.resolved => 'Resolved',
  };
}

class TimelineEntry {
  const TimelineEntry({required this.title, required this.detail, this.time});

  final String title;
  final String detail;
  final String? time;
}

class WorkItem {
  const WorkItem({
    required this.id,
    required this.pivot,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.quantity,
    required this.owner,
    required this.tone,
    required this.metrics,
    required this.timeline,
  });

  final String id;
  final StatusPivot pivot;
  final String title;
  final String subtitle;
  final String status;
  final String quantity;
  final String owner;
  final HealthTone tone;
  final Map<String, String> metrics;
  final List<TimelineEntry> timeline;
}

class Instruction {
  const Instruction({
    required this.id,
    required this.targetId,
    required this.targetLabel,
    required this.message,
    required this.createdBy,
    required this.assignedTo,
    required this.urgency,
    required this.status,
    required this.createdAt,
    this.hasPhoto = false,
    this.hasVoice = false,
  });

  final String id;
  final String targetId;
  final String targetLabel;
  final String message;
  final String createdBy;
  final String assignedTo;
  final InstructionUrgency urgency;
  final InstructionStatus status;
  final DateTime createdAt;
  final bool hasPhoto;
  final bool hasVoice;

  Instruction copyWith({InstructionStatus? status}) => Instruction(
    id: id,
    targetId: targetId,
    targetLabel: targetLabel,
    message: message,
    createdBy: createdBy,
    assignedTo: assignedTo,
    urgency: urgency,
    status: status ?? this.status,
    createdAt: createdAt,
    hasPhoto: hasPhoto,
    hasVoice: hasVoice,
  );
}
