import 'package:flutter_test/flutter_test.dart';
import 'package:jewellery_ops_mobile/data/demo_store.dart';
import 'package:jewellery_ops_mobile/domain/models.dart';

void main() {
  test('instruction keeps target context through its lifecycle', () {
    final store = DemoStore.seeded();
    addTearDown(store.dispose);
    final target = store.workItemsFor(StatusPivot.orders).first;

    final instruction = store.addInstruction(
      target: target,
      message: 'Confirm the replacement stones.',
      urgency: InstructionUrgency.urgent,
      hasPhoto: true,
    );

    expect(instruction.targetId, target.id);
    expect(instruction.targetLabel, 'Order ${target.id}');
    expect(instruction.status, InstructionStatus.sent);
    expect(store.instructions.first.id, instruction.id);

    store.setInstructionStatus(instruction.id, InstructionStatus.acknowledged);
    expect(store.instructions.first.status, InstructionStatus.acknowledged);

    store.setInstructionStatus(instruction.id, InstructionStatus.resolved);
    expect(store.instructions.first.status, InstructionStatus.resolved);
  });
}
