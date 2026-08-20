import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:jewellery_ops_mobile/app.dart';

void main() {
  testWidgets('Admin status pivots between orders and people', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const JewelleryOpsApp());
    await tester.pumpAndSettle();

    expect(find.text('Status'), findsWidgets);
    expect(find.text('Saanvi Jewels · Jaipur'), findsOneWidget);

    await tester.tap(find.text('People'));
    await tester.pumpAndSettle();

    expect(find.text('Meera Patel'), findsOneWidget);
  });
}
