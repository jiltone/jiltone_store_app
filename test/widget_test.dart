import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jiltone_store_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const JiltoneApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
